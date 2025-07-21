
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dialog.dart';
import 'image_model.dart';

class ImageGallary extends StatefulWidget {
  const ImageGallary({super.key, required this.image});
final List<ImageModel> image;

  @override
  State<ImageGallary> createState() => _ImageGallaryState();
}

class _ImageGallaryState extends State<ImageGallary> {
  late List<ImageModel> imageList;

  @override
  void initState() {
    super.initState();
    imageList = List.from(widget.image); // কপি নিচ্ছি
  }

  Future<void> deleteImage(ImageModel imageModel) async {
    final file = File(imageModel.path);
    if (await file.exists()) {
      await file.delete();
      if (!mounted) return;
      setState(() {
        imageList.removeWhere((e) => e.path == imageModel.path);// UI থেকে remove
        widget.image.removeWhere((e) => e.path == imageModel.path); // Parent list থেকেও সরাও
      });
    }
  }
  Future<void> saveImageOrder(List<ImageModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final paths = list.map((e) => e.path).toList();
    await prefs.setStringList('image_order', paths);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gallery"),
      actions: [
        
        IconButton(onPressed: ()async{
          showDialog(
            context: context,
            builder: (context)=> CustomDialog(
                title: 'Delete All Image',
                content: 'Are you sure you want to delete all images?',
                onPressedOne: ()=>Navigator.pop(context),
              onPressedTwo: () async{
                final localContext = context;
                final dir = await getApplicationDocumentsDirectory();
                final files = dir.listSync();

                for (var file in files) {
                  if (file is File && (file.path.endsWith(".jpg") || file.path.endsWith(".png"))) {
                    await file.delete(); // 🔥 ফাইল মুছে ফেলো
                  }
                }
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('image_order');

                if (!mounted) return;
                setState(() {
                  imageList.clear();
                  widget.image.clear();
                });

                if (localContext.mounted) {
                  ScaffoldMessenger.of(localContext).showSnackBar(
                    const SnackBar(
                      content: Text("🧹 All cached images deleted"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(localContext, true);
                }

              },
              childTitleOne: 'Cancel',
              childTitleTwo: 'Yes',),
          );
        }, icon: Icon(Icons.cleaning_services_rounded))
        ],
      ),
      body: imageList.isEmpty
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Image(image: AssetImage('assets/images/empty_file.png'))),
              Center(child: Text("Ouhh...it's empty in here!",style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold))),
            ],
          ) :
      ReorderableGridView.count(
          onReorder: (oldIndex,newIndex){
            final path = imageList.removeAt(oldIndex);
            if (!mounted) return;
            setState(() {
              imageList.insert(newIndex, path);
              widget.image
                ..clear()
                ..addAll(List.from(imageList));
            });
            saveImageOrder(imageList); // ✅ Save updated order
          },
          childAspectRatio: 1.5,
          crossAxisCount: 3,
        children: imageList.map((model) {
          return Stack(
            key: ValueKey(model.path),
            children: [
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(model.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context)=> CustomDialog(
                        title: 'Delete Image',
                        content: 'Are you sure you want to delete image?',
                        onPressedOne: ()=>Navigator.pop(context),
                        onPressedTwo: () async{
                          deleteImage(model);
                          Navigator.pop(context, true);
                        },
                        childTitleOne: 'Cancel',
                        childTitleTwo: 'Delete',),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ),
              ),
            ],
          );

        }).toList(),

      )

    );
  }
}

