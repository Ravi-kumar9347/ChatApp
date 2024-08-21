import 'package:chat_app/pages/forgotpassword.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:chat_app/service/database.dart';
import 'package:chat_app/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        QuerySnapshot querySnapshot =
            await DatabaseMethods().getUserByEmail(email);

        var userDoc = querySnapshot.docs[0];
        String name = "${userDoc["Name"]}";
        String userName = "${userDoc["UserName"]}";
        String pic = "${userDoc["Photo"]}";
        String id = userDoc.id;

        await SharedPreferenceHelper().saveUserId(id);
        await SharedPreferenceHelper().saveUserDisplayName(name);
        await SharedPreferenceHelper().saveUserPic(pic);
        await SharedPreferenceHelper().saveUserName(userName);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = "No User Found";
            break;
          case 'wrong-password':
            message = "Wrong Password";
            break;
          default:
            message = "Wrong User Credentials";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(message,
                style: TextStyle(fontSize: 18.0, color: Colors.black)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            _buildHeaderBackground(context),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  _buildTitle(),
                  _buildSubtitle(),
                  SizedBox(height: 20.0),
                  _buildForm(),
                  SizedBox(height: 40.0),
                  _buildSignUpLink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4.0,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.elliptical(MediaQuery.of(context).size.width, 105.0),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        "SignIn",
        style: TextStyle(
            color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: Text(
        "Login to your account",
        style: TextStyle(
            color: Color(0xFFbbb0ff),
            fontSize: 18.0,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("Email", _emailController, Icons.mail_outline,
                    "Please Enter Email"),
                SizedBox(height: 20.0),
                _buildTextField("Password", _passwordController, Icons.password,
                    "Please Enter Password",
                    obscureText: true),
                SizedBox(height: 10.0),
                _buildForgotPassword(),
                SizedBox(height: 50.0),
                _buildSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String errorText,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black38),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextFormField(
            controller: controller,
            validator: (value) =>
                value == null || value.isEmpty ? errorText : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Color(0xFF7f30fc)),
            ),
            obscureText: obscureText,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ForgotPassword()));
      },
      child: Container(
        alignment: Alignment.bottomRight,
        child: Text(
          "Forgot Password?",
          style: TextStyle(
              color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _signIn,
      child: Center(
        child: SizedBox(
          width: 130.0,
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color(0xFF6380fb),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  "Sign In",
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
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignUp()));
          },
          child: Text(
            "Sign Up Now!",
            style: TextStyle(
                color: Color(0xFF7f30fe),
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
