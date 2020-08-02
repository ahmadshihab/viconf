import 'package:bubbleapp/provider/image_upload_provieder.dart';
import 'package:bubbleapp/provider/modal_hud.dart';
import 'package:bubbleapp/provider/user_provider.dart';

import 'package:bubbleapp/screens/search_screen.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModalHud()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider())
      ],
      child: MaterialApp(
        title: 'Bubble App',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {'/search_screen': (context) => SearchScreen()},
        theme: ThemeData(primaryColor: Color(0XFFD90746)),
        home: FutureBuilder(
          future: _authMethods.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return HomeScreen();
            } else {
              return WelcomeScreen();
            }
          },
        ),
//        initialRoute: WelcomeScreen.id,
//        routes: {
//          WelcomeScreen.id: (context) => WelcomeScreen(),
//          RegistrationScreen.id: (context) => RegistrationScreen(),
//          ChatScreen.id: (context) => ChatScreen(),
//          CreateConferenceScreen.id: (context) => CreateConferenceScreen(),
//          HomeScreen.id: (context) => HomeScreen(),
//          ContactsScreen.id: (context) => ContactsScreen(),
//          ProfileScreen.id: (context) => ProfileScreen(),
//          SearchScreen.id: (context) => SearchScreen(),
//        },
      ),
    );
  }
}
