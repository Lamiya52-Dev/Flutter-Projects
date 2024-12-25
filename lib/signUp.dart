import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  var _fkey = GlobalKey<FormState>();
  var _name = TextEditingController();
  var _email = TextEditingController();
  var _psd = TextEditingController();
  var _cpsd = TextEditingController();


  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SIGN UP")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _fkey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                    labelText: "NAME", border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                    labelText: "EMAIL ID", border: OutlineInputBorder()),
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
                            .collection("NAMES")
                            .doc(value.user!.uid)
                            .set({
                          "username": username,
                          "email": email,
                          "password": password,
                        }).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Signed up"),
                          showCloseIcon: true,
                          action: SnackBarAction(
                            onPressed: (){},label: "OKAY",
                          ),),);
                        },);
                      },
                    );
                  },
                  child: Text("Signed up"))
            ],
          ),
        ),
      ),
    );
  }
}
