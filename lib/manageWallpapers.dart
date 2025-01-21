import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class manageWallpapers extends StatefulWidget {
  const manageWallpapers({super.key});

  @override
  State<manageWallpapers> createState() => _manageWallpapersState();
}

class _manageWallpapersState extends State<manageWallpapers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Wallpapers").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.size < 0) {
              return Center(
                child: Text("No Wallpapers Found"),
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
                        "${walls["title"]}",
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        "${walls["amount"] > 0 ? (walls["amount"] * 0.20).toString() + " Profit" : "Free"}",
                        style: TextStyle(fontSize: 10),
                      ),
                      leading: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider("${walls["url"]}"),
                      ),
                      trailing: IconButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("Wallpapers")
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
    );
  }
}
