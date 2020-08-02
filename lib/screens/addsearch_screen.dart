import 'package:bubbleapp/screens/callscreen/pickup_layout.dart';
import 'package:bubbleapp/widgets/MyCircleAvatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';

class AddSearchScreen extends StatefulWidget {
  static const String id = 'search_screen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<AddSearchScreen> {
//  DatabaseService databaseService = DatabaseService();

  var _controller = TextEditingController();
  String _name;

  QuerySnapshot searchSnapshot;

//  initiateSearch() {
//    databaseService.getUsersByName(_name).then((val) {
//      setState(() {
//        searchSnapshot = val;
//      });
//    });
//  }

  Widget SearchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                name: searchSnapshot.documents[index].data['name'],
                email: searchSnapshot.documents[index].data['email'],
              );
            })
        : Container();
  }

  @override
  void initState() {
//    initiateSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: GradientText(
              'Add Contact',
              gradient: LinearGradient(
                  colors: [Color(0XFFD90746), Color(0xFFEB402C)]),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          leading: InkWell(
            onTap: () {/* Write listener code here */},
            child: Icon(
              Icons.arrow_back,
              color: Color(0XFFD90746),
              size: 30.0, // add custom icons also
            ),
          ),
          actions: <Widget>[
            Center(
                child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: InkWell(
                      onTap: () {
//                      initiateSearch();
                      },
                      child: Text(
                        'SEARCH',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFFD90746)),
                      ),
                    )))
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controller,
                onChanged: (value) {
                  _name = value;
                },
                decoration: InputDecoration(
                    hintText: ('Search...'),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                        })),
              ),
              SearchList(),

              //SearchTile(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {
  final String name;
  final String email;

  SearchTile({this.email, this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12.0),
      child: Row(
        children: <Widget>[
          MyCircleAvatar(),
          SizedBox(width: 16.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: Theme.of(context).textTheme.subtitle1,
                overflow: TextOverflow.clip,
              ),
              Text(email),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              minWidth: 30,
              color: Color(0XFFD90746),
              onPressed: () {},
              child: Text(
                'Add',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//class DataSearch extends SearchDelegate<String> {
//  @override
//  List<Widget> buildActions(BuildContext context) {
//    throw UnimplementedError();
//    return [];
//  }
//
//  @override
//  Widget buildLeading(BuildContext context) {
//    // TODO: implement buildLeading
//    throw UnimplementedError();
//  }
//
//  @override
//  Widget buildResults(BuildContext context) {
//    // TODO: implement buildResults
//    throw UnimplementedError();
//  }
//
//  @override
//  Widget buildSuggestions(BuildContext context) {
//    // TODO: implement buildSuggestions
//    throw UnimplementedError();
//  }
//}
