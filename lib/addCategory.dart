import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class addCategory extends StatefulWidget {
  const addCategory({super.key});

  @override
  State<addCategory> createState() => _addCategoryState();
}

class _addCategoryState extends State<addCategory> {
  var _imgname = TextEditingController();

  XFile? _img;

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
        title: Text("Add Category"),
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
              decoration: InputDecoration(labelText: "Category Name : "),
            ),
            SizedBox(
              height: 8,
            ),
            FilledButton.tonalIcon(
              onPressed: () async {
                var _name = _imgname.text.toString();
                var _ignm =
                    _name.trim().toLowerCase().replaceAll(" ", "") + ".jpg";
                var supabase = await Supabase.instance;
                supabase.client.storage
                    .from("Category")
                    .upload(_ignm, File(_img!.path));
                var url = supabase.client.storage.from("Category").getPublicUrl(
                      _ignm,
                    );
                FirebaseFirestore.instance.collection("Categories").add(
                  {"name": _name, "url": url, "visible": true},
                ).then(
                  (value) {
                    setState(() {
                      _imgname.text = "";
                      _img = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Category Added")));
                    Navigator.of(context).pop();
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
