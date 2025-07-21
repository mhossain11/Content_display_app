import 'package:flutter/material.dart';

class NeumorphismButton  extends StatelessWidget {
   NeumorphismButton ({super.key , this.height =100,this.wight=100});

  bool isPressed = true;
  double height;
  double wight;



  @override
  Widget build(BuildContext context) {
    Offset distance = isPressed? Offset(10, 10): Offset(28, 28);
    double blur =isPressed?5.0: 30.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Color(0xFFE7ECEF),
        boxShadow: [
          BoxShadow(
            blurRadius: blur,
            offset: distance,
            color: Colors.white,
          ),
          BoxShadow(
            blurRadius: blur,
            offset: distance,
            color: Color(0xFFA7A9AF),
          )
        ]
      ),
      child: SizedBox(height: height,width: wight,),
    );
  }
}
