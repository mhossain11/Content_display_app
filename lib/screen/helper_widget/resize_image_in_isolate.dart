
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List resizeImageInIsolate(Uint8List originalBytes) {
  final image = img.decodeImage(originalBytes); // এটা raw bytes (originalBytes) কে ডিকোড করে image object বানায়। এটি package:image/image.dart থেকে আসা ফাংশন।
  if (image == null) return originalBytes;
  final resized = img.copyResize(image, width: 600); //এটা একটি function, যেটা image bytes (Uint8List) ইনপুট হিসেবে নেয়। যদি width = 600 মানে হচ্ছে যদি ইউজার কোনো width না দেয়, তাহলে default width হবে 600px।
  return Uint8List.fromList(img.encodeJpg(resized));
}