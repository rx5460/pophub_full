import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onPressed;

  const AlertDialogWidget(
      {super.key,
      required this.title,
      required this.content,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // 원하는 radius 값으로 설정
      ),
      title: Center(child: Text(title)),
      content: SingleChildScrollView(
        child: Center(child: Text(content)),
      ),
      actions: <Widget>[
        Center(
          child: OutlinedButton(
            onPressed: onPressed,
            child: const Text('확인'),
          ),
        ),
      ],
    );
  }
}
