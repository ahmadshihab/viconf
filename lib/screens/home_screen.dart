import 'package:bubbleapp/enum/user_state.dart';
import 'package:bubbleapp/models/conference_model.dart';
import 'package:bubbleapp/provider/user_provider.dart';
import 'package:bubbleapp/screens/callscreen/pickup_layout.dart';
import 'package:bubbleapp/screens/conference/confirmation_screen.dart';
import 'package:bubbleapp/screens/conference/upcomingCalls_screen.dart';
import 'file:///E:/Android%20Projects/flutter_app/bubble_app/lib/widgets/quiet_box.dart';
import 'file:///E:/Android%20Projects/flutter_app/bubble_app/lib/screens/conference/createconference_screen.dart';
import 'file:///E:/Android%20Projects/flutter_app/bubble_app/lib/screens/contact/history_screen.dart';
import 'package:bubbleapp/screens/addsearch_screen.dart';
import 'package:bubbleapp/services/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gradient_text/gradient_text.dart';
import 'file:///E:/Android%20Projects/flutter_app/bubble_app/lib/screens/conference/confirmation_screen.dart';
import 'package:bubbleapp/screens/contacts_screen.dart';
import 'package:bubbleapp/widgets/appdrawer.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final AuthMethods _authMethods = AuthMethods();
  UserProvider userProvider;
  TabController _tabController;
  bool showFab = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      _authMethods.setUserState(
          userId: userProvider.getUser.uid, userState: UserState.Online);
    });

    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 1, length: 3);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        showFab = true;
      } else {
        showFab = false;
      }
      setState(() {});
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        (userProvider != null && userProvider.getUser != null)
            ? userProvider.getUser.uid
            : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.9,
          title: Center(
            child: GradientText(
              'VICONF',
              gradient: LinearGradient(
                  colors: [Color(0XFFD90746), Color(0xFFEB402C)]),
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bottom: TabBar(
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0XFFD90746)),
                top: BorderSide(color: Colors.black12),
                left:
                    BorderSide(color: Colors.black12), // provides to left side
                right: BorderSide(color: Colors.black12), // for right side
              ),
            ),
            labelColor: Color(0xFF3e4e68),
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                text: 'Upcoming calls',
              ),
              Tab(
                text: 'History',
              ),
              Tab(
                text: 'Contacts',
              )
            ],
          ),
          leading: IconButton(
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
            icon: Icon(
              Icons.menu,
              color: Color(0XFFD90746),
              size: 30.0,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search_screen');
              },
              icon: Icon(
                Icons.search,
                color: Color(0XFFD90746),
                size: 30.0,
              ),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            UpcomingScreen(),
            HistoryScreen(),
            ContactsScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0XFFD90746),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateConferenceScreen()));
          },
        ),
      ),
    );
  }
}
