import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  String uid;
  String name;
  Timestamp addedOn;

  Participant({this.uid, this.addedOn, this.name});

  Map toMap() {
    var data = Map<String, dynamic>();
    data['participant_id'] = this.uid;
    data['added_on'] = this.addedOn;
    data['name'] = this.name;
    return data;
  }

  Participant.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['contact_id'];
    this.addedOn = mapData["added_on"];
    this.name = mapData["name"];
  }

  factory Participant.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data;
    return Participant(
        uid: data['participant_id'],
        addedOn: data['added_on'],
        name: data["name"]);
  }
}
