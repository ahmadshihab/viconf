import 'package:bubbleapp/models/particpants_model.dart';
import 'package:bubbleapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConferenceModel {
  String id;
  String name;
  String ownerId;
  String topic;
  Timestamp confTime;
  List<Participant> participants;
  Timestamp confDate;

  ConferenceModel(
      {this.id,
      this.name,
      this.ownerId,
      this.topic,
      this.confTime,
      this.participants,
      this.confDate});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['id'] = this.id;
    map['ownerId'] = this.ownerId;
    map['name'] = this.name;
    map['topic'] = this.topic;
    map['confTime'] = this.confTime;
//    map['participants'] = this.participants;
    map['confDate'] = this.confDate;
    return map;
  }

  ConferenceModel.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.ownerId = map['ownerId'];
    this.name = map['name'];
    this.topic = map['topic'];
    this.confTime = map['confTime'];
//    this.participants = map['participants'];
    this.confDate = map['confDate'];
  }
}
