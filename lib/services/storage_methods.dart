import 'package:bubbleapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bubbleapp/provider/image_upload_provieder.dart';
import 'package:bubbleapp/services/chat_methods.dart';
import 'package:flutter/widgets.dart';

class StorageMethods {
  static final Firestore firestore = Firestore.instance;

  StorageReference _storageReference;

  UserModel user = UserModel();

  //add Image to firebase storage
  Future<String> uploadImageToStorage(File imageFile, String path) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('$path${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask =
          _storageReference.putFile(imageFile);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();

//      print(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  //get image from database
  void uploadImage(
      {@required File image,
      String receiverId,
      @required String senderId,
      @required String path,
      @required ImageUploadProvider imageUploadProvider}) async {
    final ChatMethods chatMethods = ChatMethods();

    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image, path);

    // Hide loading
    imageUploadProvider.setToIdle();
    if (path == '/chat/images/') {
      chatMethods.setImageMsg(url, receiverId, senderId);
    }
  }
}
