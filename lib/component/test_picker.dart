import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(TestPicker());
}

class TestPicker extends StatefulWidget {
  const TestPicker({super.key});

  @override
  _TestPickerState createState() => _TestPickerState();
}

class _TestPickerState extends State<TestPicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Image Picker Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? Text('No image selected')
                  : Image.file(File(_image!.path)),
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Pick Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
