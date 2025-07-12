
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  CustomDialog({super.key,
    required this.title,
     this.content ='',
     this.actions,
    required this.onPressedOne,
    required this.onPressedTwo,
    required this.childTitleOne,
    required this.childTitleTwo});
  String title;
  String content;
  List<Widget>? actions;
  void Function() onPressedOne;
  void Function() onPressedTwo;
  String childTitleOne;
  String childTitleTwo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content:Text(content),
      actions: [
        TextButton(
          onPressed: onPressedOne,
          child: Text(childTitleOne),
        ),
        TextButton(
          onPressed: onPressedTwo,
          child: Text(childTitleTwo),
        ),
      ],
    );
  }
}




class CustomAlertDialog extends StatelessWidget {
   CustomAlertDialog({super.key,required this.title});

  Widget title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
    );
  }
}


