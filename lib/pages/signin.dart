import 'package:chat_app/pages/home.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:chat_app/service/database.dart';
import 'package:chat_app/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email = " ",
      password = " ",
      name = " ",
      pic = " ",
      userName = " ",
      id = " ";
  TextEditingController userMailController = new TextEditingController();
  TextEditingController userPasswordController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserByEmail(email);

      name = "${querySnapshot.docs[0]["Name"]}";
      userName = "${querySnapshot.docs[0]["UserName"]}";
      pic = "${querySnapshot.docs[0]["Photo"]}";
      id = querySnapshot.docs[0].id;

      await SharedPreferenceHelper().saveUserId(id);
      await SharedPreferenceHelper().saveUserDisplayName(name);
      await SharedPreferenceHelper().saveUserPic(pic);
      await SharedPreferenceHelper().saveUserName(userName);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      } else if (e.code == "wrong-password") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(
                          MediaQuery.of(context).size.width, 105.0))),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "SignIn",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Login to your account",
                      style: TextStyle(
                          color: Color(0xFFbbb0ff),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 20.0),
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0, color: Colors.black38),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: TextFormField(
                                    controller: userMailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please Enter Email";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.mail_outline,
                                        color: Color(0xFF7f30fc),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Password",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0, color: Colors.black38),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: TextFormField(
                                    controller: userPasswordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please Enter Password";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: Color(0xFF7f30fc),
                                      ),
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                  height: 50.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        email = userMailController.text;
                                        password = userPasswordController.text;
                                      });
                                    }
                                    userLogin();
                                  },
                                  child: Center(
                                    child: Container(
                                      width: 130.0,
                                      child: Material(
                                        elevation: 5.0,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Container(
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                              color: Color(0xFF6380fb),
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          child: Center(
                                            child: Text(
                                              "SignIn",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUp()));
                        },
                        child: Text(
                          "SignUp Now!",
                          style: TextStyle(
                              color: Color(0xFF7f30fe),
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
