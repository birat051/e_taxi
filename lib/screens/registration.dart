import 'package:e_taxi/screens/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:e_taxi/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:loading_overlay/loading_overlay.dart';

class Registration extends StatefulWidget {
  static const String id = 'registration';
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String phonenumber = '';
  String email = '';
  String name = '';
  String password = '';
  bool _saving=false;
  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        style: ksnackbarStyle,
      ),
      backgroundColor: kdefaultColour,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future<void> createUser() async {
    bool userCreated = true;
    FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential? authresult;
    try {
      setState(() {
        _saving=true;
      });
      authresult = await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .catchError((Object e) {
        print(e);
        throw e;
      });
    } catch (e) {
      userCreated = false;
      print(userCreated);
      showSnackBar('Unexpected error: Unable to Create User');
    } finally {
      print('Inside finally: $userCreated');
      setState(() {
        _saving=false;
      });
      if (userCreated) {
        DatabaseReference? dbref = FirebaseDatabase.instance
            .reference()
            .child('users/${authresult!.user!.uid}');
        Map usermap = {
          'name': name,
          'email': email,
          'phonenumber': phonenumber
        };
        dbref.set(usermap);
        auth.signOut();
        Navigator.pushNamedAndRemoveUntil(
            context, LoginPage.id,(route)=>false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
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
                    image: AssetImage('assets/images/uberclonelogo.png'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    onChanged: (value) {
                      name = value;
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                    ),
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
                      phonenumber = value;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
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
                          'Already have an account?',
                          style: TextStyle(fontSize: 20, fontFamily: 'Bolt'),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, LoginPage.id, (route) => false);
                            },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Bolt'),
                              ),
                          ),
                      ],
                    )),
                Expanded(
                  flex: 1,
                  child: Material(
                    elevation: 5.0,
                    color: kdefaultColour,
                    borderRadius: BorderRadius.circular(30.0),
                    child: MaterialButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (name.length < 3)
                          showSnackBar('Please enter your full name');
                        else if (!email.contains('@'))
                          showSnackBar('Please provide a valid email address');
                        else if (phonenumber.length != 10)
                          showSnackBar('Please provide a valid phone number');
                        else if (password.length < 8)
                          showSnackBar(
                              'Please provide a password with 8 characters or more');
                        else {
                          createUser();
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),)
    );
  }
}
