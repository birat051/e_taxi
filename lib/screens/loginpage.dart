import 'dart:ui';
import 'package:e_taxi/screens/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_taxi/utilities/constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'registration.dart';

class LoginPage extends StatefulWidget {
  static const id='loginpage';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final GlobalKey<ScaffoldState> scaffoldkey=GlobalKey<ScaffoldState>();
    bool _saving=false;
    String phonenumber='';
    String email='';
    String name='';
    String password='';
    void showSnackBar(String title)
    {
      final snackbar=SnackBar(content: Text(title,style: ksnackbarStyle,),backgroundColor: kdefaultColour,);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
    Future<void> signInUser() async
    {
      FirebaseAuth auth=FirebaseAuth.instance;
      bool isSuccess=true;
      setState(() {
        _saving=true;
      });
      try{
      await auth.signInWithEmailAndPassword(email: email, password: password).catchError((e){
        setState(() {
          _saving=false;
        });
        isSuccess=false;
        showSnackBar('Incorrect Username or Password!');
      });}
      catch(e){
        print(e);
      }
      finally {
        if (isSuccess)
          Navigator.pushNamedAndRemoveUntil(
              context, DashBoard.id, (route) => false);
      }
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: scaffoldkey,
        body:
        Builder(
          builder: (context)=> LoadingOverlay(
            isLoading: _saving,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Image(
                        image: AssetImage(
                            'assets/images/uberclonelogo.png'),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        onChanged: (value) {
                          email = value;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email Id',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        onChanged: (value) {
                          password = value;
                        },
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Bolt'
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.pushNamedAndRemoveUntil(context, Registration.id, (route) => false);
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Bolt'
                                ),
                              ),
                            )
                          ],
                        )
                    ),
                    Expanded(
                      flex: 1,
                      child: Material(
                        elevation: 5.0,
                        color: kdefaultColour,
                        borderRadius: BorderRadius.circular(30.0),
                        child: MaterialButton(
                          onPressed: ()async
                          {
                            FocusScope.of(context).unfocus();
                            if (!email.contains('@'))
                              showSnackBar('Please provide a valid email address');
                            else
                          await signInUser();
                          },
                          minWidth: 200.0,
                          height: 42.0,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),),
      );
  }
}
