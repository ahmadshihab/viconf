import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:bubbleapp/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bubbleapp/enum/user_state.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final AuthMethods _authMethods = AuthMethods();

  OnlineDotIndicator({
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;

        case UserState.Online:
          return Colors.green;

        default:
          return Colors.red;
      }
    }

    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _authMethods.getUserStream(
          uid: uid,
        ),
        builder: (context, snapshot) {
          UserModel user;

          if (snapshot.hasData && snapshot.data.data != null) {
            user = UserModel.fromMap(snapshot.data.data);
          }
          return Container(
            height: 12,
            width: 12,
            margin: EdgeInsets.only(right: 5, top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(user?.state),
            ),
          );
        },
      ),
    );
  }
}
