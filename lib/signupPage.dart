import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallpaperapp/loginPage.dart';

class signupPage extends StatefulWidget {
  const signupPage({super.key});

  @override
  State<signupPage> createState() => _signupPageState();
}

class _signupPageState extends State<signupPage> {
  var _fkey = GlobalKey<FormState>();
  var _name = TextEditingController();
  var _email = TextEditingController();
  var _psd = TextEditingController();
  var _cpsd = TextEditingController();
  bool isDarkMode = false;
  Color primaryColor = Colors.deepPurple;

  void funTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void funColor(Color value) {
    setState(() {
      primaryColor = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Form(
            key: _fkey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                      labelText: "USER NAME", border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 20,
                ),
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
                TextFormField(
                  controller: _cpsd,
                  decoration: InputDecoration(
                      labelText: "CONFIRM PASSWORD",
                      border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    var username = _name.text.toString();
                    var email = _email.text.toString();
                    var password = _psd.text.toString();
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password)
                        .then(
                      (value) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc(value.user!.uid)
                            .set({
                          "username": username,
                          "email": email,
                          "password": password,
                          "status": true,
                          "profile_img":
                              "https://www.pngall.com/wp-content/uploads/12/Avatar-Profile-PNG-Images.png"
                        }).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("User Signed In"),
                            showCloseIcon: true,
                          ));
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => loginPage(
                              changeColor: funColor,
                              changeTheme: funTheme,
                            ),
                          ));
                        });
                      },
                    );
                  },
                  child: Text("SIGN UP"),
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
                    Text("Already A User?"),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => loginPage(
                              changeColor: funColor,
                              changeTheme: funTheme,
                            ),
                          ));
                        },
                        child: Text("Login"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
