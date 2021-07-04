import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? name;
  String? phone;
  String? email;
  String? id;
  UserModel({this.name,this.phone,this.email});
  UserModel.fromSnapshot(DataSnapshot snapshot)
  {
    id=snapshot.key;
    phone=snapshot.value['phonenumber'];
    email=snapshot.value['email'];
    name=snapshot.value['name'];
  }
}