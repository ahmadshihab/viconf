import 'dart:math';

import 'package:bubbleapp/models/call.dart';
import 'package:bubbleapp/models/conference_model.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/screens/callscreen/call_screen.dart';
import 'package:bubbleapp/services/call_methods.dart';
import 'package:flutter/material.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserModel from, UserModel to, context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }

  static dialGroup(UserModel from, ConferenceModel conferenceModel,
      List<String> participants, context) async {
    Call call = Call.groupCall(
      callerId: from.uid,
      callerName: conferenceModel.name,
      callerPic: from.profilePhoto,
      receiversId: participants,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }
}
