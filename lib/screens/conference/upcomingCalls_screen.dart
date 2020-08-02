import 'package:bubbleapp/constants/strings.dart';
import 'package:bubbleapp/models/conference_model.dart';
import 'package:bubbleapp/provider/user_provider.dart';
import 'package:bubbleapp/screens/conference/createconference_screen.dart';
import 'package:bubbleapp/screens/groups/chatGroup.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:bubbleapp/services/conference_methods.dart';
import 'package:bubbleapp/widgets/quiet_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:text_drawable_widget/color_generator.dart';
import 'package:text_drawable_widget/text_drawable_widget.dart';

class UpcomingScreen extends StatefulWidget {
  @override
  _UpcomingScreen createState() => _UpcomingScreen();
}

class _UpcomingScreen extends State<UpcomingScreen> {
  ConferenceMethods _conferenceMethods = ConferenceMethods();
  AuthMethods _authMethods = AuthMethods();
  List<ConferenceModel> confList;
  List<ConferenceModel> myList = List<ConferenceModel>();
  ConferenceModel conferenceModel;
  String currentUserId;
  final f = DateFormat('yyyy-mm-dd');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    currentUserId = userProvider.getUser.uid;
    return FutureBuilder(
      future: _conferenceMethods.getUserConference(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          myList = snapshot.data;
//          for (var i = 0; i < confList.length; i++) {
//            if (confList[i].ownerId == currentUserId) {
//              myList.add(confList[i]);
//            }
//          }
          if (myList.isEmpty) {
            return QuietBox(
              text1: "This is where all the conference are listed",
              text2: "Create conferences to start your business",
              text3: "CREATE CONFERENCE",
              onPressed: () => CreateConferenceScreen(),
            );
          }

          return Scaffold(
            body: upcomingCardsList(context, myList),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget upcomingCardsList(
      BuildContext context, List<ConferenceModel> confList) {
    return Center(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: EdgeInsetsDirectional.only(
                start: 8.0, end: 8.0, top: 16.0, bottom: 8.0),
            child: ListView.builder(
              itemBuilder: (BuildContext context, int position) {
                return upcomingCard(context, confList[position]);
              },
              itemCount: confList.length,
            ),
          ),
        ),
      ),
    );
  }

  Widget upcomingCard(BuildContext context, ConferenceModel conferenceModel) {
    DateTime confDate = conferenceModel.confDate.toDate();
    DateTime confTime = conferenceModel.confTime.toDate();
    return Container(
      margin: EdgeInsets.only(bottom: 4.0),
      child: Card(
        child: InkWell(
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatGroup(
                          conferenceModel: conferenceModel,
                        )));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextDrawableWidget(
                    conferenceModel.name, ColorGenerator.materialColors,
                    (bool selected) {
                  // on tap callback
                }, true, 60.0, 60.0, BoxShape.circle),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        conferenceModel.name,
                        style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'ON\t' +
                            DateFormat('yyyy-MM-dd')
                                .format(confDate)
                                .toString() +
                            '\tAT\t' +
                            DateFormat('hh:mm a').format(confTime).toString(),
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
