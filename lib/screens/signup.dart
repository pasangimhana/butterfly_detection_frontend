import 'package:flutter/material.dart';
import 'package:foodie/screens/signin_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = new GlobalKey<FormState>();

  static final _conUserName = TextEditingController();
  static final _conPassword = TextEditingController();
  static final _conCPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _conUserName,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: 'User Name (Email)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _conPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _conCPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // Implement registration functionality here
                    },
                    child: Text('Register'),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Login Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()), // replace with your login page class name
                      );
                    },
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                 // Image.asset('images/logo2.png', width: 100, height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
