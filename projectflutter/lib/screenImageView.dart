import 'dart:convert';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  final String base64Image;
  final BuildContext context;
  ImageViewScreen(this.context, this.base64Image);

  Future<void> _downloadImage() async {
    final imageBytes = base64Decode(base64Image);
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(imageBytes));
    if (result['isSuccess']) {
      // Image saved successfully
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Image saved successfully')),
      );
    } else {
      // Image save failed
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Failed to save image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(base64Image);
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the chat screen
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _downloadImage, // Download the image
          ),
        ],
      ),
      body: Center(
        child: Image.memory(imageBytes),
      ),
    );
  }
}