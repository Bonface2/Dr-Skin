import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NewGradientAppBar(
          title: Text(
            "Profile",
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 25),
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blueGrey,
            ],
          ),
          // automaticallyImplyLeading: false,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: ListView(
          addAutomaticKeepAlives: false,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Container(
                child: Text(
                  'Cases',
                  style: TextStyle(
                      fontSize: 50,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                margin: EdgeInsets.only(left: 145.0, right: 145.0, top: 50.0),
              ),
            ),
            Card(
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/drskin.png'))),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Normal Skin',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
            ),
          ],
        ));
  }
}
