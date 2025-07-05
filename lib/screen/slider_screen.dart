import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';




class SliderShowScreen extends StatefulWidget {
  const SliderShowScreen({super.key});

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

  List<String> imageUrls = [
    'https://images.pexels.com/photos/1212487/pexels-photo-1212487.jpeg',
    'https://images.pexels.com/photos/1366630/pexels-photo-1366630.jpeg',
    'https://images.pexels.com/photos/40465/pexels-photo-40465.jpeg',
    'https://images.pexels.com/photos/1535162/pexels-photo-1535162.jpeg'
  ];

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
        child: SafeArea(
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: CarouselSlider(
              items: imageUrls.map((url) {

                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  height: screenHeight,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
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


