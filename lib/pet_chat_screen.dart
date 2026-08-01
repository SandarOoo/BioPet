import 'package:flutter/material.dart';
import 'package:biopet/services/chat_service.dart';
import 'package:biopet/main_navigation.dart';
class PetChatScreen extends StatefulWidget {
  const PetChatScreen({super.key});

  @override
  State<PetChatScreen> createState() => _PetChatScreenState();
}

class _PetChatScreenState extends State<PetChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [
    {
      "text": "Hi 🐾 I'm BioPet AI\nAsk me anything about your pet!",
      "isUser": false
    }
  ];

  bool isLoading = false;

  void sendMessage() async {
    if (controller.text.trim().isEmpty || isLoading) return;

    String userText = controller.text.trim();


    setState(() {
      messages.add({
        "text": userText,
        "isUser": true,
      });
      isLoading = true;
    });

    controller.clear();


    _scrollToBottom();

    try {

      setState(() {
        messages.add({
          "text": "✍️ Thinking...",
          "isUser": false,
          "isLoading": true,
        });
      });
      void sendMessage() async {
        if (controller.text.trim().isEmpty || isLoading) return;

        String userText = controller.text.trim();

        setState(() {
          messages.add({
            "text": userText,
            "isUser": true,
          });
          isLoading = true;
        });

        controller.clear();
        _scrollToBottom();

        try {
          // ✅ Loading Message
          setState(() {
            messages.add({
              "text": "✍️ Thinking...",
              "isUser": false,
              "isLoading": true,
            });
          });
          _scrollToBottom();


          String aiReply = await ChatService.sendMessage(userText);

          setState(() {
            messages.removeWhere((msg) => msg["isLoading"] == true);
            messages.add({
              "text": aiReply,
              "isUser": false,
            });
            isLoading = false;
          });
          _scrollToBottom();
        } catch (e) {
          setState(() {
            messages.removeWhere((msg) => msg["isLoading"] == true);
            messages.add({
              "text": "⚠️ Error: ${e.toString()}",
              "isUser": false,
              "isError": true,
            });
            isLoading = false;
          });
          _scrollToBottom();
        }
      }

      _scrollToBottom();


      String aiReply = await ChatService.sendMessage(userText);


      setState(() {
        messages.removeWhere((msg) => msg["isLoading"] == true);
        messages.add({
          "text": aiReply,
          "isUser": false,
        });
        isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {

      setState(() {
        messages.removeWhere((msg) => msg["isLoading"] == true);
        messages.add({
          "text": "⚠️ Sorry, something went wrong. Please try again.",
          "isUser": false,
          "isError": true,
        });
        isLoading = false;
      });
      _scrollToBottom();
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.pets),
            SizedBox(width: 8),
            Text(
              "BioPet AI",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index]["isUser"] ?? false;
                bool isLoadingMsg = messages[index]["isLoading"] ?? false;
                bool isError = messages[index]["isError"] ?? false;
                String text = messages[index]["text"] ?? "";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                      const SizedBox(width: 8),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                // blurRadius: 8,
                              ),
                            ],
                          ),
                          child: isLoadingMsg
                              ?
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
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
                                "Thinking...",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                              : Text(
                            text,
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : isError
                                  ? Colors.red.shade800
                                  : Colors.black87,
                              fontSize: 15,
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
          // ✅ Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E7),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: "Ask about your pet...",
                      filled: true,
                      fillColor: const Color(0xffF1F3F6),
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
                  backgroundColor: isLoading ? Colors.grey : Color(0xFF065F46),
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
                        : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: isLoading ? null : sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




