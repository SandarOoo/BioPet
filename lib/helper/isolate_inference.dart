import 'dart:isolate';

import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateInference {
  static const String _debugName = 'TFLITE_INFERENCE';

  final ReceivePort _receivePort = ReceivePort();

  late Isolate _isolate;
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );

    _sendPort = await _receivePort.first as SendPort;
  }

  Future<void> close() async {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel isolateModel in port) {
      try {
        final sourceImage = isolateModel.image;

        if (sourceImage == null) {
          isolateModel.responsePort.send(<String, double>{});
          continue;
        }

        final imageInput = image_lib.copyResize(
          sourceImage,
          width: isolateModel.inputShape[1],
          height: isolateModel.inputShape[2],
        );

        final imageMatrix = List.generate(
          imageInput.height,
          (y) => List.generate(
            imageInput.width,
            (x) {
              final pixel = imageInput.getPixel(x, y);
              return <int>[
                pixel.r.toInt(),
                pixel.g.toInt(),
                pixel.b.toInt(),
              ];
            },
          ),
        );

        final input = [imageMatrix];
        final output = [
          List<int>.filled(
            isolateModel.outputShape[1],
            0,
          ),
        ];

        final interpreter = Interpreter.fromAddress(
          isolateModel.interpreterAddress,
        );

        interpreter.run(input, output);

        final result = output.first;
        final totalScore = result.fold<int>(
          0,
          (sum, score) => sum + score,
        );

        if (totalScore <= 0) {
          isolateModel.responsePort.send(<String, double>{});
          continue;
        }

        final classification = <String, double>{};
        final resultCount = result.length < isolateModel.labels.length
            ? result.length
            : isolateModel.labels.length;

        for (var index = 0; index < resultCount; index++) {
          final score = result[index];

          if (score <= 0) continue;

          classification[isolateModel.labels[index]] =
              score.toDouble() / totalScore.toDouble();
        }

        isolateModel.responsePort.send(classification);
      } catch (error) {
        isolateModel.responsePort.sendError(
          error,
          StackTrace.current,
        );
      }
    }
  }
}

class InferenceModel {
  image_lib.Image? image;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel(
    this.image,
    this.interpreterAddress,
    this.labels,
    this.inputShape,
    this.outputShape,
  );
}
