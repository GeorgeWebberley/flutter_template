import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/widgets/dismiss_keyboard_on_swipe.dart';

class TypingInput extends StatelessWidget {
  const TypingInput({
    super.key,
    required this.sendMessage,
  });

  final void Function(String) sendMessage;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return DismissKeyboardOnSwipe(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (text) {
                  sendMessage(text);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () {
                sendMessage(_controller.text);
                _controller.clear();
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }
}
