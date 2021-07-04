import 'package:flutter/material.dart';

class SideListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  SideListTile(this.text,this.icon);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0,10,10,10),
      child: Container(
          child: ListTile(
          leading: Icon(icon,
          size: 25,),
      title: Text(text),
      ),),
    );
  }
}
