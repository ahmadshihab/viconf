import 'package:bubbleapp/enum/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubbleapp/constants/strings.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:bubbleapp/utils/utils.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  static final Firestore fireStore = Firestore.instance;

  static final CollectionReference _userCollection =
      _fireStore.collection(USERS_COLLECTION);

  static final Firestore _fireStore = Firestore.instance;

  //get User info
  Future<UserModel> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();

    return UserModel.fromMap(documentSnapshot.data);
  }

  //get User info by id
  Future<UserModel> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _userCollection.document(id).get();

      return UserModel.fromMap(documentSnapshot.data);
    } catch (e) {
      print(e);

      return null;
    }
  }

  Future updateProfile(
      String name, String email, String profilePhoto, String currentUserId) {
    _userCollection.document(currentUserId).updateData(
        {'name': name, 'profile_photo': profilePhoto, 'email': email});
  }

  Future getUser(String uid) async {
    try {
      var userData = await _userCollection.document(uid).get();
      return UserModel.fromMap(userData.data);
    } catch (e) {
      return e.message;
    }
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  //google SignIn
  Future<FirebaseUser> signInWithGoogle() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken);

    AuthResult result = await _auth.signInWithCredential(credential);

    FirebaseUser user = result.user;

    return user;
  }

  //SignUp With email and password
  Future<FirebaseUser> signUp(
      String email, String password, String displayName) async {
    final authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser user = authResult.user;
    return user;
  }

  //SignIn With email and password
  Future<FirebaseUser> signInWithEmail(String email, String password) async {
    final authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser user = authResult.user;

    return user;
  }

  //check if user loggedIn
  Future<bool> authenticateUser(FirebaseUser user) async {
    QuerySnapshot result = await fireStore
        .collection(USERS_COLLECTION)
        .where('email', isEqualTo: user.email)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;

    return docs.length == 0 ? true : false;
  }

  // add user to database
  Future<void> addDataToDb(FirebaseUser currentUser) async {
    String userName = Utils.getUsername(currentUser.email);
    UserModel user = UserModel(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoUrl,
        username: userName);

    fireStore
        .collection(USERS_COLLECTION)
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  //SignOut
  Future<bool> signOut() async {
    try {
//      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //get all users in database without current user
  Future<List<UserModel>> fetchAllUsers(FirebaseUser currentUser) async {
    List<UserModel> usersList = List<UserModel>();

    QuerySnapshot querySnapshot =
        await fireStore.collection(USERS_COLLECTION).getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid) {
        usersList.add(UserModel.fromMap(querySnapshot.documents[i].data));
      }
    }
    return usersList;
  }

  //add the state to user Collection
  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.document(userId).updateData({'state': stateNum});
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.document(uid).snapshots();
}
