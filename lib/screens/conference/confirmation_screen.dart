import 'package:bubbleapp/models/conference_model.dart';
import 'package:bubbleapp/screens/callscreen/pickup_layout.dart';
import 'package:bubbleapp/services/conference_methods.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../home_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  static const String id = 'confirmation_screen';
  ConferenceModel conferenceModel;

  ConfirmationScreen({this.conferenceModel});

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  ConferenceMethods _conferenceMethods = ConferenceMethods();
  bool _isSelected = false;
//  DateTime confDate = ;
//  DateTime confTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [const Color(0XFFD90746), const Color(0xFFEB402C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 250.0,
                        width: 250.0,
                        decoration: BoxDecoration(
                            color: Color(0xFFD01830), shape: BoxShape.circle),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isSelected = !_isSelected;
                          });
                        },
                        child: AnimatedContainer(
                          height: _isSelected ? 250.0 : 150,
                          width: _isSelected ? 250.0 : 150,
                          duration: Duration(seconds: 2),
                          curve: Curves.easeOut,
                          onEnd: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                          },
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 20.0,
                              )
                            ],
                            color: Colors.white,
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0XFFD90746),
                                  const Color(0xFFEB402C)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 60.0,
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0),
                  Text(
                    'CONFERENCE SUCCESSFULLY SCHEDULED',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ON' +
                        DateFormat('yyyy-MM-dd')
                            .format(widget.conferenceModel.confDate.toDate())
                            .toString() +
                        '\tAT\t' +
                        DateFormat('hh:mm a')
                            .format(widget.conferenceModel.confTime.toDate())
                            .toString(),
//                    'ON JAN 16TH AT 09:30 WITH 4 PARTICIPANTS',
                    style: TextStyle(color: Colors.white38),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
