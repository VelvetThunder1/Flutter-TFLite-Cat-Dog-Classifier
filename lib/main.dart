// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerWidget(),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? file;
  var result = "";

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_cat_dog.tflite",
      labels: "assets/labels1.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      image = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        file = File(image!.path);
      });
      classifyImage(file!);
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
  }

  Future classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      result = output![0]['label'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar(
            title: Text('Cat or Dog Classifier'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          SizedBox(
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () => _pickImage(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Select Image'),
            ),
          ),
          if (image != null)
            Container(
                padding: const EdgeInsets.all(20),
                child: Image.file(
                  File(image!.path),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ))
          else
            SizedBox(
              height: 240,
              child: Center(
                  child: Text(
                'No image selected',
                style: TextStyle(fontSize: 16),
              )),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Result:",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Text(
            result,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
