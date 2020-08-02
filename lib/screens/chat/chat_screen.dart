import 'dart:io';

import 'package:bubbleapp/constants/strings.dart';
import 'package:bubbleapp/enum/user_state.dart';
import 'package:bubbleapp/enum/view_state.dart';
import 'package:bubbleapp/models/message_model.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/provider/image_upload_provieder.dart';
import 'package:bubbleapp/screens/callscreen/pickup_layout.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:bubbleapp/services/chat_methods.dart';
import 'package:bubbleapp/services/storage_methods.dart';
import 'package:bubbleapp/utils/call_utils.dart';
import 'package:bubbleapp/utils/permissions.dart';
import 'package:bubbleapp/utils/utils.dart';
import 'package:bubbleapp/widgets/MyCircleAvatar.dart';
import 'package:bubbleapp/widgets/cached_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  final UserModel receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();

  final AuthMethods _authMethods = AuthMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final StorageMethods _storageMethods = StorageMethods();
  String path = '/chat/images/';

  ImageUploadProvider _imageUploadProvider;

  bool isWriting = false;

  List<IconData> iconList = [
    Icons.image,
    Icons.camera,
    Icons.contacts,
    Icons.my_location,
    Icons.gif,
  ];

  UserModel sender;
  String _currentUserId;

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((user) async {
      _currentUserId = user.uid;
      sender = await _authMethods.getUser(_currentUserId);
      setState(() {
//        sender = UserModel(
//          uid: user.uid,
//          name: user.displayName,
//          profilePhoto: user.photoUrl,
//        );
      });
    });
  }

  addMediaModal(context) {
    showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: Colors.white,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(25.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 5), blurRadius: 15.0, color: Colors.grey)
              ],
            ),
            child: GridView.count(
              mainAxisSpacing: 21.0,
              crossAxisSpacing: 21.0,
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(
                iconList.length,
                (i) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey[200],
                      border: Border.all(color: Color(0XFFD90746), width: 2),
                    ),
                    child: IconButton(
                      icon: Icon(
                        iconList[i],
                        color: Color(0XFFD90746),
                        size: 30,
                      ),
                      onPressed: () {
                        if (i == 0) {
                          pickImage(source: ImageSource.gallery);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

//  setWritingTo(bool val) {
//    setState(() {
//      isWriting = val;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    Widget getStatus(int number) {
      switch (Utils.numToState(number)) {
        case UserState.Offline:
          return Text('Offline',
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .apply(color: Colors.red));

        case UserState.Online:
          return Text('Online',
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .apply(color: Colors.green));

        default:
          return Text('Offline',
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .apply(color: Colors.red));
      }
    }

    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              color: Color(0XFFD90746),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MyCircleAvatar(
                personalPhoto: widget.receiver.profilePhoto,
              ),
              SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.receiver.name,
                    style: Theme.of(context).textTheme.subtitle1,
                    overflow: TextOverflow.clip,
                  ),
                  getStatus(widget.receiver.state),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
                color: Color(0XFFD90746),
                onPressed: () async =>
                    await Permissions.cameraAndMicrophonePermissionsGranted()
                        ? CallUtils.dial(
                            from: sender, to: widget.receiver, context: context)
                        : {},
                icon: Icon(Icons.video_call)),
            IconButton(
                color: Color(0XFFD90746),
                onPressed: () {
                  print(sender.name);
                },
                icon: Icon(Icons.more_vert)),
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Flexible(child: messageList()),
              _imageUploadProvider.getViewState == ViewState.LOADING
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 15.0),
                      child: CircularProgressIndicator())
                  : Container(),
              chatControls(),
            ],
          ),
        ),
      ),
    );
  }

  sendMessage() {
    var text = textEditingController.text;

    MessageModel _message = MessageModel(
      receiverId: widget.receiver.uid,
      senderId: sender.uid,
      message: text,
      timestamp: Timestamp.now(),
      type: 'text',
    );

    setState(() {
      isWriting = false;
    });
    textEditingController.text = '';

    _chatMethods.addMessageToDb(_message, sender, widget.receiver);
  }

  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.documents.length,
          reverse: true,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  getMessage(MessageModel messageModel) {
    return messageModel.type != MESSAGE_TYPE_IMAGE
        ? Text(
            messageModel.message,
            style: TextStyle(
                color: messageModel.senderId == sender.uid
                    ? Colors.white
                    : Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          )
        : messageModel.photoUrl != null
            ? CachedImage(
                messageModel.photoUrl,
                height: 250,
                width: 250,
                radius: 10,
              )
            : Text('Url was null');
  }

//  String getMessageTime(DocumentSnapshot snapshot) {
//    return snapshot['timestamp'];
//  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    MessageModel _messageModel = MessageModel.fromMap(snapshot.data);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Container(
        alignment: _messageModel.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _messageModel.senderId == _currentUserId
            ? senderLayout(_messageModel)
            : receiverLayout(_messageModel),
      ),
    );
  }

//
  Widget senderLayout(MessageModel messageModel) {
    DateTime messageTime = messageModel.timestamp.toDate();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 2 / 3),
      decoration: BoxDecoration(
        color: Color(0XFFD90746),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(0)),
      ),
      child: Column(
        children: <Widget>[
          getMessage(messageModel),
          SizedBox(height: 6.0),
          Container(
//              alignment: Alignment.bottomCenter,
              child: Text(
            DateFormat('hh:mm a').format(messageTime).toString(),
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ))
        ],
      ),
    );
  }

  Widget receiverLayout(MessageModel messageModel) {
    DateTime messageTime = messageModel.timestamp.toDate();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 2 / 3),
      decoration: BoxDecoration(
        color: Color(0XFFEDEDED),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: <Widget>[
          getMessage(messageModel),
          SizedBox(height: 6.0),
          Container(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('hh:mm a').format(messageTime).toString(),
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ))
        ],
      ),
    );
  }

  pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider,
        path: path);
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    return Container(
      margin: EdgeInsets.all(15.0),
//      height: 61,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
                ],
              ),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.face), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (val) {
                        (val.length > 0 && val.trim() != "")
                            ? setWritingTo(true)
                            : setWritingTo(false);
                      },
                      decoration: InputDecoration(
                          hintText: "Type Something...",
                          hintStyle: TextStyle(fontSize: 15),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo_camera),
                    onPressed: () => pickImage(source: ImageSource.camera),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {
                      addMediaModal(context);
                    },
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 15),
          isWriting
              ? Container(
//                    padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                      color: Color(0XFFD90746), shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () => sendMessage(),
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                )
              : Container(
//                    padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                      color: Color(0XFFD90746), shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.keyboard_voice, color: Colors.white),
                    onPressed: () {
                      print(sender.name);
                    },
                  ),
                )
        ],
      ),
    );
  }
}
