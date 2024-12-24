import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todolamiya/addPage.dart';
import 'package:todolamiya/updatePage.dart';

class viewPage extends StatefulWidget {
  const viewPage({super.key});

  @override
  State<viewPage> createState() => _viewPageState();
}

class _viewPageState extends State<viewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Enrollment"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => addPage(),
                ));
              },
              icon: Icon(Icons.add)),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Enrollment").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.size <= 0) {
              return Center(
                child: Text("No Data Found"),
              );
            } else {
              return ListView(
                children: snapshot.data!.docs.map((sdata) {
                  return ListTile(
                    title: Text("${sdata["title"]}"),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Text("${sdata["description"]}"),
                          Text("${sdata["date"]}"),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_upward),
                      onPressed: () {
                        print("${sdata.id}");
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => updatePage(id: sdata.id),
                        ));
                      },
                    ),
                    leading: CircleAvatar(
                      child: IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("Enrollment")
                              .doc(("${sdata.id}"))
                              .delete()
                              .then(
                            (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Data Deleted")));
                            },
                          );
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
