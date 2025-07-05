

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          ElevatedButton(onPressed: (){}, child: Text('Setting')),
          ElevatedButton(onPressed: (){}, child: Text('images')),
          ElevatedButton(onPressed: (){}, child: Text('Start Slide')),
        ],
      ),
    );
  }
}
