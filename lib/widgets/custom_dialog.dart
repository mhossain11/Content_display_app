import 'package:flutter/material.dart';

class CustomDialogs extends StatelessWidget {
  CustomDialogs({super.key,
    required this.title,
     this.content,
     this.actions,


  });
  Widget title;
  Widget? content;
  List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content:content,
      actions: actions,
    );
  }
}

