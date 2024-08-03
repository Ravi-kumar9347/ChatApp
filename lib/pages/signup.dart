import 'package:chat_app/pages/home.dart';
import 'package:chat_app/pages/signin.dart';
import 'package:chat_app/service/database.dart';
import 'package:chat_app/service/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String name = "", email = "", password = "", confirmPassword = "";
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  registration() async {
    if (!password.isEmpty && password == confirmPassword) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String id = randomAlphaNumeric(10);
        String user = emailController.text.replaceAll("@gmail.com", "");
        String updateUserName =
            user.replaceFirst(user[0], user[0].toUpperCase());
        String firstletter = user.substring(0, 1).toUpperCase();

        Map<String, dynamic> userInfoMap = {
          "Name": nameController.text,
          "E-mail": emailController.text,
          "UserName": updateUserName.toUpperCase(),
          "SearchKey": firstletter,
          "Photo":
              "https://img.freepik.com/premium-vector/young-man-face-avater-vector-illustration-design_968209-15.jpg",
          "Id": id,
        };

        await DatabaseMethods().addUserDetails(userInfoMap, id);
        await SharedPreferenceHelper().saveUserId(id);
        await SharedPreferenceHelper().saveUserDisplayName(nameController.text);
        await SharedPreferenceHelper().saveUserEmail(emailController.text);
        await SharedPreferenceHelper().saveUserPic(
            "https://img.freepik.com/premium-vector/young-man-face-avater-vector-illustration-design_968209-15.jpg");
        await SharedPreferenceHelper().saveUserName(
            emailController.text.replaceAll("@gmail.com", "").toUpperCase());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Registered Successfully",
          style: TextStyle(fontSize: 20.0),
        )));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      } on FirebaseAuthException catch (e) {
        print("catch block");
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "SignUp",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Create a new Account",
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
                      margin: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 30.0, horizontal: 20.0),
                          height: MediaQuery.of(context).size.height / 1.6,
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
                                    "Name",
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
                                      controller: nameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter the Name";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: Color(0xFF7f30fc),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
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
                                      controller: emailController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter the Email";
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
                                      controller: passwordController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter the Password";
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
                                  Text(
                                    "Confirm Password",
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
                                      controller: confirmPasswordController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter the Confirm Password";
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
                                    height: 30.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SignIn(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Sign In Now!",
                                          style: TextStyle(
                                              color: Color(0xFF7f30fe),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  )
                                ]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            name = nameController.text;
                            email = emailController.text;
                            password = passwordController.text;
                            confirmPassword = confirmPasswordController.text;
                          });
                        }

                        registration();
                      },
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          width: MediaQuery.of(context).size.width,
                          child: Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Color(0xFF6380fb),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Center(
                                child: Text(
                                  "SIGN UP",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
