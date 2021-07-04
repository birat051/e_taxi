import 'package:e_taxi/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:e_taxi/datamodels/users.dart';

class UserData{
  static void fetchUserData() {
  //  print('Inside fetch User Data');
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    DatabaseReference dbref = FirebaseDatabase.instance.reference().child(
        'users/${user!.uid}');
    dbref.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null)
        print('Got snapshot');
        kCurrentUserInfo=UserModel.fromSnapshot(snapshot);
      /*  print(kCurrentUserInfo!.phone);
        print(kCurrentUserInfo!.email);
        print(kCurrentUserInfo!.name);
        print(kCurrentUserInfo!.id); */
    }
    );
  }
}