import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class downloadPage extends StatefulWidget {
  final id;

  const downloadPage({super.key, required this.id});

  @override
  State<downloadPage> createState() => _downloadPageState();
}

class _downloadPageState extends State<downloadPage> {
  var _url;
  var _title;
  var _amt = 0;
  var _userid = FirebaseAuth.instance.currentUser!.uid;

  void getSdata() {
    FirebaseFirestore.instance
        .collection("Wallpapers")
        .doc(widget.id)
        .get()
        .then(
      (value) {
        setState(() {
          _url = value["url"];
          _title = value["title"];
          _amt = value["amount"];
        });
      },
    );
  }

  Future<void> _downloadImage(dynamic imgurl, dynamic imgname) async {
    if (await _requestStoragePermission()) {
      try {
        final response = await Dio()
            .get(imgurl, options: Options(responseType: ResponseType.bytes));
        final directory = await getApplicationSupportDirectory();
        final filePath = "${directory.path}/${imgname}.jpg";
        File file = File(filePath);
        await file.writeAsBytes(response.data);
        await GallerySaver.saveImage(filePath);
        await GallerySaver.pleaseProvidePath.toString();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Downloaded Image On ${await GallerySaver.pleaseProvidePath.toString()}")));
      } catch (err) {
        // Optionally, show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${err.toString()}')),
        );
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // You can request multiple permissions at once.
      var result = await Permission.storage.request();
      status = result;
    }
    if (status.isGranted) {
      return true;
    } else {
      // Handle the case where the user denied the permission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return false;
    }
  }

  Future<void> toggleFavourite(
      String uid, String wallid, String imgurl, String title) async {
    final wallRef = FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection("Favourite")
        .doc(wallid);
    final wallsnapshot = await wallRef.get();
    if (wallsnapshot.exists) {
      await wallRef.delete();
    } else {
      await wallRef
          .set({"favurl": imgurl, "favtitle": title, "date": DateTime.now()});
    }
  }

  @override
  void initState() {
    getSdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        Center(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: (_url != null)
                  ? CachedNetworkImage(
                      imageUrl: "${_url}",
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width - 50,
                      height: MediaQuery.of(context).size.height - 200,
                    )
                  : Center(child: CircularProgressIndicator())),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("${_title}"),
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            titleTextStyle: GoogleFonts.playfairDisplay(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _amt > 0
                    ? FloatingActionButton.extended(
                        heroTag: 'download_button',
                        // Unique tag for the download button
                        onPressed: () {
                          _downloadImage(_url, _title);
                        },
                        icon: Icon(Icons.download),
                        label: Text("Pay ₹${_amt}"),
                      )
                    : FloatingActionButton.extended(
                        heroTag: 'download_button',
                        // Unique tag for the download button
                        onPressed: () {
                          _downloadImage(_url, _title);
                        },
                        icon: Icon(Icons.download),
                        label: Text("Download"),
                      ),
                SizedBox(
                  width: 10,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Users")
                      .doc(_userid)
                      .collection("Favourite")
                      .doc(widget.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.data!.exists) {
                        return FloatingActionButton(
                          heroTag: 'favorite_button',
                          // Unique tag for the favorite button
                          onPressed: () async {
                            final uid =
                                await FirebaseAuth.instance.currentUser!.uid;
                            toggleFavourite(uid, widget.id, _url, _title);
                          },
                          child: Icon(
                            Icons.favorite_outlined,
                            color: Colors.red,
                          ),
                        );
                      } else {
                        return FloatingActionButton(
                          heroTag: 'favorite_button',
                          // Unique tag for the favorite button
                          onPressed: () async {
                            final uid =
                                await FirebaseAuth.instance.currentUser!.uid;
                            toggleFavourite(uid, widget.id, _url, _title);
                          },
                          child: Icon(
                            Icons.favorite_outline,
                          ),
                        );
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
// FloatingActionButton(
//                   heroTag: 'favorite_button',
//                   // Unique tag for the favorite button
//                   onPressed: () async{
//                     final uid = await FirebaseAuth.instance.currentUser!.uid;
//                     toggleFavourite(uid, widget.id, _url, _title);
//                   },
//                   child: Icon(Icons.favorite_border_outlined),
//                 )
