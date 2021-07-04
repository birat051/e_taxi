import 'package:e_taxi/utilities/constants.dart';
import 'package:flutter/material.dart';

class PlaceList extends StatelessWidget {
  final String maintext;
  final String secondaryText;
  PlaceList(this.maintext,this.secondaryText);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.location_on_rounded
      ),
      title: Text(maintext,style: kappbarStyle,),
      subtitle: Text(secondaryText),
    );
  }
}
