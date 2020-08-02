import 'package:bubbleapp/screens/home_screen.dart';
import 'package:bubbleapp/screens/registration_screen.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import 'file:///E:/Android%20Projects/flutter_app/bubble_app/lib/widgets/rounded_textfield.dart';
import 'package:provider/provider.dart';
import 'package:bubbleapp/models/user_model.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  AuthMethods _authMethods = AuthMethods();

  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Form(
        key: _globalKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [const Color(0XFFD90746), const Color(0xFFEB402C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
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
                          email = value;
                        },
                        obscureText: false,
                        hintText: 'yourmailid@mail.com',
                      ),
                      SizedBox(height: height * .03),
                      RoundedTextField(
                        onClick: (value) {
                          password = value;
                        },
                        obscureText: true,
                        hintText: 'your password',
                      ),
                      SizedBox(height: height * .1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Material(
                            elevation: 5.0,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                            child: Builder(
                              builder: (context) => MaterialButton(
                                onPressed: () async {
                                  if (_globalKey.currentState.validate()) {
                                    try {
                                      _globalKey.currentState.save();
                                      performLogin(email, password);
//                                    final authResult =
//                                        await _auth.signIn(email, password);
//
//                                    Navigator.pushNamed(context, HomeScreen.id);
                                    } catch (e) {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(e.message),
                                      ));
                                    }
                                  }
                                },
                                minWidth: width * 0.3,
                                height: height * .08,
                                child: GradientText(
                                  'SIGN IN',
                                  gradient: LinearGradient(colors: [
                                    Color(0XFFD90746),
                                    Color(0xFFEB402C)
                                  ]),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Material(
                            elevation: 5.0,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                            child: MaterialButton(
                              onPressed: () => performLoginWithGoogle(),
                              minWidth: width * 0.3,
                              height: height * .08,
                              child: GradientText(
                                'Goolge SIGN IN',
                                gradient: LinearGradient(colors: [
                                  Color(0XFFD90746),
                                  Color(0xFFEB402C)
                                ]),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * .03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(width: 6.0),
                          InkWell(
                            onTap: () {
                              setState(() {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return RegistrationScreen();
                                }));
                              });
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void performLoginWithGoogle() {
    _authMethods.signInWithGoogle().then((FirebaseUser user) {
      if (user != null) {
        authenticateUser(user);
      } else {
        print('There was error');
      }
    });
  }

  void performLogin(String email, String password) {
    _authMethods.signInWithEmail(email, password).then((FirebaseUser user) {
      if (user != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      } else {
        print('there was erorr');
      }
    });
  }

  void authenticateUser(FirebaseUser user) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        _authMethods.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
