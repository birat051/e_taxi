import 'package:e_taxi/utilities/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:e_taxi/services/locationservice.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class RideRequest {
  static DatabaseReference createRequest(BuildContext context,String paymentMethod) {
    DatabaseReference dbref =
        FirebaseDatabase.instance.reference().child('riderequests').push();
    Map pickupMap = {
      'latitude': Provider.of<LocationService>(context, listen: false)
          .startlatitude
          .toString(),
      'longitude': Provider.of<LocationService>(context, listen: false)
          .startlongitude
          .toString(),
      'pickup': Provider.of<LocationService>(context, listen: false)
          .useraddress
          .toString()
    };
    Map destMap = {
      'latitude': Provider.of<LocationService>(context, listen: false)
          .endlatitude
          .toString(),
      'longitude': Provider.of<LocationService>(context, listen: false)
          .endlongitude
          .toString(),
      'destination': Provider.of<LocationService>(context, listen: false)
          .destination
          .toString()
    };
    Map userData = {
      'name': kCurrentUserInfo!.name,
      'phone': kCurrentUserInfo!.phone,
      'email': kCurrentUserInfo!.email,
      'driverID': 'Waiting',
      'paymentmethod': paymentMethod
    };
    Map ridedetails={
      'ridedata': userData,
      'pickupdata': pickupMap,
      'destdata': destMap
    };
    dbref.set(ridedetails);
    return dbref;
  }

  static void deleteRequest(DatabaseReference dbref) {
    dbref.remove();
  }
}
