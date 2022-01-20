import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:tflite/tflite.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'profile.dart';
import 'login.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  static late File _image;
  static late List _output;
  final picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    //initS is the first function that is executed by default when this class is called
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    //dis function disposes and clears our memory
    super.dispose();
    Tflite.close();
  }

  classifyImage(File image) async {
    //this function runs the model on the image
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 36, //the amout of categories our neural network can predict
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output as List<dynamic>;
      _loading = false;
    });
  }

  loadModel() async {
    //this function loads our model
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  pickImage() async {
    //this function to grab the image from camera
    var image = await picker.getImage(source: ImageSource.camera);
    // ignore: unnecessary_null_comparison
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  pickGalleryImage() async {
    //this function to grab the image from gallery
    var image = await picker.getImage(source: ImageSource.gallery);
    // ignore: unnecessary_null_comparison
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewGradientAppBar(
        title: Text('Dr. Skin',
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 25)),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.blueGrey,
          ],
        ),
        // automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        decoration: new BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white,
            Colors.brown,
          ],
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: _loading == false
                  ? null //show nothing if picture selected
                  : Image(image: AssetImage("assets/landing.png")),
              margin: EdgeInsets.only(bottom: 25),
            ),
            Container(
              child: _loading == false
                  ? null //show nothing if picture selected
                  : Text(
                      'Please Submit an Image for Diagnosis',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
              margin: EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(105.0),
              ),
            ),
            Container(
              child: Center(
                child: _loading == true
                    ? null //show nothing if no picture selected
                    : Container(
                        child: Column(
                          children: [
                            Container(
                              height: 350,
                              width: 300,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.file(
                                  _image,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Divider(
                              height: 25,
                              thickness: 1,
                            ),
                            // ignore: unnecessary_null_comparison
                            _output != null
                                ? Text(
                                    'Probable Diagnosis: ${_output[0]['label']}.',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  )
                                : Container(),
                            Divider(
                              height: 25,
                              thickness: 1,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _buildPopupDialog(context),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 200,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 17),
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey[600],
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  'Approve',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pickImage();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 230,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 17),
                                decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  'Take new photo',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                margin: EdgeInsets.only(top: 5),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pickGalleryImage()();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 230,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 17),
                                decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  'Pick From Gallery',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                margin: EdgeInsets.only(top: 5),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
            ),
            Container(
              child: _loading == false
                  ? null //show nothing if a picture is selected
                  : Column(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 200,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 17),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey[600],
                                borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              'Take A Photo',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: pickGalleryImage,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 200,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 17),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey[600],
                                borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              'Pick From Gallery',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(''),
              decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: AssetImage("assets/drskin.png"),
                      fit: BoxFit.contain)),
            ),
            ListTile(
              tileColor: Colors.white70,
              leading: Icon(Icons.logout),
              title: const Text('Log Out', style: TextStyle(fontSize: 20)),
              onTap: () async {
                // Update the state of the app
                // ...
                // Then close the drawer
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //Upload Images to firebase
  static Future uploadImageToFirebase(BuildContext context) async {
    String fileName = '${_output[0]['label']}';
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
        );
  }
}

class Info extends StatefulWidget {
  @override
  State<Info> createState() => _Info();
}

class _Info extends State<Info> {
  String information = '';
  List _output = _HomeState._output;

  loadAsset() async {
    String response =
        await rootBundle.loadString('assets/${_output[0]['label']}.txt');

    setState(() {
      information = response;
    });
  }

  @override
  void initState() {
    loadAsset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NewGradientAppBar(
          title: Text('Diagnosis Information',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey,
              Colors.white,
            ],
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white,
                  Colors.brown,
                ],
              )),
            ),
            Card(
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            AssetImage('assets/${_output[0]['label']}.jpg'))),
              ),
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Center(
                  child: Text(
                information,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.5,
                ),
              )),
            ),
          ],
        ));
  }
}

Widget _buildPopupDialog(BuildContext context) {
  return new AlertDialog(
    title: Text(
        'If you wish to save the image in our systems, click save. Otherwise you can ignore',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blueGrey)),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Info()),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width - 120,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            decoration: BoxDecoration(
                color: Colors.blueGrey[600],
                borderRadius: BorderRadius.circular(15)),
            child: Text(
              'Learn More',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _HomeState.uploadImageToFirebase(context);
            Fluttertoast.showToast(
                msg: "Image saved successfully. Thank You.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          },
          child: Container(
              width: MediaQuery.of(context).size.width - 120,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
              decoration: BoxDecoration(
                  color: Colors.blueGrey[600],
                  borderRadius: BorderRadius.circular(15)),
              child: Text(
                'Save Image',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              margin: EdgeInsets.only(top: 10.0)),
        ),
      ],
    ),
    actions: <Widget>[
      new FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        textColor: Theme.of(context).primaryColor,
        child: Text('Close'),
      ),
    ],
  );
}
