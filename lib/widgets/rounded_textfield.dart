import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Function onClick;

  String _errorMessage(String str) {
    switch (hintText) {
      case 'display name':
        return 'Name is empty!';
      case 'yourmailid@mail.com':
        return 'email is empty!';
      case 'your password':
        return 'Password is empty!';
      case 'confirm your password':
        return 'Password is empty!';
    }
  }

  RoundedTextField({this.hintText, this.obscureText, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return _errorMessage(hintText);
          }
        },
        style: TextStyle(color: Color(0xFFF1F1F1), fontWeight: FontWeight.w700),
        obscureText: obscureText,
        onSaved: onClick,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFAA1B21),
          hintText: hintText,
          hintStyle:
              TextStyle(color: Color(0xFFF1F1F1), fontWeight: FontWeight.w700),
          errorStyle: TextStyle(color: Colors.white),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.white, width: 0.1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.black12, width: 0.0)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.black12, width: 0.0)),
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
//          border: OutlineInputBorder(
//            //borderRadius: BorderRadius.all(Radius.circular(90.0)),
//            borderSide: BorderSide.none,
//          ),
        ),
      ),
    );
  }
}
