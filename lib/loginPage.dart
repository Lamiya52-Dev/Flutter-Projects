import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ntlwallpaper/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  var _fkey = GlobalKey<FormState>();
  var _psd = TextEditingController();
  var _email = TextEditingController();

  void checklogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("islogin")) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => homePage(),
      ));
    }
  }

  @override
  void initState() {
    FlutterNativeSplash.remove();
    checklogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Form(
        key: _fkey,
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              decoration: InputDecoration(
                  labelText: "Email ID", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _psd,
              decoration: InputDecoration(
                  labelText: "PASSWORD", border: OutlineInputBorder()),
            ),
            ElevatedButton(
                onPressed: () {
                  var email = _email.text.toString();
                  var password = _psd.text.toString();

                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password)
                      .then(
                    (value) {
                      var uid = value.user!.uid;
                      FirebaseFirestore.instance
                          .collection("NAMES")
                          .doc(uid)
                          .get()
                          .then((value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString("uid", value.id);
                        prefs.setString("username", value["username"]);
                        prefs.setString("email", value["email"]);
                        prefs.setBool("islogin", true);
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => homePage(),
                        ));
                      });
                    },
                  );
                },
                child: Text("LOGIN"))
          ],
        ),
      ),
    );
  }
}
