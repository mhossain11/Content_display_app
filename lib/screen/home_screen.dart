

import 'dart:io';
import 'dart:typed_data';

import 'package:contentdisplay_app/screen/slider_screen.dart';
import 'package:contentdisplay_app/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'image_gallary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController uploadLinkController = TextEditingController();
  bool _isPicking = false;
  bool _isSaving = false;
  List<String> savedImagePaths = [];
  List<Uint8List> cachedImageBytesList = [];

  @override
  void initState() {
    super.initState();
    loadCachedImages();
  }
//এটা একটি helper function যা Uint8List (ছবির raw bytes) কে internal storage এ .jpg ফাইল হিসেবে save করে এবং সেই path return করে।
  Future<String> saveImageToCache(Uint8List bytes, String filename) async {
    final dir = await getApplicationDocumentsDirectory(); // বা getApplicationDocumentsDirectory()
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
      print('LocalStore:${file.path.toString()}');
    return file.path;
  }


  //🔸 গ্যালারি থেকে ছবি নেওয়ার জন্য image_picker ব্যবহার করা হচ্ছে
  // 🔸 ছবি নেওয়ার পর Uint8List আকারে read করে saveImageToCache এর মাধ্যমে internal memory তে সেভ করা হচ্ছে
  // 🔸 তারপর সেই path savedImagePaths লিস্টে যোগ হচ্ছে
  Future<void> pickFromExternal() async{
    if (_isPicking || _isSaving) return;


    setState(() {
      _isPicking = true;
      // 🚀 saving শুরু
    });
    try{
      final imagePicker = ImagePicker();
      final List<XFile>? pickedImages = await imagePicker.pickMultiImage(); // 🔥 Multiple image
     // final pickImage = await imagePicker.pickImage(source: ImageSource.gallery);

      if(pickedImages != null && pickedImages.isNotEmpty){
        for(XFile image in pickedImages){
          Uint8List bytes  = await image.readAsBytes();
          String filename = 'content_${DateTime.now().millisecondsSinceEpoch}.jpg';
          String savePath = await saveImageToCache(bytes, filename);
          // Delay দিয়ে filename duplication এড়াতে পারেন
          await Future.delayed(Duration(milliseconds: 300));
          setState(() {
            _isSaving = true;
            savedImagePaths.add(savePath);
            cachedImageBytesList.add(bytes); // 🔥 RAM cache এ রাখছেন

          });
        }

      }
    }catch(e){
      print("Error picking image: $e");
    }finally{
      setState(() {
        _isPicking = false;
        _isSaving = false; // ✅ saving শেষ
      });
    }
  }

//অ্যাপ চালু হলে (initState) থেকে call হয়ে saved image ফাইলগুলো load করে
  Future<void> loadCachedImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> files = dir.listSync();

    final List<String> paths = [];
    final List<Uint8List> imageCacheBytes = [];

    for (var file in files) {
      if (file is File && (file.path.endsWith(".jpg") || file.path.endsWith(".png"))) {
        paths.add(file.path);
        imageCacheBytes.add(await file.readAsBytes());
      }
    }

    setState(() {
      savedImagePaths = paths; // পুরাতন ছবি লোড
      cachedImageBytesList = imageCacheBytes;
    });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: ElevatedButton(onPressed: (){

                showDialog(
                    context: context,
                    builder: (context){
                      return  AlertDialog(
                        title: Column(
                          children: [
                            ElevatedButton(onPressed: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogs(
                                      title: Column(
                                        children: [
                                          TextFormField()
                                        ],));
                                },
                              );
                              // Navigator.of(context).pop();
                            }, child: Text('Link Upload')),
                            ElevatedButton(onPressed: (){
                              Navigator.of(context).pop();// <-- dialog বন্ধ
                              pickFromExternal();
                            }, child: Text('Storage')),
                          ],
                        ),
                      );
                    });

              }, child: Text('Setting'))),
              Center(child: ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>ImageGallary(image:savedImagePaths ,)));
              }, child: Text('images'))),
              Center(child: ElevatedButton(onPressed: (){
                if(savedImagePaths .isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Image is Empty.please stroe image")),
                  );
                }else{
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SliderShowScreen(image: cachedImageBytesList),
                    ),
                        (Route<dynamic> route) => false, // 🔥 আগের সব route মুছে ফেলে
                  );

                }
              }, child: Text('Start Slide'))),
            ],
          ),

          // 🔄 Loading overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Saving images...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),


    );
  }
}
