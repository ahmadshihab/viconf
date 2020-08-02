import 'package:bubbleapp/models/contacts.dart';
import 'package:bubbleapp/models/contacts_model.dart';
import 'package:bubbleapp/provider/user_provider.dart';
import 'package:bubbleapp/screens/search_screen.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:bubbleapp/services/chat_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubbleapp/widgets/quiet_box.dart';
import 'history_tile.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChatListContainer();
  }
}

class ChatListContainer extends StatelessWidget {
  final String currentUserId;
  ChatListContainer({this.currentUserId});

  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _chatMethods.fetchContacts(userId: userProvider.getUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.documents;

          if (docList.isEmpty) {
            return QuietBox(
              text1: "This is where all the contacts are listed",
              text2:
                  "Search for your friends and family to start calling or chatting with them",
              text3: "START SEARCHING",
              onPressed: () => SearchScreen(),
            );
          }
          return ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.black12,
                  thickness: 1.0,
                );
              },
              itemCount: docList.length,
              //shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                Contact contact = Contact.fromMap(docList[index].data);
                return HistoryTile(contact: contact);
              });
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

//ClipRRect(
//borderRadius: BorderRadius.circular(60.0),
//child: Image.network(imageUrl,
//height: 100.0, width: 100.0, fit: BoxFit.cover),
//),
