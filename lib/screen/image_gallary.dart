
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageGallary extends StatefulWidget {
  const ImageGallary({super.key, required this.image});
final List<String> image;

  @override
  State<ImageGallary> createState() => _ImageGallaryState();
}

class _ImageGallaryState extends State<ImageGallary> {
  late List<String> imageList;

  @override
  void initState() {
    super.initState();
    imageList = List.from(widget.image); // কপি নিচ্ছি
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        imageList.remove(path); // UI থেকে remove
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Save Image")),
      body: imageList.isEmpty
          ? const Center(child: Text('List is Empty')) :
      GridView.builder(
          itemCount: imageList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemBuilder: (context, index) {
            final imagePath = imageList[index];

            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imagePath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _confirmDelete(imagePath),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete, size: 18, color: Colors.red),
                    ),
                  ),
                ),
              ],
            );
          }),

    );
  }

  void _confirmDelete(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Image"),
        content: const Text("Are you sure you want to delete this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              deleteImage(path);
              setState(() {
                widget.image.remove(path);
              });
              Navigator.pop(context,true); // pop with result = true
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

