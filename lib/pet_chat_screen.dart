import 'package:biopet/services/chat_service.dart';
import 'package:flutter/material.dart';

class PetChatScreen extends StatefulWidget {
  const PetChatScreen({super.key});

  @override
  State<PetChatScreen> createState() => _PetChatScreenState();
}

class _PetChatScreenState extends State<PetChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'text':
      'မင်္ဂလာပါ 🐾 BioPet AI ပါ။\nခွေးနဲ့ကြောင်တို့ရဲ့ အစားအသောက်၊ ကျန်းမာရေး၊ သန့်ရှင်းရေးနဲ့ အပြုအမူအကြောင်း မေးနိုင်ပါတယ်။',
      'isUser': false,
    },
  ];

  bool isLoading = false;

  Future<void> sendMessage() async {
    final userText = controller.text.trim();

    if (userText.isEmpty || isLoading) return;

    setState(() {
      messages.add({
        'text': userText,
        'isUser': true,
      });
      messages.add({
        'text': 'BioPet AI စဉ်းစားနေပါတယ်...',
        'isUser': false,
        'isLoading': true,
      });
      isLoading = true;
    });

    controller.clear();
    _scrollToBottom();

    try {
      final aiReply = await ChatService.sendMessage(userText);

      if (!mounted) return;

      setState(() {
        messages.removeWhere((message) => message['isLoading'] == true);
        messages.add({
          'text': aiReply,
          'isUser': false,
        });
        isLoading = false;
      });
    } on ChatServiceException catch (error) {
      if (!mounted) return;

      setState(() {
        messages.removeWhere((message) => message['isLoading'] == true);
        messages.add({
          'text': '⚠️ ${error.message}',
          'isUser': false,
          'isError': true,
        });
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        messages.removeWhere((message) => message['isLoading'] == true);
        messages.add({
          'text': '⚠️ တစ်ခုခုမှားနေပါတယ်။ ခဏနေရင် ပြန်စမ်းပါ။',
          'isUser': false,
          'isError': true,
        });
        isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets),
            SizedBox(width: 8),
            Text(
              'BioPet AI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF065F46), Color(0xFF065F46)],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(15),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message['isUser'] as bool? ?? false;
                  final isLoadingMessage =
                      message['isLoading'] as bool? ?? false;
                  final isError = message['isError'] as bool? ?? false;
                  final text = message['text']?.toString() ?? '';

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(
                              Icons.pets,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        if (!isUser) const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF065F46)
                                  : isError
                                  ? Colors.red.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12),
                              ],
                            ),
                            child: isLoadingMessage
                                ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'စဉ်းစားနေပါတယ်...',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )
                                : SelectableText(
                              text,
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : isError
                                    ? Colors.red.shade800
                                    : Colors.black87,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !isLoading,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'ခွေး သို့မဟုတ် ကြောင်အကြောင်း မေးပါ...',
                        filled: true,
                        fillColor: const Color(0xFFF1F3F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                    isLoading ? Colors.grey : const Color(0xFF065F46),
                    child: IconButton(
                      icon: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: isLoading ? null : sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
