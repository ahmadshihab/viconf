import 'package:bubbleapp/services/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubbleapp/models/message_model.dart';
import 'package:bubbleapp/constants/strings.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bubbleapp/models/contacts.dart';
import 'package:flutter/widgets.dart';

class ChatMethods {
  static final Firestore _fireStore = Firestore.instance;

  final CollectionReference _messageCollection =
      _fireStore.collection(MESSAGES_COLLECTION);
  final CollectionReference _userCollection =
      _fireStore.collection(USERS_COLLECTION);
  AuthMethods _authMethods = AuthMethods();

  //Add message to database
  Future<void> addMessageToDb(
      MessageModel message, UserModel sender, UserModel receiver) async {
    var map = message.toMap();
    await _fireStore
        .collection(MESSAGES_COLLECTION)
        .document(message.senderId)
        .collection(message.receiverId)
        .add(map);

    //add contacts when send a message
    addToContacts(
      senderId: message.senderId,
      receiverId: message.receiverId,
    );

    return await _fireStore
        .collection(MESSAGES_COLLECTION)
        .document(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  //create contact collection
  DocumentReference getContactsDocument({String of, String forContact}) =>
      _userCollection
          .document(of)
          .collection(CONTACTS_COLLECTION)
          .document(forContact);

  //add contacts to sender and receiver
  addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .setData(receiverMap);
    }
  }

  Future<void> addToReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId, forContact: senderId)
          .setData(senderMap);
    }
  }

  //add image message to database
  void setImageMsg(String url, String receiverId, String senderId) async {
    MessageModel _messageModel;

    _messageModel = MessageModel.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'image');

    // create imagemap
    var map = _messageModel.toImageMap();

    // var map = Map<String, dynamic>();
    await _messageCollection
        .document(_messageModel.senderId)
        .collection(_messageModel.receiverId)
        .add(map);

    _messageCollection
        .document(_messageModel.receiverId)
        .collection(_messageModel.senderId)
        .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
      .document(userId)
      .collection(CONTACTS_COLLECTION)
      .snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({
    @required String senderId,
    @required String receiverId,
  }) =>
      _messageCollection
          .document(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();

  // get list of the contact
  Future<List<UserModel>> contactList(FirebaseUser user) async {
    List<UserModel> usersList = List<UserModel>();

    QuerySnapshot querySnapshot = await _fireStore
        .collection(USERS_COLLECTION)
        .document(user.uid)
        .collection(CONTACTS_COLLECTION)
        .getDocuments();

    for (var i = 0; i < querySnapshot.documents.length; i++) {
      String uid = (querySnapshot.documents[i].documentID);
      UserModel userModel = await _authMethods.getUserDetailsById(uid);
      usersList.add(userModel);
//      usersList.add(UserModel.fromMap(querySnapshot.documents[i].data);
    }
    return usersList;
  }
}
