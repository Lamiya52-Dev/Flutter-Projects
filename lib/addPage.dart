import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class addPage extends StatefulWidget {
  const addPage({super.key});

  @override
  State<addPage> createState() => _addPageState();
}

class _addPageState extends State<addPage> {
  var uid = "";
  var _imgname = TextEditingController();
  var _imgamt = TextEditingController();
  var _imgdesc = TextEditingController();
  var _imgdate;
  var _imgcat;
  XFile? _img;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString("uid").toString();
    });
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
        title: Text("Add Wallpaper"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: _img == null
                  ? Center(
                      child: Text("No Image Found"),
                    )
                  : Image.file(
                      File(_img!.path),
                      fit: BoxFit.contain,
                    ),
            ),
            FilledButton.tonalIcon(
              onPressed: _pickImage,
              label: Text("Select Image"),
              icon: Icon(Icons.add),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              controller: _imgname,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(labelText: "Title : "),
            ),
            TextField(
              controller: _imgamt,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount : "),
            ),
            TextField(
              controller: _imgdesc,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(labelText: "Description : "),
            ),
            SizedBox(
              height: 8,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Categories")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.size < 0) {
                    return Center(
                      child: Text("No Categories Found"),
                    );
                  } else {
                    return DropdownMenu(
                        width: MediaQuery.of(context).size.width,
                        label: Text("Select Category"),
                        onSelected: (value) {
                          setState(() {
                            _imgcat = value;
                          });
                        },
                        dropdownMenuEntries: snapshot.data!.docs.map((cat) {
                          return DropdownMenuEntry(
                              value: "${cat["name"].toString().toLowerCase()}",
                              label: "${cat["name"]}");
                        }).toList());
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            SizedBox(
              height: 8,
            ),
            FilledButton.tonalIcon(
              onPressed: () async {
                var _name = _imgname.text.toString();
                var _desc = _imgdesc.text.toString();
                var _amt = int.parse(_imgamt.text.toString());
                _imgdate = DateTime.now();
                var _ignm =
                    _name.trim().toLowerCase().replaceAll(" ", "") + "jpg";
                var supabase = await Supabase.instance;
                supabase.client.storage
                    .from("Wallpaper")
                    .upload(_ignm, File(_img!.path));
                var url =
                    supabase.client.storage.from("Wallpaper").getPublicUrl(
                          _ignm,
                        );
                FirebaseFirestore.instance.collection("Wallpapers").add(
                  {
                    "title": _name,
                    "description": _desc,
                    "date": _imgdate,
                    "uid": uid,
                    "category": _imgcat,
                    "url": url,
                    "amount": _amt,
                    "visible": true
                  },
                );
              },
              label: Text("Upload"),
              icon: Icon(Icons.upload),
            )
          ],
        ),
      ),
    );
  }
}
