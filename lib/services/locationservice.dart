import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:e_taxi/utilities/config.dart';
import 'package:e_taxi/datamodels/direction.dart';

class LocationService extends ChangeNotifier {
  Position? position;
  String? startlatitude;
  String? startlongitude;
  String? endlatitude;
  String? endlongitude;
  String? url;
  String? useraddress;
  String? destination;
  Directions? direction;
  String calculateFare(){
    //perKm=10
    //baseFare=50
    //perHour=40
    double baseFare=50;
    double distanceFare=(10*this.direction!.distancevalue)/1000;
    double timeFare=40*this.direction!.durationvalue/60;
    double totalFare=baseFare+distanceFare+timeFare;
    return totalFare.toStringAsFixed(2);
  }
  Future<void> getUserAddress(String latitude, String longitude) async {
    this.startlatitude = latitude;
    this.startlongitude = longitude;
    url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${this
        .startlatitude},${this.startlongitude}&key=$mapapiKey';
    // print('Inside Reverse Location URL generated: $url');
    try {
      http.Response response = await http.get(Uri.parse(url!));
      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        useraddress = decodedData["results"][0]["formatted_address"];
        print('Updated user address: $useraddress');
     //   notifyListeners();
      }
      else
        throw 'Failed to fetch user address data with response code: ${response.statusCode}';
    }
    catch (e) {
      throw 'Failed to fetch user address data with error: $e';
    }
  }
    Future<void> setDestinationAddress(String latitude,
        String longitude) async {
      this.endlatitude = latitude;
      this.endlongitude = longitude;
      url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${this
          .endlatitude},${this.endlongitude}&key=$mapapiKey';
      // print('Inside Reverse Location URL generated: $url');
      try {
        http.Response response = await http.get(Uri.parse(url!));
        if (response.statusCode == 200) {
          String data = response.body;
          var decodedData = jsonDecode(data);
          destination = decodedData["results"][0]["formatted_address"];
          print('Updated destination address: $destination');
       //   notifyListeners();
        }
        else
          throw 'Failed to fetch destination data with response code: ${response
              .statusCode}';
      }
      catch (e) {
        throw 'Failed to fetch destination data with error: $e';
      }
    }
    Future<void> getDirection() async{
      String url='https://maps.googleapis.com/maps/api/directions/json?origin=$startlatitude,$startlongitude&destination=$endlatitude,$endlongitude&mode=driving&key=$mapapiKey';
      print('Url in getdestination: $url');
      try{
        http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          String data = response.body;
          var decodedData = jsonDecode(data);
          String polyLines=decodedData["routes"][0]["overview_polyline"]["points"];
          print('Polylines: $polyLines');
          String distancetext=decodedData["routes"][0]["legs"][0]["distance"]["text"];
          print ('Distance Text: $distancetext');
          int distancevalue=decodedData["routes"][0]["legs"][0]["distance"]["value"];
          print ('Distance value: $distancevalue');
          String durationtext=decodedData["routes"][0]["legs"][0]["duration"]["text"];
          print('Duration Text: $durationtext');
          int durationvalue=decodedData["routes"][0]["legs"][0]["duration"]["value"];
          print('Duration value: $durationvalue');
          direction=Directions(distancevalue,durationvalue,durationtext,distancetext,polyLines);
       //   notifyListeners();
        }
        else
          throw 'Failed to direction data with response code: ${response
              .statusCode}';
      }
      catch(e){
        throw 'Failed to fetch destination data with error: $e';
      }
    }
  }