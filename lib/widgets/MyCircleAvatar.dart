import 'package:flutter/material.dart';
import 'package:bubbleapp/widgets/MyCircleAvatar.dart';

class MyCircleAvatar extends StatelessWidget {
  final String personalPhoto;

  MyCircleAvatar({this.personalPhoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.3),
              offset: Offset(0, 5),
              blurRadius: 25)
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
              child: CircleAvatar(
            backgroundImage: NetworkImage(personalPhoto),
          ))
        ],
      ),
    );
  }
}
