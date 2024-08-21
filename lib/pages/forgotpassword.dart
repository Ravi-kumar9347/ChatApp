import 'package:chat_app/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userMailController = TextEditingController();
  String _email = '';

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email has been sent',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 20.0),
          _buildResetPasswordForm(),
          SizedBox(height: 40.0),
          _buildSignUpPrompt(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Password Recovery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Enter your Email',
          style: TextStyle(
            color: Color(0xFFbbb0ff),
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          height: MediaQuery.of(context).size.height / 3,
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
                _buildEmailField(),
                SizedBox(height: 50.0),
                _buildSendEmailButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black38),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextFormField(
            controller: _userMailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Email';
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
            onChanged: (value) => _email = value,
          ),
        ),
      ],
    );
  }

  Widget _buildSendEmailButton() {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState?.validate() ?? false) {
          _resetPassword();
        }
      },
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
                  'Send Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUp(),
              ),
            );
          },
          child: Text(
            'Sign Up Now!',
            style: TextStyle(
              color: Color(0xFF7f30fe),
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
