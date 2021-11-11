import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:splashscreen/splashscreen.dart';
import 'package:tflite/tflite.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: SplashScreen(
            seconds: 5,
            navigateAfterSeconds: TakePictureScreen(camera: firstCamera),
            image: new Image.asset('assets/drskin.png'),
            photoSize: 250,
            backgroundColor: Colors.white,
            styleTextUnderTheLoader: new TextStyle(),
            loaderColor: Colors.brown[400])),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    loadModel();

    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() async {
    // Dispose of the controller when the widget is disposed.
    await Tflite.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // To enter FullScreenMode.EMERSIVE_STICKY,
    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);

    return Scaffold(
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      appBar: AppBar(
        title: Image.asset('assets/drskin.png'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),

      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[400],

        hoverColor: Colors.brown,

        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomAppBar(
          child: Container(
        height: 10,
      )),
    );
  }

  Future loadModel() async {
    Tflite.close();
    String? res;
    res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
    print(res);
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      appBar: AppBar(
        title: Image.asset('assets/drskin.png', fit: BoxFit.cover),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
          onPressed: _MyAppState().selectImage(),
          child: const Icon(Icons.check_box)),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late File _image;
  late List _results;
  final String imagePath = DisplayPictureScreen(
    imagePath: '',
  ).imagePath;

  selectImage() {
    // pick image and...
    var image = (File(imagePath));
    // Perform image classification on the selected image.
    imageClassification(image);
  }

  imageClassification(File image) async {
    // Run tensorflowlite image classification model on the image
    final List? results = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.1,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = results!;
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: implement build
    throw UnimplementedError();
  }
}

class MessageState<T extends StatefulWidget> extends State<T> {
  late String _message;

  /// Setter for the message variable
  set setMessage(String message) => setState(() {
        _message = message;
      });

  /// Getter for the message variable
  String get getMessage => _message;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

/*class LoadingScreen extends StatefulWidget {
  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends MessageState<LoadingScreen> {
  @override
  //Widget build(BuildContext context) {}
}
*/