import 'package:flutter/material.dart';

class ShowDialogs extends StatelessWidget {
   ShowDialogs({super.key,
    required this.content,
     this.cancelText= 'Cancel',
    this.confirmText = 'OK',
    required this.onConfirm,

  });
  String content;
  String cancelText ;
  String confirmText ;
  VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(''),
      content: Text(content),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: Text(cancelText)),
        TextButton(onPressed: (){
          if (onConfirm != null) {
            onConfirm!(); // custom action
          }
        }, child: Text(confirmText)),
      ],
    );
  }
}

