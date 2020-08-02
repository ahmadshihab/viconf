import 'package:flutter/material.dart';
import 'package:bubbleapp/screens/search_screen.dart';

class QuietBox extends StatelessWidget {
  final String text1, text2, text3;
  final Function onPressed;

  QuietBox({this.text1, this.text2, this.text3, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          color: Colors.white10,
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 25),
              Text(
                text2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 25),
              FlatButton(
                color: Color(0XFFD90746),
                child: Text(
                  text3,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => onPressed(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
