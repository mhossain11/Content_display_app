import 'dart:io';
import 'dart:typed_data';

import 'package:contentdisplay_app/screen/image_model.dart';
import 'package:contentdisplay_app/screen/slider_screen.dart';
import 'package:contentdisplay_app/widgets/custom_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../widgets/button.dart';
import 'image_gallary.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController uploadLinkController = TextEditingController();
  bool _isPicking = false;
  bool _isSaving = false;
  List<ImageModel> imageItems  = [];


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
      _isSaving = true;
      _isPicking = true;
      // 🚀 saving শুরু
    });
    try{
      final imagePicker = ImagePicker();
      final List<XFile> pickedImages = await imagePicker.pickMultiImage(); // 🔥 Multiple image
      List<ImageModel> newItems = [];

      if(pickedImages.isNotEmpty){
        for(XFile image in pickedImages){
          Uint8List bytes  = await image.readAsBytes();
          bytes =resizeImageInIsolate(bytes);
          String filename = 'content_${DateTime.now().millisecondsSinceEpoch}.jpg';
          String savePath = await saveImageToCache(bytes, filename);
          newItems.add(ImageModel(path: savePath, bytes: bytes));// 🔥 RAM cache এ রাখছেন
        }
        if (!mounted) return;
        setState(() {
          imageItems.addAll(newItems);
          _isSaving = false;
        });

      }
    }catch(e){
      print("Error picking image: $e");
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(e.toString()),
      ));
    }finally{
      if (!mounted) return;
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

    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('image_order') ?? [];

    final List<ImageModel> loadedItems = [];

    for (var file in files) {
      if (file is File && (file.path.endsWith(".jpg") || file.path.endsWith(".png"))) {
        final bytes = await file.readAsBytes();
        loadedItems.add(ImageModel(path: file.path, bytes: bytes));
      }
    }

    final reordered = <ImageModel>[];
    for (final path in savedOrder) {
      final match = loadedItems.firstWhere(
            (img) => img.path == path,
        orElse: () => ImageModel(path: '', bytes: Uint8List(0)),
      );
      if (match.path.isNotEmpty) reordered.add(match);
    }

    // Add remaining (new) images at the end
    final remaining = loadedItems.where((e) => !savedOrder.contains(e.path));
    reordered.addAll(remaining);

    if (!mounted) return;
    setState(() {
      imageItems = reordered;
     // savedImagePaths = loadedItems.map((e)=>e.path).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(

      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Image.asset('assets/images/slogo.png'),
              ),
              SizedBox(height: 30,),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: OutlinedButton.icon(
                          onPressed: (){
                            showDialog(
                                context: context,
                                builder: (context){
                                  return CustomAlertDialog(
                                    title: Column(
                                      children: [
                                        /* ElevatedButton(onPressed: (){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                          title: Column(
                                            children: [
                                              TextFormField()
                                            ],));
                                    },
                                  );
                                  // Navigator.of(context).pop();
                                }, child: Text('Link Upload')),*/
                                        SizedBox(
                                          height: 50.h,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();// <-- dialog বন্ধ
                                              pickFromExternal();
                                            },
                                            style: OutlinedButton.styleFrom(
                                                foregroundColor: Color(0xFF00B6F1),
                                                iconSize: 30,
                                                side: BorderSide(
                                                    color: Colors.blue,
                                                    width: 2
                                                )
                                            ),
                                            child: Text('Storage',style: TextStyle(fontSize: 20.sp),),
                                          ),
                                        ),
                                       
                                      ],
                                    ),
                                  );
                                });
                          },
                          label:Text('Setting',style: TextStyle(fontSize: 20.sp),),

                          style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF00B6F1),
                              iconSize: 30,

                              side: BorderSide(
                                  color: Colors.blue,
                                  width: 2
                              )
                          ),
                          icon: Image.asset('assets/icon/settings.png',
                            width: 30.w,height: 30.h,),
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: OutlinedButton.icon(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>ImageGallary(image:imageItems,)));
                          },
                          label:Text('Gallery',style: TextStyle(fontSize: 20.sp),),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF00B6F1),
                              iconSize: 30,
                              side: BorderSide(
                                  color: Colors.blue,
                                  width: 2
                              )
                          ),
                          icon: Image.asset('assets/icon/gallary.png',
                            width: 30.w,height: 30.h,),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15,),
              SizedBox(
                width: screenWidth/2,
                height: 50.h,
                child: OutlinedButton.icon(
                    onPressed: (){
                      loadCachedImages();
                      if(imageItems .isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Image is Empty.please stroe image")),
                        );
                      }else{
                        final bytesList = imageItems.map((e) => e.bytes).toList();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SliderShowScreen(image: bytesList),

                          ),
                              (Route<dynamic> route) => false, // 🔥 আগের সব route মুছে ফেলে
                        );

                      }
                    },
                  label:Text('Start Slide',style: TextStyle(fontSize: 20.sp),),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF00B6F1),
                    iconSize: 30,
                    side: BorderSide(
                      color: Colors.blue,
                      width: 2
                    )
                  ),
                  icon: Image.asset('assets/icon/start_s.png',
                  width: 30.w,height: 30.h,),
                   ),
              )
            ],
          ),

          // 🔄 Loading overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      "Saving images.",
                      style: TextStyle(color: Colors.white, fontSize: 20.sp),
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
Uint8List resizeImageInIsolate(Uint8List originalBytes) {
  final image = img.decodeImage(originalBytes); // এটা raw bytes (originalBytes) কে ডিকোড করে image object বানায়। এটি package:image/image.dart থেকে আসা ফাংশন।
  if (image == null) return originalBytes;
  final resized = img.copyResize(image, width: 600); //এটা একটি function, যেটা image bytes (Uint8List) ইনপুট হিসেবে নেয়। যদি width = 600 মানে হচ্ছে যদি ইউজার কোনো width না দেয়, তাহলে default width হবে 600px।
  return Uint8List.fromList(img.encodeJpg(resized));
}