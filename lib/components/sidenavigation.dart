import 'package:e_taxi/screens/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_taxi/components/sidenavigationlist.dart';
import 'package:e_taxi/utilities/constants.dart';

class SideNavigation extends StatelessWidget {
  String getUserName(){
    String? name;
  if(kCurrentUserInfo!=null)
  name=kCurrentUserInfo!.name.toString();
  else name='User Name';
  return name;
  }
  @override
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context).size.width;
    return Container(
      width: width*0.75,
      child: Drawer(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(10, 60, 10, 20),
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person,
                      size: 50,
                      color: Colors.white,),
                  ),
            SizedBox(height: 20,),
            Text('${getUserName()}',style: TextStyle(
                fontFamily: 'Bolt',
                fontSize: 25,
                fontWeight: FontWeight.bold
            ),
            ),
            SizedBox(height: 20),
              Text('View Profile',
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10,20,10,10),
                child: Divider(thickness: 1,color: Colors.black12,height: 1,),
              ),
              SideListTile('Free Rides', Icons.card_giftcard_outlined),
              SideListTile('Payments', Icons.payment_outlined),
              SideListTile('Ride History', Icons.history_outlined),
              SideListTile('Support', Icons.support_outlined),
              SideListTile('About', Icons.info_outline_rounded),
              Padding(
                padding: const EdgeInsets.fromLTRB(10,10,10,20),
                child: Divider(thickness: 1,color: Colors.black12,height: 1,),
              ),
              GestureDetector(
                child: Text(
                  'Logout',style: TextStyle(
                fontSize: 25
                ),
                ),
                onTap: () async{
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}