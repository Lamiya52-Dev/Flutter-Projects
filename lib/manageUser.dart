import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class manageUser extends StatefulWidget {
  const manageUser({super.key});

  @override
  State<manageUser> createState() => _manageUserState();
}

class _manageUserState extends State<manageUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.size < 0) {
              return Center(
                child: Text("No Users Found"),
              );
            } else {
              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map(
                  (user) {
                    return ListTile(
                      title: Text(
                        "${user["username"]}",
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        "${user["email"]}",
                        style: TextStyle(fontSize: 10),
                      ),
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            "${user["profile_img"]}"),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                            user["status"] ? Icons.person : Icons.camera_alt),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("Users")
                              .doc(user.id)
                              .update({"status": !user["status"]});
                        },
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
    );
  }
}
