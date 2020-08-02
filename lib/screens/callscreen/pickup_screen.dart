import 'package:bubbleapp/models/call.dart';
import 'package:bubbleapp/utils/permissions.dart';
import 'package:bubbleapp/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:bubbleapp/services/call_methods.dart';

import 'package:bubbleapp/screens/callscreen/call_screen.dart';

class PickupScreen extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({@required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Incoming...',
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(height: 50),
            CachedImage(
              call.callerPic,
              isRound: true,
              radius: 180,
            ),
            SizedBox(height: 50),
            Text(
              call.callerName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.call_end),
                    color: Colors.redAccent,
                    onPressed: () async {
                      await callMethods.endCall(call: call);
                    },
                  ),
                  SizedBox(width: 25),
                  IconButton(
                    icon: Icon(Icons.call),
                    color: Colors.green,
                    onPressed: () async => await Permissions
                            .cameraAndMicrophonePermissionsGranted()
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CallScreen(call: call),
                            ))
                        : {},
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
