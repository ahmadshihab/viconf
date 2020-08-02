import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/provider/user_provider.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactsTile extends StatelessWidget {
  final contact;
  final double height;
  final double width;

  final AuthMethods _authMethods = AuthMethods();

  ContactsTile({this.contact, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserModel userModel = snapshot.data;

          return ViewLayout(
            contact: userModel,
            height: height,
            width: width,
          );
        }
        return Row();
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final UserModel contact;
  final double height;
  final double width;

  ViewLayout({@required this.contact, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return GestureDetector(
      onTap: () {

      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        contact.profilePhoto,
                        fit: BoxFit.cover,
                        height: height,
                        width: width,
                      ),
                    ),
//              Positioned(
//                  right: 0,
//                  child: new Container(
//                    padding: EdgeInsets.all(1),
//                    decoration: new BoxDecoration(
//                      color: Colors.red,
//                      borderRadius: BorderRadius.circular(6),
//                    ),
//                    constraints: BoxConstraints(
//                      minWidth: 12,
//                      minHeight: 12,
//                    ),
//                  ))
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                contact.name,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
