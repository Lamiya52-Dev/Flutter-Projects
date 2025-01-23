import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaperapp/addPage.dart';
import 'package:wallpaperapp/favouritePage.dart';
import 'package:wallpaperapp/profilePage.dart';
import 'package:wallpaperapp/showCategory.dart';
import 'package:wallpaperapp/showWalls.dart';
import 'package:wallpaperapp/termsandCon.dart';
import 'package:wallpaperapp/userWalls.dart';

import 'loginPage.dart';

class homePage extends StatefulWidget {
  final Function changeTheme;
  final Function changeColor;

  const homePage(
      {super.key, required this.changeTheme, required this.changeColor});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  var pg = true;
  var purl = "";
  var uid = "";
  var uname = "";
  var email = "";
  var _curindex = 0;
  var _pgcon = PageController();
  bool isDarkMode = false;
  Color primaryColor = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    checkpg();
    _loadUserData(); // Load user data (uid, name, email, etc.) on init
  }

  // This method is used to check user status from Firestore
  void checkpg() {
    String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUid)
          .get()
          .then((value) {
        setState(() {
          pg = value["status"];
        });
      });
    }
  }

  // This method is used to load user data from SharedPreferences or Firebase Auth
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      uname = prefs.getString("username") ??
          "User"; // Make sure the user name is loaded
      email = prefs.getString("email") ?? "user@example.com"; // Load email
      purl = prefs.getString("purl") ?? ""; // Load profile URL if saved
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Home")),
        body: PageView(
          controller: _pgcon,
          onPageChanged: (value) {
            setState(() {
              _curindex = value;
            });
          },
          children: [showWalls(), showCategory()],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("Welcome! ${uname}"),
                accountEmail: Text("$email"),
                currentAccountPicture: CircleAvatar(
                  foregroundImage: NetworkImage("$purl"),
                ),
                otherAccountsPictures: [
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
                                      builder: (context) => loginPage(
                                        changeColor: widget.changeColor,
                                        changeTheme: widget.changeTheme,
                                      ),
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
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              uid.isNotEmpty
                  ? StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("Users")
                          .doc(uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
                          var userData =
                              snapshot.data!.data() as Map<String, dynamic>;

                          // Check if "status" exists and is true
                          if (userData["status"] == true) {
                            return SizedBox(); // Return an empty widget if status is true
                          } else {
                            return ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => userWalls(),
                                ));
                              },
                              title: Text("My Wallpapers"),
                              leading: Icon(Icons.photo),
                            );
                          }
                        } else {
                          return Center(
                            child: Text("No data available"),
                          );
                        }
                      },
                    )
                  : Container(),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => profilePage(),
                  ));
                },
                title: Text("Profile"),
                leading: Icon(Icons.person),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => favouritePage(),
                  ));
                },
                title: Text("Favourite"),
                leading: Icon(Icons.favorite),
              ),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              title: Text("Dark Mode"),
                              value: isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  isDarkMode = value;
                                  widget.changeTheme(value);
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  child: CircleAvatar(
                                    backgroundColor:
                                        primaryColor == Colors.deepPurple
                                            ? Colors.white
                                            : Colors.transparent,
                                    child: CircleAvatar(
                                      child: Icon(
                                        Icons.check,
                                        color: primaryColor == Colors.deepPurple
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                      radius: 15,
                                      backgroundColor: Colors.deepPurple,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      primaryColor = Colors.deepPurple;
                                      widget.changeColor(Colors.deepPurple);
                                    });
                                  },
                                ),
                                InkWell(
                                  child: CircleAvatar(
                                    backgroundColor:
                                        primaryColor == Colors.deepOrange
                                            ? Colors.white
                                            : Colors.transparent,
                                    child: CircleAvatar(
                                      radius: 15,
                                      child: Icon(
                                        Icons.check,
                                        color: primaryColor == Colors.deepOrange
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                      backgroundColor: Colors.deepOrange,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      primaryColor = Colors.deepOrange;
                                      widget.changeColor(Colors.deepOrange);
                                    });
                                  },
                                ),
                                InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: primaryColor == Colors.red
                                        ? Colors.white
                                        : Colors.transparent,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.check,
                                        color: primaryColor == Colors.red
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      primaryColor = Colors.red;
                                      widget.changeColor(Colors.red);
                                    });
                                  },
                                ),
                                InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: primaryColor == Colors.blue
                                        ? Colors.white
                                        : Colors.transparent,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.blue,
                                      child: Icon(
                                        Icons.check,
                                        color: primaryColor == Colors.blue
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      primaryColor = Colors.blue;
                                      widget.changeColor(Colors.blue);
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                title: Text("Settings"),
                leading: Icon(Icons.settings),
              ),
              ListTile(
                onTap: () {
                  showLicensePage(context: context);
                },
                title: Text("About & Licenses"),
                leading: Icon(Icons.info_outline),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => termsandCon(),
                  ));
                },
                title: Text("Terms & Condition"),
                leading: Icon(Icons.assignment),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text("Made With ❤ By NodeToLearn"),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _curindex,
          onTap: (value) {
            setState(() {
              _curindex = value;
            });
            _pgcon.animateToPage(_curindex,
                duration: Duration(milliseconds: 500), curve: Curves.linear);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.photo), label: "Wallpapers"),
            BottomNavigationBarItem(
                icon: Icon(Icons.category), label: "Category")
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;

              // Check if "status" exists and is true
              if (userData["status"] == true) {
                return SizedBox(); // Return an empty widget if status is true
              } else {
                return FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => addPage(),
                    ));
                  },
                  child: Icon(Icons.add),
                );
              }
            } else {
              return Center(
                child: Text("No data available"),
              );
            }
          },
        ) // If UID is empty, show nothing (Container)
        );
  }
}
