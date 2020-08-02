import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/screens/profile_screen.dart';
import 'package:bubbleapp/screens/welcome_screen.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    SignOut() async {
      final bool isLoggedOut = await AuthMethods().signOut();

      if (isLoggedOut) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
            (Route<dynamic> route) => false);
      }
    }

    return FutureBuilder<UserModel>(
      future: _authMethods.getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserModel userModel = snapshot.data;

          return Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountEmail: Text(userModel.name),
                  accountName: Text(userModel.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child:
                        Image.network(userModel.profilePhoto, fit: BoxFit.fill),
                  ),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.group),
                  title: Text('Groups'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  },
                  leading: Icon(Icons.settings),
                  title: Text('Profile settings'),
                ),
                ListTile(
                  onTap: () => SignOut(),
                  leading: Icon(Icons.power_settings_new),
                  title: Text('Logout'),
                ),
              ],
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
