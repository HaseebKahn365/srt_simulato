// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutMe extends StatelessWidget {
  const AboutMe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Me"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Expanded(
          child: ListView(
            children: [
              //create a circle avatar to display my image
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage(
                  "assets/images/my.JPG",
                ),
              ),

              //create a text widget to display my name
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text(
                  "Abdul Haseeb",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              //Create cards to display my information
              Card(
                child: ListTile(
                  //on tap launch the email app and start composing an email to me

                  // ...

                  onTap: () {
                    const email = 'haseebkahn365@gmail.com';
                    Clipboard.setData(ClipboardData(text: email));

                    //show snackbar at the top
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Email Copied to Clipboard"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  leading: Icon(Icons.email),
                  title: Text("Email"),
                  subtitle: Text("haseebkahn365@gmail.com"),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: () {
                    const phone = '+03491777261';
                    Clipboard.setData(ClipboardData(text: phone));

                    //show snackbar at the top
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Phone Number Copied to Clipboard"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  leading: Icon(Icons.phone),
                  title: Text("Phone"),
                  subtitle: Text("+03491777261"),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text("Address"),
                  subtitle:
                      Text("Kawdari Haji Abad, dist. Mardan, KP Pakistan "),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.school),
                  title: Text("Education"),
                  subtitle: Text("BSc. Computer Science"),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.work),
                  title: Text("Work"),
                  subtitle: Text("Flutter Developer"),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text("Hobbies"),
                  subtitle: Text("Exploring Code, Latest Tech "),
                ),
              ),
              Card(
                //summary about this project

                child: ListTile(
                  title: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "About this project",
                        ),
                      )),
                  subtitle: Text(
                      //shortest remaining time algrorithm
                      "This project is a simple implementation of shortest remaining time algrorithm. \nIt is a preemptive scheduling algorithm in which the process with the smallest amount of time remaining until completion is selected to execute. Since the currently executing process is the one with the shortest amount of time remaining by definition, and since that time should only reduce as execution progresses, processes will always run until they complete or a new process is added that requires a smaller amount of time. The result of this algorithm is that short processes are favored as they have smaller execution time whereas long processes may be blocked indefinitely since the shortest process will always be selected to execute first."),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
