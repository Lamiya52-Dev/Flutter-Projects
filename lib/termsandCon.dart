import 'package:flutter/material.dart';

class termsandCon extends StatefulWidget {
  const termsandCon({super.key});

  @override
  State<termsandCon> createState() => _termsandConState();
}

class _termsandConState extends State<termsandCon> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms & Condition"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to the NodeWally Wallpaper App. By accessing and using the NodeWally , you agree to comply with and be bound by the following Terms and ConditionsThese Terms govern your use of the App and its services, including but not limited to the download and usage of wallpapers",
                textAlign: TextAlign.justify,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                  "Please read these Terms carefully before using the App. If you do not agree with any part of these Terms, you must not use the App."),
              SizedBox(
                height: 10,
              ),
              Text(
                "Eligibility",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                  "You must be at least 13 years old to use the App. By using the App, you confirm that you are at least 13 years of age or have parental consent if required by your local laws."),

            ],
          ),
        ),
      ),
    );
  }
}
