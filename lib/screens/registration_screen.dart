import 'package:bubbleapp/provider/modal_hud.dart';
import 'package:bubbleapp/screens/home_screen.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'file:///E:/Android%20Projects/flutter_app/bubble_app/lib/widgets/rounded_textfield.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  AuthMethods _authMethods = AuthMethods();

  Firestore fireStore = Firestore.instance;
  String _email, _password, _displayName;
  String _profilePhoto =
      'https://cdn4.iconfinder.com/data/icons/social-messaging-ui-color-and-shapes-3/177800/130-512.png';
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: Provider.of<ModalHud>(context).isLoading,
        child: Form(
          key: _globalKey,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0XFFD90746),
                    const Color(0xFFEB402C)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  height: height,
                  child: ListView(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * .2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Text(
                              'VICONF',
                              style: TextStyle(
                                  fontFamily: 'Pacifico',
                                  fontSize: height * .05,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            ),
                            Positioned(
                              bottom: 25,
                              child: Text('Group Calling app',
                                  style: TextStyle(
                                      color: Colors.white30, fontSize: 20.0)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * .1),
                      RoundedTextField(
                        onClick: (value) {
                          _displayName = value;
                        },
                        obscureText: false,
                        hintText: 'display name',
                      ),
                      SizedBox(height: height * .02),
                      RoundedTextField(
                        onClick: (value) {
                          _email = value;
                        },
                        obscureText: false,
                        hintText: 'yourmailid@mail.com',
                      ),
                      SizedBox(height: height * .02),
                      RoundedTextField(
                        onClick: (value) {
                          _password = value;
                        },
                        obscureText: true,
                        hintText: 'your password',
                      ),
                      SizedBox(height: height * .02),
//                      RoundedTextField(
//                        obscureText: true,
//                        hintText: 'confirm your password',
//                      ),
                      SizedBox(height: height * .1),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * .17),
                        child: Material(
                          elevation: 5.0,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          child: Builder(
                            builder: (context) => MaterialButton(
                              onPressed: () async {
                                final modalHud = Provider.of<ModalHud>(context,
                                    listen: false);

                                modalHud.changeIsLoading(true);

                                if (_globalKey.currentState.validate()) {
                                  _globalKey.currentState.save();
                                  try {
                                    performSignUp(
                                        _email, _password, _displayName);

//                                    final authResult =
//                                        await _auth.signUp(_email, _password);
//                                    FirebaseUser user = authResult.user;
//                                    await DatabaseService(uid: user.uid)
//                                        .updateUserData(_displayName, _email);
//                                    modalHud.changeIsLoading(false);
//                                    Navigator.pushNamed(context, HomeScreen.id);
                                  } catch (e) {
                                    modalHud.changeIsLoading(false);
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: (Text(e.message)),
                                    ));
                                  }
                                }
                                modalHud.changeIsLoading(false);
                              },
                              minWidth: 400.0,
                              height: height * .08,
                              child: GradientText(
                                'SIGN UP',
                                gradient: LinearGradient(colors: [
                                  Color(0XFFD90746),
                                  Color(0xFFEB402C)
                                ]),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void performSignUp(String email, String password, String displayName) {
    _authMethods.signUp(email, password, displayName).then((FirebaseUser user) {
      _authMethods.addDataToDb(user).then((value) {
        fireStore
            .collection("users")
            .document(user.uid)
            .updateData({'name': displayName, 'profile_photo': _profilePhoto});
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      });
    });
  }
}
