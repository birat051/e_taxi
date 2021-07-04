import 'dart:convert';
import 'package:e_taxi/datamodels/predictions.dart';
import 'package:e_taxi/services/locationservice.dart';
import 'package:e_taxi/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:e_taxi/utilities/config.dart';
import 'package:e_taxi/components/placelist.dart';
import 'package:e_taxi/datamodels/address.dart';

class SearchScreen extends StatefulWidget {
  static const id = 'searchscreen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchText=TextEditingController();
  TextEditingController destinationText=TextEditingController();
  FocusNode focusDestination=FocusNode();
   List<Prediction>? suggestion;
   List<PlaceList>? placeList;
   int suggestionslength=0;
   bool visibility=true;
   bool isLoading=false;
   Future<void> getPlaceDetails(String placeId) async{
     setState(() {
       isLoading=true;
     });
     String url='https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$mapapiKey';
     http.Response response = await http.get(Uri.parse(url));
     if (response.statusCode == 200) {
       String data = response.body;
       var decodedData = jsonDecode(data);
    //   print(decodedData);
       if(decodedData['status']=='OK') {
         Address address = Address(decodedData['result']['formatted_address'].toString(),
             decodedData['result']['geometry']['location']['lat'].toString(),
             decodedData['result']['geometry']['location']['lng'].toString());
         await Provider.of<LocationService>(context,listen: false).setDestinationAddress(address.latitude, address.longitude);
         setState(() {
           destinationText.text=Provider.of<LocationService>(context,listen: false).destination.toString();
         });
       }
     }
     await Provider.of<LocationService>(context,listen: false).getDirection();
     setState(() {
       isLoading=false;
     });
     Navigator.of(context).pop('Got Destination');
   }
  Future<void> searchPlace(String value) async{
   if(value.length>1)
     {
       String url='https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$mapapiKey&sessiontoken=123254251&components=country:in';
       try {
         http.Response response = await http.get(Uri.parse(url));
         if (response.statusCode == 200) {
           String data = response.body;
           var decodedData = jsonDecode(data);
         if(decodedData['status']=='OK') {
           var  jsonResponse=decodedData['predictions'];
           var suggestion1 = (jsonResponse as List)
               .map((e) => Prediction.fromJson(e))
               .toList();
           setState(() {
             suggestion=suggestion1;
             suggestionslength=suggestion!.length;
           });
         }
         }
         else
           throw 'Failed to fetch data';
       }
       catch (e) {
         throw 'Failed to fetch data with error: $e';
       }
     }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        searchText.text=Provider.of<LocationService>(context,listen:false).useraddress??'Unable to fetch address';
        FocusScope.of(context).requestFocus(focusDestination);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set Destination',
          style: kappbarStyle,
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
      ),
        body: Builder(
          builder:(context)=> LoadingOverlay(
            isLoading: isLoading,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height*0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black
                      )
                    ),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.06,
                          child: ListTile(
                            leading: Icon(Icons.adjust_outlined,
                            color: Colors.green,),
                            title:TextField(
                              decoration: InputDecoration(
                                hintText: 'Pickup Location',
                                fillColor: Color(0XFFd3d3d3),
                                border: InputBorder.none,
                                filled: true,
                                isDense: true
                              ),
                              controller: searchText,
                            ),),
                        ),
                        SizedBox(
                          height:MediaQuery.of(context).size.height*0.04,
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: (){
                                var value=searchText.text;
                                setState(() {
                                  searchText.text=destinationText.text;
                                  destinationText.text=value;
                                });
                              },
                              child: Icon(Icons.swap_vert,
                              color: Colors.grey,),
                            ),
                          ),
                        ),
                        SizedBox(
                        height: MediaQuery.of(context).size.height*0.06,
                          child: ListTile(
                            leading: Icon(Icons.location_on_rounded,
                              color: Colors.grey,),
                            title:  TextField(
                              onChanged: (value) async{
                                setState(() {
                                  value==''?visibility=false:visibility=true;
                                });
                                try {
                                  await searchPlace(value);
                                }
                                catch(e){
                                  print('Unable to fetch address: $e');
                                }
                              },
                              controller: destinationText,
                              focusNode: focusDestination,
                              decoration: InputDecoration(
                                  hintText: 'Where to?',
                                  fillColor: Color(0XFFd3d3d3),
                                  filled: true,
                                  isDense: true,
                                border: InputBorder.none
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(height: 10),
                Expanded(child: suggestionslength>0?
                  Visibility(
                    child: ListView.separated(
                      itemBuilder: (context,index){
                        return GestureDetector(child: PlaceList(suggestion![index].mainText, suggestion![index].secondaryText),
                          onTap: () async{
                            await getPlaceDetails(suggestion![index].placeId);
                          },
                        );
                      },
                      itemCount: suggestionslength,
                      shrinkWrap: true,
                      separatorBuilder: (context,index){return Padding(
                        padding: const EdgeInsets.fromLTRB(10,0,10,0),
                        child: Divider(thickness: 0.3,color: Colors.grey,),
                      );},
                    ),visible: visibility,
                  ):Container(),
                  flex: 8,
                )
              ],
            ),
          ),
        ),
    );
  }
}
