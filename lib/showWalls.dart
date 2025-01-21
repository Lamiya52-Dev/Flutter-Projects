import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'downloadPage.dart';

class showWalls extends StatefulWidget {
  const showWalls({super.key});

  @override
  State<showWalls> createState() => _showWallsState();
}

class _showWallsState extends State<showWalls> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Wallpapers")
              .where("visible", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.size < 1) {
                return Center(
                  child: Text("No Images Found"),
                );
              } else {
                return GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1 / 1.4),
                  children: snapshot.data!.docs.map(
                    (img) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => downloadPage(id: img.id),
                          ));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 300,
                            child: Stack(children: [
                              CachedNetworkImage(
                                imageUrl: "${img["url"]}",
                                height: 300,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ]),
                          ),
                        ),
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
      ),
    );
  }
}
