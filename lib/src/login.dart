import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teamflutterfa_sfhacks2021/src/views/home_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String email, password, username;

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
    return "Login Successfully";
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
                padding: EdgeInsets.fromLTRB(30, 60, 30, 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Login", style: TextStyle(fontSize: 50)),
                    SizedBox(height: 50),
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
                    SizedBox(height: 15),
                    Text(
                      "Forgot Password?",
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.blueAccent, fontSize: 18),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            color: Colors.lightBlueAccent,
                            textColor: Colors.white,
                            child: Text("Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            onPressed: () async {
                              List data;
                              CollectionReference collectionReference =
                                  Firestore.instance.collection('User_Data');
                              collectionReference
                                  .snapshots()
                                  .listen((snapshot) {
                                data = snapshot.documents;
                                for (int i = 0; i < data.length; i++) {
                                  if (data[i]['email'] == email) {
                                    if (data[i]['password'] == password) {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeView()));
                                      break;
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Your provided password is wrong",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM_RIGHT,
                                      );
                                    }
                                  }
                                }
                              });
                            },
                          ),
                        ),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.5,
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
                        "Don't have an Account? Create one",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
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
