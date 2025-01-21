import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaperapp/manageCategory.dart';
import 'package:wallpaperapp/manageUser.dart';
import 'package:wallpaperapp/manageWallpapers.dart';

import 'loginPage.dart';

class adminPage extends StatefulWidget {
  const adminPage({super.key});

  @override
  State<adminPage> createState() => _adminPageState();
}

class _adminPageState extends State<adminPage> {
  var _curindex = 0;
  var _pgcon = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Page"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Logout"),
                    content: Text("Do you want to Logout"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.clear();

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => loginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text("Yes"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("No"),
                      )
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue[300],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Center(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Users")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person,color: Colors.white),
                                  Text(
                                    " : ${snapshot.data!.size}",
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue[300],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Center(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Wallpapers")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo,color: Colors.white),
                                  Text(
                                    " : ${snapshot.data!.size}",
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue[300],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Center(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Categories")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.category,color: Colors.white),
                                  Text(
                                    " : ${snapshot.data!.size}",
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 562,
              child: PageView(
                controller: _pgcon,
                onPageChanged: (value) {
                  setState(() {
                    _curindex = value;
                  });
                },
                children: [
                  manageUser(),
                  manageWallpapers(),
                  manageCategory(),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _curindex = value;
          });
          _pgcon.animateToPage(_curindex,
              duration: Duration(milliseconds: 500), curve: Curves.linear);
        },
        currentIndex: _curindex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Wallpapers"),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: "Category"),
        ],
      ),
    );
  }
}
