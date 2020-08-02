import 'package:bubbleapp/enum/view_state.dart';
import 'package:bubbleapp/models/conference_model.dart';
import 'package:bubbleapp/models/particpants_model.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/provider/image_upload_provieder.dart';
import 'package:bubbleapp/provider/user_provider.dart';
import 'package:bubbleapp/screens/callscreen/pickup_layout.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:bubbleapp/services/chat_methods.dart';
import 'package:bubbleapp/services/conference_methods.dart';
import 'package:bubbleapp/utils/call_utils.dart';
import 'package:bubbleapp/utils/permissions.dart';
import 'package:bubbleapp/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatGroup extends StatefulWidget {
  final ConferenceModel conferenceModel;

  ChatGroup({this.conferenceModel});
  @override
  _ChatGroupState createState() => _ChatGroupState();
}

class _ChatGroupState extends State<ChatGroup> {
  ImageUploadProvider _imageUploadProvider;
  UserProvider _userProvider;
  bool isWriting = false;
  TextEditingController textEditingController = TextEditingController();
  Stream<QuerySnapshot> _chats;
  ConferenceMethods _conferenceMethods = ConferenceMethods();
  List<Participant> confParticipants = List<Participant>();
  UserModel currentUser = UserModel();

  List<IconData> iconList = [
    Icons.image,
    Icons.camera,
    Icons.contacts,
    Icons.my_location,
    Icons.gif,
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      _chats = _conferenceMethods.getChats(widget.conferenceModel.id);
//      confParticipants =
//           _conferenceMethods.getParticipants(widget.conferenceModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    _userProvider = Provider.of<UserProvider>(context);
    currentUser = _userProvider.getUser;
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.conferenceModel.name,
                    style: Theme.of(context).textTheme.headline6,
                    overflow: TextOverflow.clip,
                  ),
                  Text(
                    widget.conferenceModel.topic,
                    style: Theme.of(context).textTheme.bodyText1,
                    overflow: TextOverflow.clip,
                  )
                ],
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
                color: Color(0XFFD90746),
                onPressed: () {},
                icon: Icon(Icons.video_call)),
            IconButton(
                color: Color(0XFFD90746),
                onPressed: () {},
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

  Widget messageList() {
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    sender: snapshot.data.documents[index].data["sender"],
                    sentByMe: currentUser.name ==
                        snapshot.data.documents[index].data["sender"],
                  );
                })
            : Container();
      },
    );
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
                    onPressed: () {},
                  ),
                )
        ],
      ),
    );
  }

  pickImage({ImageSource source}) {}

  sendMessage() {
    if (textEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": textEditingController.text,
        "sender": currentUser.name,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      ConferenceMethods()
          .sendMessage(widget.conferenceModel.id, chatMessageMap);

      setState(() {
        textEditingController.text = "";
      });
    }
  }
}
