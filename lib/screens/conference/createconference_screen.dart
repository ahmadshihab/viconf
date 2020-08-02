import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:bubbleapp/models/conference_model.dart';
import 'package:bubbleapp/models/contacts.dart';
import 'package:bubbleapp/models/particpants_model.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/provider/user_provider.dart';
import 'package:bubbleapp/screens/callscreen/pickup_layout.dart';
import 'package:bubbleapp/screens/conference/confirmation_screen.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:bubbleapp/services/chat_methods.dart';
import 'package:bubbleapp/services/conference_methods.dart';
import 'package:bubbleapp/widgets/custom_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:bubbleapp/models/contacts_model.dart';
import 'package:provider/provider.dart';

class CreateConferenceScreen extends StatefulWidget {
  static final String id = 'conference_screen';
  final String currentUserId;
  CreateConferenceScreen({this.currentUserId});

  @override
  _ConferenceScreenState createState() => _ConferenceScreenState();
}

class _ConferenceScreenState extends State<CreateConferenceScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  DatePickerController _controller = DatePickerController();
  DateTime _confDate = DateTime.now();
  String _name, _topic;
  ConferenceMethods _conferenceMethods = ConferenceMethods();
  String query = '';
  List<UserModel> userList;
  List<Participant> participants = List<Participant>();
  TextEditingController searchController = TextEditingController();
  DateTime _confTime = DateTime.now();
  final ChatMethods _chatMethods = ChatMethods();
