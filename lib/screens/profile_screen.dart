import 'dart:io';
import 'dart:math';
import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/provider/image_upload_provieder.dart';
import 'package:bubbleapp/screens/callscreen/pickup_layout.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:bubbleapp/services/storage_methods.dart';
import 'package:bubbleapp/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthMethods _authMethods = AuthMethods();
  final StorageMethods _storageMethods = StorageMethods();
  String _profileImage;
  String _currentImage;
  UserModel user;
  String _currentUserId;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  File _imageFile;

  String path = '/profile/images/';

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((user) {
      _currentUserId = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return PickupLayout(
      scaffold: FutureBuilder(
        future: _authMethods.getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserModel userModel = snapshot.data;
            name.text = userModel.name;
            email.text = userModel.email;
            _currentImage = userModel.profilePhoto;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0XFFD90746),
                title: Center(
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: (Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30.0,
                  )),
                ),
                actions: <Widget>[
                  Center(
                      child: Padding(
                          padding: EdgeInsets.only(right: 15.0),
                          child: InkWell(
                            onTap: () async {
                              if (_profileImage == null) {
                                await await _authMethods.updateProfile(
                                    name.text,
                                    email.text,
                                    _currentImage,
                                    _currentUserId);
                              } else {
                                await await _authMethods.updateProfile(
                                    name.text,
                                    email.text,
                                    _profileImage,
                                    _currentUserId);
                              }

                              print(email.text);
                              print(name.text);
                              print(_currentImage);
                              print(_profileImage);
                            },
                            child: Text(
                              'SAVE',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.w600),
                            ),
                          )))
                ],
              ),
              body: Column(
                children: <Widget>[
                  Container(
                    color: Color(0XFFD90746),
                    height: height * .3,
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                              borderRadius: BorderRadius.circular(60.0),
                              child: Image.network(
                                userModel.profilePhoto,
                                height: height * 0.25,
                                width: height * 0.25,
                                fit: BoxFit.cover,
                              )),
                          Container(
                            height: height * 0.15,
                            width: width * 0.15,
                            decoration: BoxDecoration(
                                color: Color(0XFF0D1B32),
                                shape: BoxShape.circle),
                            child: Center(
                              child: IconButton(
                                onPressed: () =>
                                    pickImage(source: ImageSource.gallery),
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(32.0),
                      children: <Widget>[
                        Text(
                          'Display Name',
                          style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: name,
                          style: TextStyle(fontWeight: FontWeight.w600),
//                          onSaved: (value) {
//                            _displayName = value;
//                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Email',
                          style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: email,
                          style: TextStyle(fontWeight: FontWeight.w600),
//                          onChanged: (value) {
//                            _email = value;
//                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Password',
                          style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold),
                        ),
                        TextFormField(),
                        SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    selectedImage = await ImageCropper.cropImage(
        sourcePath: selectedImage.path, maxWidth: 150, maxHeight: 150);
    setState(() {
      _imageFile = selectedImage;
    });
//    _storageMethods.uploadImage(
//      image: selectedImage,
//      senderId: _currentUserId,
//      imageUploadProvider: _imageUploadProvider,
//      path: path,
//    );
    _profileImage =
        await _storageMethods.uploadImageToStorage(selectedImage, path);
  }

//  Future<void> _cropImage() async {
//    File _cropeImage = await ImageCropper.cropImage(
//        sourcePath: _imageFile.path, maxHeight: 150, maxWidth: 150);
//  }
}
