import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ntlwallpaper/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("LOGOUT"),
          onPressed: ()async{
            SharedPreferences prefs=await SharedPreferences.getInstance();
            prefs.clear().then((value) {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => loginPage(),));
            },);
          },
        ),
      ),
    );
  }
}
