import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userWalls extends StatefulWidget {
  const userWalls({super.key});

  @override
  State<userWalls> createState() => _userWallsState();
}

class _userWallsState extends State<userWalls> {
  var uid = "";

  Future<void> getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString("uid")!;
    });
  }

  @override
  void initState() {
    getUid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Wallpapers"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Wallpapers")
            .where("uid", isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.size < 0) {
              return Center(
                child: Text("Lets Upload Some Images First"),
              );
            } else {
              return ListView(
                children: snapshot.data!.docs.map((mwalls) {
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
                                      .doc(mwalls.id)
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
                    leading: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: CachedNetworkImage(
                              imageUrl: mwalls["url"],
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                            ),
                          ),
                        ));
                      },
                      child: CircleAvatar(
                        foregroundImage:
                            CachedNetworkImageProvider(mwalls["url"]),
                      ),
                    ),
                    title: Text("${mwalls["title"]}"),
                    subtitle: Text("${mwalls["description"]}"),
                    trailing: Text("${mwalls["amount"]}"),
                  );
                }).toList(),
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
