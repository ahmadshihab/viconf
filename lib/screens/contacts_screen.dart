import 'package:bubbleapp/models/contacts.dart';
import 'package:bubbleapp/provider/user_provider.dart';
import 'package:bubbleapp/screens/callscreen/pickup_layout.dart';
import 'package:bubbleapp/screens/contact/online_dot_indicator.dart';
import 'package:bubbleapp/services/chat_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bubbleapp/models/contacts_model.dart';

import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatefulWidget {
  static const String id = 'createconference_screen';

  @override
  _CreateConferenceState createState() => _CreateConferenceState();
}

class _CreateConferenceState extends State<ContactsScreen> {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return PickupLayout(
      scaffold: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchContacts(userId: userProvider.getUser.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.documents;

              return Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            child: Text(
                              'ALL CONTACTS',
                              style: TextStyle(
                                color: Color(0xFF3e4e68),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w900,
                              ),
                            )),
                      ],
                    ),
                    Divider(
                      color: Colors.black12,
                      thickness: 1.0,
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3),
                              itemCount: docList.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                Contact contact =
                                    Contact.fromMap(docList[index].data);
                                return Stack(
                                  children: <Widget>[
                                    ContactsTile(
                                      contact: contact,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.2,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                    ),
                                    OnlineDotIndicator(uid: contact.uid)
                                  ],
                                );
                              }),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
