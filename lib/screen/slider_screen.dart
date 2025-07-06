import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';





class SliderShowScreen extends StatefulWidget {
   SliderShowScreen({super.key,required this.image});
  List<Uint8List> image;

  @override
  _SliderShowScreenState createState() => _SliderShowScreenState();
}

class _SliderShowScreenState extends State<SliderShowScreen> {

  final CarouselSliderController _controller = CarouselSliderController();
  bool _isAutoPlay = true;

  late List<MemoryImage> memoryImages;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: []); //status bar hide

    // Convert Uint8List to MemoryImage only once (cached in RAM)
    memoryImages = widget.image.map((bytes) => MemoryImage(bytes)).toList();

    WakelockPlus.enable(); // 🔥 এটা screen lock / dim হতে দিবে না
    Timer.periodic(Duration(seconds: 10), (timer){
      setState(() {
        _isAutoPlay = true;
      });
    });

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
              items:memoryImages.map((url) {

                return Image(
                  image: url,
                  fit: BoxFit.cover,
                  height: screenHeight,
                  gaplessPlayback: true,// ✅ পুরনো ফ্রেম সরিয়ে না দিয়ে একই ফ্রেম ব্যবহার করে

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


  @override
  void dispose() {
    WakelockPlus.disable(); // ✅ পরবর্তী screen গেলে screen lock allow করতে চাইলে
    super.dispose();
  }
}


