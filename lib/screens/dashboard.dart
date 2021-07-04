import 'dart:async';
import 'package:e_taxi/components/sidenavigation.dart';
import 'package:e_taxi/screens/searchscreen.dart';
import 'package:e_taxi/utilities/constants.dart';
import 'package:e_taxi/datamodels/users.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:e_taxi/services/locationservice.dart';
import 'package:provider/provider.dart';
import 'package:e_taxi/components/selectpaymentmethod.dart';
import 'package:e_taxi/services/riderequest.dart';

class DashBoard extends StatefulWidget {
  static const id = 'dashboard';
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String name = '';
  String phonenumber = '';
  String? userAddress = '';
  bool visibleRideRequest = false;
  String destinationText = 'Search Destination';
  TextEditingController search = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  GoogleMapController? mapController;
  Position? currentLocation;
  bool permissionStatus = true;
  bool rideDetails = false;
  DatabaseReference? dbref;
  LocationPermission? permission;
  Set<Polyline> polylineSet = {};
  Set<Marker> markers = {};
  Set<Circle> locationCircles = {};
  List<LatLng> polyLineCoord = [];
  String totalFare = '0';
  String selectedvalue = 'Cash';
  int distancevalue = 0;
  UserModel? userInfo;
  void setPayment(String value) {
    setState(() {
      selectedvalue = value;
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Completer<GoogleMapController> _controller = Completer();
  void resetDestination() {
    setState(() {
      destinationText = 'Search Destination';
      polylineSet.clear();
      markers.clear();
      locationCircles.clear();
      polyLineCoord.clear();
    });
  }

  Future<void> setPermission() async {
    PermissionStatus permissionstatus =
        await LocationPermissions().checkPermissionStatus();
    if (permissionstatus == PermissionStatus.denied) {
      PermissionStatus permission =
          await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.denied) permissionStatus = false;
      print('Current permission: $permission');
    }
  }

  void setLatLngBound() {
    print('Inside setLatLngBound');
    var pickupLat = double.parse(
        Provider.of<LocationService>(context, listen: false)
            .startlatitude
            .toString());
    assert(pickupLat is double);
    var pickupLong = double.parse(
        Provider.of<LocationService>(context, listen: false)
            .startlongitude
            .toString());
    assert(pickupLong is double);
    var destLat = double.parse(
        Provider.of<LocationService>(context, listen: false)
            .endlatitude
            .toString());
    assert(destLat is double);
    var destLong = double.parse(
        Provider.of<LocationService>(context, listen: false)
            .endlongitude
            .toString());
    assert(destLong is double);
    LatLng pickupLatLng = LatLng(pickupLat, pickupLong);
    LatLng destLatLng = LatLng(destLat, destLong);
    LatLngBounds bounds;
    if (pickupLat > destLat && pickupLong > destLong)
      bounds = LatLngBounds(southwest: destLatLng, northeast: pickupLatLng);
    else if (pickupLong > destLong)
      bounds = LatLngBounds(
          southwest: LatLng(pickupLat, destLong),
          northeast: LatLng(destLat, pickupLong));
    else if (pickupLat > destLat)
      bounds = LatLngBounds(
          southwest: LatLng(destLat, pickupLong),
          northeast: LatLng(pickupLat, destLong));
    else
      bounds = LatLngBounds(southwest: pickupLatLng, northeast: destLatLng);
    Circle pickupCircle = Circle(
        circleId: CircleId('pickupCircle'),
        fillColor: Colors.green,
        radius: 10,
        strokeWidth: 4,
        center: pickupLatLng,
        strokeColor: Colors.lightGreen);
    Circle destCircle = Circle(
        circleId: CircleId('destCircle'),
        fillColor: Colors.red,
        radius: 10,
        strokeWidth: 4,
        center: destLatLng,
        strokeColor: Colors.redAccent);
    Marker pickupMarker = Marker(
        markerId: MarkerId('pickmarkerID'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: pickupLatLng,
        infoWindow: InfoWindow(title: userAddress, snippet: 'My Location'));
    Marker destMarker = Marker(
        markerId: MarkerId('destmarkerID'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: destLatLng,
        infoWindow: InfoWindow(title: destinationText, snippet: 'Destination'));
    setState(() {
      markers.add(pickupMarker);
      markers.add(destMarker);
      locationCircles.add(pickupCircle);
      locationCircles.add(destCircle);
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    });
  }

  void setPolyPoints() {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(
        Provider.of<LocationService>(context, listen: false)
            .direction!
            .encodedPoints);
    if (results.isNotEmpty) {
      print('Got polyline coordinates');
      polyLineCoord.clear();
      results.forEach((PointLatLng points) {
        polyLineCoord.add(LatLng(points.latitude, points.longitude));
      });
      polylineSet.clear();
      locationCircles.clear();
      markers.clear();
      setState(() {
        Polyline polyline = Polyline(
            polylineId: PolylineId('polylineId'),
            color: Colors.blueAccent,
            points: polyLineCoord,
            jointType: JointType.round,
            width: 4,
            startCap: Cap.squareCap,
            endCap: Cap.squareCap,
            geodesic: true);
        polylineSet.add(polyline);
        setLatLngBound();
      });
    }
  }

  Future<void> getLocation() async {
    if (permissionStatus == true) {
      Position position = await GeolocatorPlatform.instance.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      currentLocation = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      print('Position is : $pos');
      try {
        await Provider.of<LocationService>(context, listen: false)
            .getUserAddress(
                position.latitude.toString(), position.longitude.toString());
      } catch (e) {
        print(e);
      }
      setState(() {
        userAddress =
            Provider.of<LocationService>(context, listen: false).useraddress;
      });
      print(
          'User address is : ${Provider.of<LocationService>(context, listen: false).useraddress}');
    }
  }

  void setLocationOnMap() {
    LatLng pos = LatLng(currentLocation!.latitude, currentLocation!.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    mapController!.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  @override
  void initState() {
    setPermission();
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) { getLocation();
   /* print('User Name: ${kCurrentUserInfo!.name}');
    print('Email: ${kCurrentUserInfo!.email}');
    print('Phone number: ${kCurrentUserInfo!.phone}'); */
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldkey,
      drawer: SideNavigation(),
      body: Stack(children: [
        Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.65,
              child: (userAddress == '' || userAddress == null)
                  ? Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      circles: locationCircles,
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      //   zoomGesturesEnabled: true,
                      // myLocationButtonEnabled: true,
                      markers: markers,
                      initialCameraPosition: _kGooglePlex,
                      polylines: polylineSet,
                      onMapCreated: (GoogleMapController controller) async {
                        mapController = controller;
                        _controller.complete(controller);
                        setLocationOnMap();
                      },
                    ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 25,
                        offset: Offset(0.8, 0.8),
                        color: Colors.black38,
                        spreadRadius: 0.8)
                  ]),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Where are you going ?',
                      style: TextStyle(
                          fontFamily: 'Bolt',
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                offset: Offset(0.5, 0.5),
                                color: Colors.black26,
                                spreadRadius: 0.6)
                          ]),
                      child: ListTile(
                        leading: Icon(
                          Icons.search_rounded,
                          size: 25,
                          color: Colors.blue,
                        ),
                        title: GestureDetector(
                          onTap: () async {
                            var result = await Navigator.pushNamed(
                                context, SearchScreen.id);
                            if (result == 'Got Destination') {
                              setState(() {
                                destinationText = Provider.of<LocationService>(
                                        context,
                                        listen: false)
                                    .destination
                                    .toString();
                                setPolyPoints();
                                distancevalue = Provider.of<LocationService>(
                                        context,
                                        listen: false)
                                    .direction!
                                    .distancevalue;
                                totalFare = Provider.of<LocationService>(
                                        context,
                                        listen: false)
                                    .calculateFare();
                                rideDetails = true;
                              });
                            } else {
                              setState(() {
                                destinationText = 'Search Destination';
                              });
                            }
                          },
                          child: Text(
                            destinationText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: ListTile(
                        leading: Icon(
                          Icons.home_outlined,
                          size: 25,
                        ),
                        title: Text('Add Home'),
                        subtitle: Text('Your Home Address'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Divider(
                        thickness: 1,
                        color: Colors.black12,
                        height: 1,
                      ),
                    ),
                    Container(
                      child: ListTile(
                        leading: Icon(
                          Icons.work_outlined,
                          size: 25,
                        ),
                        title: Text('Add Work'),
                        subtitle: Text('Your Work Address'),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        Positioned(
          top: 50,
          left: 10,
          child: CircleAvatar(
            child: IconButton(
                onPressed: () {
                  if (rideDetails == true) {
                    setState(() {
                      rideDetails = false;
                    });
                    resetDestination();
                  } else
                    scaffoldkey.currentState!.openDrawer();
                },
                icon: Icon(
                  rideDetails == false ? Icons.menu : Icons.arrow_back_ios,
                  size: 25,
                  color: Colors.grey,
                )),
            radius: 25,
            backgroundColor: Colors.white,
          ),
        ),
        Visibility(
            visible: rideDetails,
            child: Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 25,
                          offset: Offset(0.8, 0.8),
                          color: Colors.black38,
                          spreadRadius: 0.8)
                    ]),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20.0, 10, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0XEA90EE90),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: ListTile(
                            leading: Icon(Icons.local_taxi_rounded),
                            title: Text('Taxi'),
                            trailing: Text('\₹$totalFare'),
                            subtitle: Text('${distancevalue / 1000} KM')),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SelectPaymentMethod(selectedvalue, setPayment),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Material(
                        elevation: 5.0,
                        color: kdefaultColour,
                        borderRadius: BorderRadius.circular(30.0),
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              rideDetails = false;
                              visibleRideRequest = true;
                              dbref=RideRequest.createRequest(context, selectedvalue);
                            });
                          },
                          minWidth: 200.0,
                          height: 42.0,
                          child: Text(
                            'Request Cab',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
        Visibility(
            child: Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 25,
                      offset: Offset(0.8, 0.8),
                      color: Colors.black38,
                      spreadRadius: 0.8)
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: LinearProgressIndicator(
                    color: Colors.grey,
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20,0,20,0),
                  child: Text(
                    'Searching for a Ride...',
                    style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Bolt',
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      resetDestination();
                      RideRequest.deleteRequest(dbref!);
                      visibleRideRequest = false;
                    });
                  },
                  icon: Icon(
                    Icons.cancel,
                  ),
                  iconSize: 80,
                  color: Colors.grey,
                ),
                Text('Cancel Ride', style: kappbarStyle)
              ],
            ),
          ),
        ),
        visible: visibleRideRequest,)
      ]),
    );
  }
}
