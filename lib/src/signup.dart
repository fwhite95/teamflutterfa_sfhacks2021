import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamflutterfa_sfhacks2021/src/views/home_view.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String email, password, username, contact;
  int flag = 0;

  Future<String> googleSignIn() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(authCredential);

    final User user = userCredential.user;

    assert(user.email != null);
    assert(user.displayName != null);

    setState(() {
      username = user.displayName;
      email = user.email;
    });

    final User currentUser = await _firebaseAuth.currentUser;
    assert(currentUser.uid == user.uid);
    return "SignUp Successfully";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(30, 40, 30, 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Sign Up", style: TextStyle(fontSize: 40)),
                    SizedBox(height: 40),
                    TextField(
                      decoration: new InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(30.0),
                          ),
                        ),
                        hintText: "Username",
                      ),
                      onChanged: (value) {
                        setState(() {
                          username = value.trim();
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    TextField(
                      decoration: new InputDecoration(
                        prefixIcon: Icon(Icons.mail),
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(30.0),
                          ),
                        ),
                        hintText: "Email Address",
                      ),
                      onChanged: (value) {
                        setState(() {
                          email = value.trim();
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    TextField(
                      decoration: new InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(30.0),
                          ),
                        ),
                        hintText: "Contact Number",
                      ),
                      onChanged: (value) {
                        setState(() {
                          contact = value.trim();
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    TextField(
                      obscureText: true,
                      decoration: new InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(30.0),
                          ),
                        ),
                        hintText: "Password",
                      ),
                      onChanged: (value) {
                        setState(() {
                          password = value.trim();
                        });
                      },
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            color: Colors.lightBlueAccent,
                            textColor: Colors.white,
                            child: Text("Sign Up",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            onPressed: () async {
                              List getInfo;
                              Map<String, dynamic> data = {
                                "username": username,
                                "email": email,
                                "contactNo": contact,
                                "password": password
                              };
                              CollectionReference collectionReference =
                                  Firestore.instance.collection('User_Data');
                              collectionReference
                                  .snapshots()
                                  .listen((snapshot) {
                                getInfo = snapshot.documents;
                                for (int i = 0; i < getInfo.length; i++) {
                                  if (email == getInfo[i]['email']) {
                                    flag = 1;
                                    break;
                                  }
                                }
                              });
                              if (flag == 0) {
                                collectionReference.add(data).then((_) {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => HomeView()));
                                });
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                      "Your provided Email Address already existed.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM_RIGHT,
                                );
                              }
                            },
                          ),
                        ),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            color: Colors.lightBlueAccent,
                            textColor: Colors.white,
                            child: Text("Google SignIn",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            onPressed: () async {
                              googleSignIn().whenComplete(() => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeView()))
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    GestureDetector(
                      child: Text(
                        "Account Already Existed! Login",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
