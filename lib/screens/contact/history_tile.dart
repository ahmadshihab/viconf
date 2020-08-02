import 'package:bubbleapp/models/contacts.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/provider/user_provider.dart';
import 'file:///E:/Android%20Projects/flutter_app/bubble_app/lib/screens/chat/chat_screen.dart';
import 'package:bubbleapp/screens/contact/last_message_container.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:bubbleapp/services/chat_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryTile extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  HistoryTile({this.contact});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
        future: _authMethods.getUserDetailsById(contact.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserModel userModel = snapshot.data;

            return ViewLayout(contact: userModel);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class ViewLayout extends StatelessWidget {
  final UserModel contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({@required this.contact});
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(
                    receiver: contact,
                  ))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
            child: Row(
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(60.0),
                  child: Image.network(contact.profilePhoto,
                      height: 50.0, width: 50.0, fit: BoxFit.cover),
                ),
//                OnlineDotIndicator(uid: contact.uid)
              ],
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        contact.name ?? '..',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  LastMessageContainer(
                    stream: _chatMethods.fetchLastMessageBetween(
                        senderId: userProvider.getUser.uid,
                        receiverId: contact.uid),
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
