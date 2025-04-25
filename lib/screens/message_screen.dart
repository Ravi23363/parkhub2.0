import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  final List messages;
  final ScrollController scrollController;

  const MessagesScreen({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  @override
  void didUpdateWidget(covariant MessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to the bottom whenever messages update
    if (widget.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.separated(
      controller: widget.scrollController,
      itemBuilder: (context, index) {
        bool isUserMessage = widget.messages[index]['isUserMessage'];

        return Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment:
                isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(isUserMessage ? 0 : 20),
                    topLeft: Radius.circular(isUserMessage ? 20 : 0),
                  ),
                  color:
                      isUserMessage
                          ? const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ) // user msg bg
                          : const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ), // bot msg bg
                ),
                constraints: BoxConstraints(maxWidth: w * 2 / 3),
                child: Text(
                  widget.messages[index]['message'].text.text[0],
                  style: TextStyle(
                    color:
                        isUserMessage
                            ? Colors
                                .black // user msg text color
                            : Colors.black, // bot msg text color
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder:
          (_, i) => const Padding(padding: EdgeInsets.only(top: 10)),
      itemCount: widget.messages.length,
    );
  }
}
