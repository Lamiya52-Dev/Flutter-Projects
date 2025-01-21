import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallpaperapp/addCategory.dart';

class manageCategory extends StatefulWidget {
  const manageCategory({super.key});

  @override
  State<manageCategory> createState() => _manageCategoryState();
}

class _manageCategoryState extends State<manageCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Categories").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.size < 0) {
              return Center(
                child: Text("No Catgegories Found"),
              );
            } else {
              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map(
                  (walls) {
                    return ListTile(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Delete"),
                              content: Text("Are your Sure"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection("Wallpapers")
                                        .doc(walls.id)
                                        .delete()
                                        .then(
                                      (value) {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                  child: Text("Yes"),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("No")),
                              ],
                            );
                          },
                        );
                      },
                      title: Text(
                        "${walls["name"]}",
                        style: TextStyle(fontSize: 14),
                      ),
                      leading: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider("${walls["url"]}"),
                      ),
                      trailing: IconButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("Categories")
                                .doc(walls.id)
                                .update({"visible": !walls["visible"]});
                          },
                          icon: Icon(walls["visible"]
                              ? Icons.visibility
                              : Icons.visibility_off)),
                    );
                  },
                ).toList(),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => addCategory(),
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
