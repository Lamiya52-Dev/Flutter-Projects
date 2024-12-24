import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class addPage extends StatefulWidget {
  const addPage({super.key});

  @override
  State<addPage> createState() => _addPageState();
}

class _addPageState extends State<addPage> {
  var _fkey = GlobalKey<FormState>();
  var _title = TextEditingController();
  var _desc = TextEditingController();
  var _dt = TextEditingController();
  DateTime? fdt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ToDo lists"),
          centerTitle: true,
          backgroundColor: Colors.cyan,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Form(
              key: _fkey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(
                        labelText: "Enter Title",
                        hintText: "Ex :- Enrollment",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter the title";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  TextFormField(
                    controller: _desc,
                    decoration: InputDecoration(
                        labelText: "Enter Description",
                        hintText: "Ex :- Roll Number ",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter the description";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  TextFormField(
                    controller: _dt,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickeddate = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026),
                      );
                      if (pickeddate != null) {
                        _dt.text = pickeddate.toLocal().toString();
                        fdt = pickeddate;
                      }
                    },
                    decoration: InputDecoration(
                        labelText: "Enter date ",
                        hintText: "Ex :- 24/10/2001",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter the title";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("Enrollment")
                            .add({
                          "title": _title.text.toString(),
                          "description": _desc.text.toString(),
                          "date": _dt.text.toString(),
                          "datetimestamp": fdt
                        }).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Data added ")));
                        });
                      },
                      child: Text("Add"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
