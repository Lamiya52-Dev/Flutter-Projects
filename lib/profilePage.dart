import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'homePage.dart';

class profilePage extends StatefulWidget {
  const profilePage({super.key});

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  var _email = TextEditingController();
  var _uname = TextEditingController();
  var uid = "";
  var profileimg;
  var _fkey = GlobalKey<FormState>();
  XFile? _img;

  void _getUser() async {
    setState(() {
      uid = FirebaseAuth.instance.currentUser!.uid;
    });
    FirebaseFirestore.instance.collection("Users").doc(uid).get().then((value) {
      setState(() {
        _uname.text = value["username"];
        _email.text = value["email"];
        profileimg = value["profile_img"];
      });
    });
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  Future _pickImage() async {
    try {
      final image = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.gallery);
      if (image == null) {
        return;
      } else {
        setState(() {
          _img = image;
        });
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
              key: _fkey,
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: _img == null
                            ? Container(
                                height: 200,
                                width: 200,
                                child: profileimg == null
                                    ? Center(
                                        child: Text("No Image Found"),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: profileimg,
                                        fit: BoxFit.cover,
                                        height: 200,
                                        width: 200,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ))
                            : Container(
                                height: 200,
                                width: 200,
                                child: _img == null
                                    ? Center(
                                        child: Text("No Image Found"),
                                      )
                                    : _img == null
                                        ? Center(
                                            child: Text("No Image Found"),
                                          )
                                        : Image.file(
                                            File(_img!.path),
                                            fit: BoxFit.cover,
                                          ),
                              ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text("Select Image from Gallery"),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    TextFormField(
                      controller: _uname,
                      decoration: InputDecoration(
                        label: Text("Username"),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: _email,
                      decoration: InputDecoration(
                        label: Text("Email ID"),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          var _ignm = _uname.text
                                  .trim()
                                  .toLowerCase()
                                  .replaceAll(" ", "") +
                              DateTime.now().minute.toString() +
                              ".jpg";
                          var supabase = await Supabase.instance;
                          if (_img == null) {
                            FirebaseFirestore.instance
                                .collection("Users")
                                .doc(uid)
                                .update({
                              "username": _uname.text.toString(),
                              "email": _email.text.toString(),
                              "profile_img": profileimg,
                            });
                          } else {
                            supabase.client.storage
                                .from("User")
                                .upload(_ignm, File(_img!.path));
                            profileimg = supabase.client.storage
                                .from("User")
                                .getPublicUrl(
                                  _ignm,
                                );
                            FirebaseFirestore.instance
                                .collection("Users")
                                .doc(uid)
                                .update({
                              "username": _uname.text.toString(),
                              "email": _email.text.toString(),
                              "profile_img": profileimg,
                            }).then(
                              (value) async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.clear();
                                FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(uid)
                                    .get()
                                    .then(
                                  (value) {
                                    prefs.setString("uid", uid);
                                    prefs.setString(
                                        "username", value["username"]);
                                    prefs.setString("email", value["email"]);
                                    prefs.setString(
                                        "purl", value["profile_img"]);
                                    prefs.setBool("islogin", true);
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => homePage(),
                                    ));
                                  },
                                );
                              },
                            );
                          }
                        },
                        child: Text("Update Profile"))
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
