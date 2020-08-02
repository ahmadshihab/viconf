import 'package:bubbleapp/models/conference_model.dart';
import 'package:bubbleapp/models/particpants_model.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubbleapp/constants/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConferenceMethods {
  static final Firestore _fireStore = Firestore.instance;
  AuthMethods _auth = AuthMethods();

  final CollectionReference _conferenceCollection =
      Firestore.instance.collection(CONFERENCE_COLLECTION);
  final CollectionReference _userCollection =
      _fireStore.collection(USERS_COLLECTION);

  final CollectionReference _messageCollection =
      _fireStore.collection(MESSAGES_COLLECTION);

  final CollectionReference _participantsCollection =
      _fireStore.collection(PARTICIPANTS_COLLECTION);
  final List<Participant> participantsList = [];

  //add conference to DB
  Future<void> addConferenceToDb(ConferenceModel conferenceModel,
      UserModel owner, List<Participant> participants) async {
    var map = conferenceModel.toMap();
    DocumentReference documentReference = _conferenceCollection.document();
    conferenceModel = ConferenceModel(
      ownerId: owner.uid,
      id: documentReference.documentID,
      name: conferenceModel.name,
      topic: conferenceModel.topic,
      confDate: conferenceModel.confDate,
      confTime: conferenceModel.confTime,
    );

    final docRef = await _fireStore
        .collection(CONFERENCE_COLLECTION)
        .document(conferenceModel.id)
        .setData(conferenceModel.toMap())
        .then((value) {
      addParticpantsToDb(conferenceModel.id, participants);
    });
  }

  Future<void> addParticpantsToDb(
      String confID, List<Participant> participants) {
    for (var Doc in participants) {
      _fireStore
          .collection(CONFERENCE_COLLECTION)
          .document(confID)
          .collection(PARTICIPANTS_COLLECTION)
          .document(Doc.uid)
          .setData(Doc.toMap());
    }
  }

  //add participants for conference
  createListParticipants(QuerySnapshot querySnapshot) {
    var docs = querySnapshot.documents;
    for (var Doc in docs) {
      participantsList.add(Participant.fromFireStore(Doc));
    }
  }

  //get conference info by ID
  Future<ConferenceModel> getConfDetails(String confId) async {
    DocumentSnapshot documentSnapshot =
        await _conferenceCollection.document(confId).get();

    return ConferenceModel.fromMap(documentSnapshot.data);
  }

  //get participants for a conference
  Future<List<Participant>> getParticipants(
      ConferenceModel conferenceModel) async {
    QuerySnapshot querySnapshot = await _fireStore
        .collection(CONFERENCE_COLLECTION)
        .document(conferenceModel.id)
        .collection(PARTICIPANTS_COLLECTION)
        .getDocuments();

    return querySnapshot.documents
        .map((e) => Participant(
            uid: e.data['participant_id'], addedOn: e.data['added_on']))
        .toList();
  }

  //get all conferences in DB
  Future<List<ConferenceModel>> getALLConferenceList() async {
    QuerySnapshot querySnapshot =
        await _fireStore.collection(CONFERENCE_COLLECTION).getDocuments();

    return querySnapshot.documents
        .map((e) => ConferenceModel(
              name: e.data['name'],
              confDate: e.data['confDate'],
              confTime: e.data['confTime'],
              ownerId: e.data['ownerId'],
              topic: e.data['topic'],
              id: e.data['id'],
            ))
        .toList();
  }

  //get current user conference
  Future<List<ConferenceModel>> getUserConference(String currentUserId) async {
    List<ConferenceModel> allConf =
        await ConferenceMethods().getALLConferenceList();

    List<ConferenceModel> confList = List<ConferenceModel>();

    for (var i = 0; i < allConf.length; i++) {
      List<Participant> participantsList =
          await ConferenceMethods().getParticipants(allConf[i]);
      for (var j = 0; j < participantsList.length; j++) {
        if (currentUserId == participantsList[j].uid) {
          confList.add(allConf[i]);
        }
      }
      if (currentUserId == allConf[i].ownerId) {
        confList.add(allConf[i]);
      }
    }
    return confList;
  }

  //convert participant to user by ID
  Future<UserModel> participantsToUser(Participant participant) {
    return _auth.getUserDetailsById(participant.uid);
  }

  //send message to group
  sendMessage(String groupId, chatMessageData) {
    _fireStore
        .collection(CONFERENCE_COLLECTION)
        .document(groupId)
        .collection(MESSAGES_COLLECTION)
        .add(chatMessageData);

    _fireStore.collection(CONFERENCE_COLLECTION).document(groupId).updateData({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  //get chat for a group
  getChats(String groupId) {
    return _fireStore
        .collection(CONFERENCE_COLLECTION)
        .document(groupId)
        .collection(MESSAGES_COLLECTION)
        .orderBy('time')
        .snapshots();
  }
}
