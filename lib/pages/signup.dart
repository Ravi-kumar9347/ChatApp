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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text);

          String id = randomAlphaNumeric(10);
          String user = _emailController.text.replaceAll("@gmail.com", "");
          String updateUserName =
              user.replaceFirst(user[0], user[0].toUpperCase());
          String firstLetter = user.substring(0, 1).toUpperCase();

          Map<String, dynamic> userInfoMap = {
            "Name": _nameController.text,
            "E-mail": _emailController.text,
            "UserName": updateUserName.toUpperCase(),
            "SearchKey": firstLetter,
            "Photo":
                "https://img.freepik.com/premium-vector/young-man-face-avater-vector-illustration-design_968209-15.jpg",
            "Id": id,
          };

          await DatabaseMethods().addUserDetails(userInfoMap, id);
          await SharedPreferenceHelper().saveUserId(id);
          await SharedPreferenceHelper()
              .saveUserDisplayName(_nameController.text);
          await SharedPreferenceHelper().saveUserEmail(_emailController.text);
          await SharedPreferenceHelper().saveUserPic(
              "https://img.freepik.com/premium-vector/young-man-face-avater-vector-illustration-design_968209-15.jpg");
          await SharedPreferenceHelper().saveUserName(updateUserName);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Registered Successfully",
                    style: TextStyle(fontSize: 20.0))),
          );
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        } on FirebaseAuthException catch (e) {
          String message;
          switch (e.code) {
            case 'weak-password':
              message = "Password Provided is too weak";
              break;
            case 'email-already-in-use':
              message = "Account already exists";
              break;
            default:
              message = "Registration failed";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(message, style: TextStyle(fontSize: 18.0)),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Passwords do not match",
                  style: TextStyle(fontSize: 18.0))),
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
                  SizedBox(height: 20.0),
                  _buildSignUpButton(),
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
        "SignUp",
        style: TextStyle(
            color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: Text(
        "Create a new Account",
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
          height: MediaQuery.of(context).size.height / 1.6,
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
                _buildTextField("Name", _nameController, Icons.person_outline,
                    "Please Enter the Name"),
                SizedBox(height: 20.0),
                _buildTextField("Email", _emailController, Icons.mail_outline,
                    "Please Enter the Email"),
                SizedBox(height: 20.0),
                _buildTextField("Password", _passwordController, Icons.password,
                    "Please Enter the Password",
                    obscureText: true),
                SizedBox(height: 10.0),
                _buildTextField("Confirm Password", _confirmPasswordController,
                    Icons.password, "Please Enter the Confirm Password",
                    obscureText: true),
                SizedBox(height: 30.0),
                _buildSignInLink(),
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

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? ",
            style: TextStyle(color: Colors.black, fontSize: 16.0)),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignIn()));
          },
          child: Text(
            "Sign In Now!",
            style: TextStyle(
                color: Color(0xFF7f30fe),
                fontSize: 16.0,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _registerUser,
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
                borderRadius: BorderRadius.circular(10.0),
              ),
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
    );
  }
}
