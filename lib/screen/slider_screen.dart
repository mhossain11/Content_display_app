import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';




class SliderShowScreen extends StatefulWidget {
   SliderShowScreen({super.key,required this.image});
  List<String> image;

  @override
  _SliderShowScreenState createState() => _SliderShowScreenState();
}

class _SliderShowScreenState extends State<SliderShowScreen> {

  final CarouselSliderController _controller = CarouselSliderController();
  bool _isAutoPlay = true;
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: []);

    Timer.periodic(Duration(seconds: 10), (timer){
      setState(() {
        _isAutoPlay = true;
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    print('0:$_isAutoPlay');
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
      setState(() {
        _isAutoPlay = !_isAutoPlay;
      });
      print(_isAutoPlay);
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Cancel
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    exit(0); // Exit the app
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
        },
        child: SafeArea(
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: CarouselSlider(
              items:widget.image.map((url) {

                return Image.file(
                  File(url),
                  fit: BoxFit.cover,
                  height: screenHeight,
                );
              }).toList(),
              carouselController: _controller,
              options: CarouselOptions(
                autoPlay: _isAutoPlay,
                enlargeCenterPage: false,
                viewportFraction: 1.0,
                height: screenHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


