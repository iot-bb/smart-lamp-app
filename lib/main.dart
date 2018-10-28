import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';

List<Widget> _children = [];

FirebaseUser _firebaseUser;
final FirebaseAuth _auth = FirebaseAuth();
//final GoogleSignIn _googleSignIn = GoogleSignIn();

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Smart Lamp',
        theme: new ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: new MyHomePage(title: 'Smart Lamp'));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();

//  Future<FirebaseUser> _handleSignIn() async {
//    try {
//      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//      FirebaseUser user = await _auth.signInWithGoogle(
//        accessToken: googleAuth.accessToken,
//        idToken: googleAuth.idToken,
//      );
//      print("signed in " + user.displayName);
//      return user;
//    } catch (error) {
//      print(error);
//      return null;
//    }
//  }

  _createFirebaseUser() {
    _auth
        .createUserWithEmailAndPassword(
            email: _emailField.text, password: _passwordField.text)
        .then((firebaseUser) {
      _firebaseUser = firebaseUser;
    }).catchError((error) {
      print("=== error: " + error);
    });
  }

  _loginFirebaseUser() {
    _auth
        .signInWithEmailAndPassword(
            email: _emailField.text, password: _passwordField.text)
        .then((firebaseUser) {
      setState(() {
        _firebaseUser = firebaseUser;
      });
    }).catchError((error) {
      print("=== error: " + error);
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      PlaceholderWidget(Colors.white),
      PlaceholderWidget(Colors.deepOrange),
      PlaceholderWidget(Colors.green),
      AccountWidget(this)
    ];
    var bottomBar = BottomNavigationBar(
      onTap: onTabTapped, // new
      currentIndex: _currentIndex,
      fixedColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.highlight,
            color: Colors.black,
          ),
          title: new Text('Lamp', style: TextStyle(color: Colors.black)),
        ),
        BottomNavigationBarItem(
          icon: new Icon(Icons.alarm, color: Colors.black),
          title: new Text(
            'Schedule',
            style: TextStyle(color: Colors.black),
          ),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.black),
            title: Text('Setting', style: TextStyle(color: Colors.black))),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle, color: Colors.black),
          title: Text('Setting', style: TextStyle(color: Colors.black)),
        )
      ],
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('Smart Lamp'),
        ),
        body: _firebaseUser != null
            ? _children[_currentIndex]
            : _buildLoginWidget(),
        bottomNavigationBar: _firebaseUser != null ? bottomBar : null);
  }

  _buildLoginWidget() {
    return ListView(
      children: <Widget>[
        Container(
          child: Text(
            'Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          padding: EdgeInsets.all(10.0),
        ),
        Container(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Email',
            ),
            controller: _emailField,
          ),
          padding: EdgeInsets.all(10.0),
        ),
        Container(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            controller: _passwordField,
            obscureText: true,
          ),
          padding: EdgeInsets.all(10.0),
        ),
        Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  child: RaisedButton(
                    onPressed: _createFirebaseUser,
                    color: Colors.black54,
                    child: Text("New Account",
                        style: TextStyle(color: Colors.white)),
                    padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                  ),
                  padding: EdgeInsets.all(10.0),
                )
              ],
              mainAxisSize: MainAxisSize.max,
            ),
            Column(children: <Widget>[
              Container(
                child: RaisedButton(
                  onPressed: _loginFirebaseUser,
                  color: Colors.black54,
                  child: Text(
                    "Sign In",
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.all(8.0),
                ),
                padding: EdgeInsets.all(10.0),
              )
            ], mainAxisSize: MainAxisSize.max)
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
        )
        //RaisedButton(onPressed: _handleSignIn, color: Colors.redAccent, child: Text("Google"),),
      ],
    );
  }
}

class AccountWidget extends StatelessWidget {
  _MyHomePageState parent;
  AccountWidget(this.parent);
  _logout() {
    _auth.signOut();
    _firebaseUser = null;
    this.parent.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              child: RaisedButton(
                onPressed: _logout,
                color: Colors.black54,
                child: Text("Logout", style: TextStyle(color: Colors.white)),
                padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
              ),
              padding: EdgeInsets.all(10.0),
            )
          ],
          mainAxisSize: MainAxisSize.max,
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
    ));
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}
