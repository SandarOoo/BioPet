import 'dart:isolate';

import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateInference {
  static const String _debugName = 'TFLITE_INFERENCE';

  final ReceivePort _receivePort = ReceivePort();

  Isolate? _isolate;
  SendPort? _sendPort;

  SendPort get sendPort {
    final port = _sendPort;

    if (port == null) {
      throw StateError('Inference isolate has not been started.');
    }

    return port;
  }

  Future<void> start() async {
    if (_isolate != null && _sendPort != null) {
      return;
    }

    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );

    final firstMessage = await _receivePort.first;

    if (firstMessage is! SendPort) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;

      throw StateError(
        'Inference isolate did not return a SendPort.',
      );
    }

    _sendPort = firstMessage;
  }

  Future<void> close() async {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _receivePort.close();
  }

  static Future<void> entryPoint(
      SendPort mainSendPort,
      ) async {
    final isolateReceivePort = ReceivePort();
    mainSendPort.send(isolateReceivePort.sendPort);

    await for (final message in isolateReceivePort) {
      if (message is! InferenceModel) {
        continue;
      }

      final isolateModel = message;

      try {
        final sourceImage = isolateModel.image;

        if (sourceImage == null) {
          isolateModel.responsePort.send(<String, double>{});
          continue;
        }

        if (isolateModel.inputShape.length < 4 ||
            isolateModel.outputShape.length < 2) {
          throw StateError('Unexpected TensorFlow Lite tensor shape.');
        }

        final inputHeight = isolateModel.inputShape[1];
        final inputWidth = isolateModel.inputShape[2];

        final resizedImage = image_lib.copyResize(
          sourceImage,
          width: inputWidth,
          height: inputHeight,
        );

        final imageMatrix = List<List<List<int>>>.generate(
          inputHeight,
              (y) => List<List<int>>.generate(
            inputWidth,
                (x) {
              final pixel = resizedImage.getPixel(x, y);

              return <int>[
                pixel.r.toInt(),
                pixel.g.toInt(),
                pixel.b.toInt(),
              ];
            },
            growable: false,
          ),
          growable: false,
        );

        final input = <Object>[
          imageMatrix,
        ];

        final outputLength = isolateModel.outputShape[1];
        final output = <List<int>>[
          List<int>.filled(outputLength, 0),
        ];

        final interpreter = Interpreter.fromAddress(
          isolateModel.interpreterAddress,
        );

        interpreter.run(input, output);

        final scores = output.first;
        final usableLength = scores.length < isolateModel.labels.length
            ? scores.length
            : isolateModel.labels.length;

        final totalScore = scores
            .take(usableLength)
            .fold<int>(0, (sum, score) => sum + score);

        if (totalScore <= 0) {
          isolateModel.responsePort.send(<String, double>{});
          continue;
        }

        final classification = <String, double>{};

        for (var index = 0; index < usableLength; index++) {
          final score = scores[index];

          if (score <= 0) {
            continue;
          }

          classification[isolateModel.labels[index]] =
              score.toDouble() / totalScore.toDouble();
        }

        isolateModel.responsePort.send(classification);
      } catch (error, stackTrace) {
        // SendPort has only send(); sending an empty result keeps the
        // caller safe and avoids crashing the isolate or the Flutter app.
        print('TFLITE INFERENCE ERROR: $error');
        print(stackTrace);
        isolateModel.responsePort.send(<String, double>{});
      }
    }
  }
}

class InferenceModel {
  final image_lib.Image? image;
  final int interpreterAddress;
  final List<String> labels;
  final List<int> inputShape;
  final List<int> outputShape;

  late SendPort responsePort;

  InferenceModel(
      this.image,
      this.interpreterAddress,
      this.labels,
      this.inputShape,
      this.outputShape,
      );
}
