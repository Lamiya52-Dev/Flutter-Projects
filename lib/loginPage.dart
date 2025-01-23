import 'package:auth_buttons/auth_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaperapp/adminPage.dart';
import 'package:wallpaperapp/homePage.dart';
import 'package:wallpaperapp/signupPage.dart';

class loginPage extends StatefulWidget {
  final Function changeTheme;
  final Function changeColor;

  const loginPage(
      {super.key, required this.changeTheme, required this.changeColor});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  var _fkey = GlobalKey<FormState>();
  var _psd = TextEditingController();
  var _email = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  void checklogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("islogin")) {
      if (prefs.containsKey("isadmin")) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => adminPage(),
        ));
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => homePage(
            changeColor: widget.changeColor,
            changeTheme: widget.changeTheme,
          ),
        ));
      }
    }
  }

  @override
  void initState() {
    FlutterNativeSplash.remove();
    checklogin();
    super.initState();
  }

  Future<void> signup(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      UserCredential result = await auth.signInWithCredential(authCredential);
      User? user = result.user;
      FirebaseFirestore.instance.collection("Users").doc(user!.uid).get().then(
        (value) async {
          if (value != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("uid", user.uid);
            prefs.setString("username", user.displayName.toString());
            prefs.setString("email", user.email.toString());
            prefs.setString("purl", user.photoURL.toString());
            prefs.setBool("islogin", true);
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => homePage(
                changeColor: widget.changeColor,
                changeTheme: widget.changeTheme,
              ),
            ));
          } else {
            FirebaseFirestore.instance.collection("Users").doc(user!.uid).set({
              "username": user.displayName,
              "email": user.email,
              "password": null,
              "status": true,
              "profile_img": "${user.photoURL}"
            }).then((value) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("uid", user.uid);
              prefs.setString("username", user.displayName.toString());
              prefs.setString("email", user.email.toString());
              prefs.setString("purl", user.photoURL.toString());
              prefs.setBool("islogin", true);
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => homePage(
                  changeColor: widget.changeColor,
                  changeTheme: widget.changeTheme,
                ),
              ));
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  var email = _email.text.toString();
                  var password = _psd.text.toString();
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password)
                      .then(
                    (value) async {
                      if (email == "admin@wallsbynode.com") {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setBool("isadmin", true);
                        prefs.setBool("islogin", true).then(
                          (value) {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => adminPage(),
                            ));
                          },
                        );
                      } else {
                        var uid = value.user!.uid;
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc(uid)
                            .get()
                            .then((value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString("uid", value.id);
                          prefs.setString("username", value["username"]);
                          prefs.setString("email", value["email"]);
                          prefs.setString("purl", value["profile_img"]);
                          prefs.setBool("islogin", true);
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => homePage(
                              changeColor: widget.changeColor,
                              changeTheme: widget.changeTheme,
                            ),
                          ));
                        });
                      }
                    },
                  );
                },
                child: Text("LOGIN"),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 140,
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("OR"),
                  ),
                  Container(
                    width: 140,
                    child: Divider(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New Here?"),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => signupPage(),
                          ),
                        );
                      },
                      child: Text("Signup"))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 140,
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("OR"),
                  ),
                  Container(
                    width: 140,
                    child: Divider(),
                  ),
                ],
              ),
              GoogleAuthButton(
                onPressed: () {
                  signup(context);
                },
                style: AuthButtonStyle(
                  width: MediaQuery.of(context).size.width,
                  elevation: 0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
