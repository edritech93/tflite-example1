import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Masker Detection',
      home: const HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLoading = false;
  late File fileImage;
  final listOutputs = [];

  @override
  void initState() {
    isLoading = true;
    loadModel().then((value) {
      setState(() => isLoading = false);
    });
    super.initState();
  }

  Future loadModel() async {
    await Tflite.loadModel(
      model: 'assets/mobilenet_v1_1.0_224_quant.tflite',
      labels: 'assets/labels_mobilenet_quant_v1_224.txt',
    );
  }

  void pickImage(ImageSource imageSource) async {
    var image = await ImagePicker().pickImage(source: imageSource);
    if (image == null) {
      return null;
    }
    setState(() {
      isLoading = true;
      fileImage = File(image.path);
    });
    processImage(fileImage);
  }

  void processImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      isLoading = false;
      listOutputs.clear();
      listOutputs.addAll(output!);
      debugPrint('outputs: $listOutputs');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Masker Detection',
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  // fileImage == null ? Container() : Image.file(fileImage),
                  // const SizedBox(height: 16),
                  // listOutputs != null
                  //     ? Text(
                  //         '${listOutputs[0]['label']}'
                  //             .replaceAll(RegExp(r'[0-9]'), ''),
                  //         style: TextStyle(
                  //           fontSize: 20,
                  //           background: Paint()..color = Colors.white,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       )
                  //     : const Text('Upload your image'),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.camera),
            tooltip: 'Take Picture From Camera',
            onPressed: () => pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            child: const Icon(Icons.image),
            tooltip: 'Take Picture From Gallery',
            onPressed: () => pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