//  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<UserModel>> key = new GlobalKey();
  AuthMethods _authMethods = AuthMethods();
  ConferenceModel createdConference = ConferenceModel();
  String currentConfID;

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((FirebaseUser user) {
      _chatMethods.contactList(user).then((List<UserModel> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }

  Widget row(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            child: Image.network(user.profilePhoto),
          ),
          SizedBox(width: 6.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.name,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                user.email,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              Divider(
                thickness: 8.0,
                color: Colors.black,
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: _chatMethods.fetchContacts(userId: userProvider.getUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docList = snapshot.data.documents;

            //inti screens.conference data
            void createConf() {
              ConferenceModel conferenceModel = ConferenceModel(
                ownerId: userProvider.getUser.uid,
                name: _name,
                topic: _topic,
                confDate: Timestamp.fromDate(_confDate),
                confTime: Timestamp.fromDate(_confTime),
                participants: participants,
              );

              createdConference = conferenceModel;
              _conferenceMethods.addConferenceToDb(
                  conferenceModel, userProvider.getUser, participants);
            }

            buildSuggestion(String query) {
              List<UserModel> suggestionList = query.isEmpty
                  ? []
                  : userList.where((UserModel user) {
                      String _getUsername = user.username.toLowerCase();
                      String _query = query.toLowerCase();
                      String _getName = user.name.toLowerCase();
                      bool matchesUsername = _getUsername.contains(_query);
                      bool matchesName = _getName.contains(_query);

                      return (matchesUsername || matchesName);
                    }).toList();

              return suggestionList;
            }

            return PickupLayout(
              scaffold: Form(
                key: _globalKey,
                child: Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    title: Center(
                      child: GradientText(
                        'VICONF',
                        gradient: LinearGradient(
                            colors: [Color(0XFFD90746), Color(0xFFEB402C)]),
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    leading: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0XFFD90746),
                        size: 30.0, // add custom icons also
                      ),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'SET CONFERENCE NAME',
                            style: TextStyle(
                                color: Color(0XFFD90746),
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          TextFormField(
                              onSaved: (value) {
                                _name = value;
                              },
                              autofocus: false,
                              cursorColor: Color(0XFFD90746),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Colors.black12, width: 2.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Colors.black12, width: 2.0)),
                              )),
                          SizedBox(height: 16.0),
                          Text(
                            'SET A TOPIC',
                            style: TextStyle(
                                color: Color(0XFFD90746),
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          TextFormField(
                              onSaved: (value) {
                                _topic = value;
                              },
                              autofocus: false,
                              cursorColor: Color(0XFFD90746),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Colors.black12, width: 2.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Colors.black12, width: 2.0)),
                              )),
                          SizedBox(height: 16.0),
                          Text(
                            'PICK A DATE',
                            style: TextStyle(
                                color: Color(0XFFD90746),
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 12.0),
                          Container(
                            //padding: EdgeInsets.only(left: 25.0, right: 25.0),
                            child: DatePicker(
                              DateTime.now().add(Duration(days: 0)),
                              width: 60.0,
                              height: 80.0,
                              controller: _controller,
                              initialSelectedDate: DateTime.now(),
                              selectionColor: Color(0XFFD90746),
                              selectedTextColor: Colors.white,
                              onDateChange: (date) {
                                // New date selected
                                setState(() {
                                  _confDate = date;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'CHOOSE TIME',
                            style: TextStyle(
                                color: Color(0XFFD90746),
                                fontWeight: FontWeight.w700),
                          ),
                          TimePickerSpinner(
                            alignment: Alignment.centerRight,
                            is24HourMode: false,
                            normalTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black),
                            highlightedTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color(0XFFD90746)),
                            spacing: 50,
                            itemHeight: 60,
                            isForce2Digits: true,
                            onTimeChange: (time) {
                              setState(() {
                                _confTime = time;
                              });
                            },
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            'Add PARTICIPANTS',
                            style: TextStyle(
                                color: Color(0XFFD90746),
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 8.0),
                          TypeAheadField(
                              textFieldConfiguration: TextFieldConfiguration(
                                  controller: searchController,
                                  autofocus: false,
                                  cursorColor: Color(0XFFD90746),
                                  decoration: InputDecoration(
                                    hintText: 'ENTER EMAIL',
                                    hintStyle: TextStyle(
                                        color: Colors.black38, fontSize: 12.0),
                                    suffixIcon: Container(
                                      margin: EdgeInsets.all(8.0),
                                      child: Material(
                                        color: Colors.white,
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(60.0),
                                            gradient: LinearGradient(
                                                colors: [
                                                  const Color(0XFFD90746),
                                                  const Color(0xFFEB402C)
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter),
                                            color: Color(0XFFD90746),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.add),
                                            color: Colors.white,
                                            onPressed: () {
                                              searchController.clear();
//                                              for (int i = 0;
//                                                  i < userList.length;
//                                                  i++) {
//                                                if (searchController ==
//                                                    userList[i].username) {
//                                                  participants.add(userList[i]);
//                                                }
//                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 10.0),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                            color: Colors.black12, width: 2.0)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                            color: Colors.black12, width: 2.0)),
                                  )),
                              suggestionsCallback: (pattern) async {
                                return buildSuggestion(searchController.text);
                              },
                              itemBuilder: (context, suggestion) {
                                return row(suggestion);
                              },
                              onSuggestionSelected: (suggestion) {
                                setState(() {
                                  UserModel user = suggestion;
                                  searchController.text = user.name;
                                  participants
                                      .add(user.userToParticipants(user));
                                  userList.remove(user);
                                });
                              }),
                          SizedBox(height: 16.0),
                          Text(
                            'Remove Participant',
                            style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 6.0),
                          Container(
                            height: 100.0,
//                            child: ListView.builder(
//                                itemCount: participants.length,
//                                shrinkWrap: true,
//                                scrollDirection: Axis.horizontal,
//                                itemBuilder: (context, index) {
//                                  Participant participant =
//                                      Participant.fromMap(docList[index].data);
//                                  return GestureDetector(
//                                    onLongPress: () async {
////                                      UserModel user = await _conferenceMethods.participantsToUser(participant);
//                                      participants.remove(participant);
//                                    },
//                                    child: ContactsTile(
//                                      contact: participant,
//                                      height: 60,
//                                      width: 60,
//                                    ),
//                                  );
//                                }),
                          ),
                          SizedBox(height: 16.0),
                          Material(
                            //elevation: 5.0,
                            //color: Color(0XFFD90746),
                            //borderRadius: BorderRadius.circular(30.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60.0),
                                gradient: LinearGradient(
                                    colors: [
                                      const Color(0XFFD90746),
                                      const Color(0xFFEB402C)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter),
                              ),
                              child: MaterialButton(
                                onPressed: () async {
                                  print(createdConference.name);

                                  if (_globalKey.currentState.validate()) {
                                    _globalKey.currentState.save();
                                    try {
                                      createConf();
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ConfirmationScreen(
                                            conferenceModel: createdConference);
                                      }));
                                    } catch (e) {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: (Text(e.message)),
                                      ));
                                    }
                                  }
                                },
                                minWidth: double.maxFinite,
                                height: 60.0,
                                child: Text(
                                  'SUBMIT',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
