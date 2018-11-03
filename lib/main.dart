import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:barcode_scan/barcode_scan.dart';

List<Widget> _children = [];

FirebaseUser _firebaseUser;
final FirebaseAuth _auth = FirebaseAuth();
var token = '';

//final GoogleSignIn _googleSignIn = GoogleSignIn();

FlutterBlue flutterBlue = FlutterBlue.instance;

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
  TextEditingController _emailField;
  TextEditingController _passwordField;
  bool isLogging = false;

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
  @override
  void initState() {
    super.initState();
    _emailField = TextEditingController(text: 'tortechnocom@gmail.com');
    _passwordField = TextEditingController(text: '12345789');
  }

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
    setState(() {
      isLogging = true;
    });
    _auth
        .signInWithEmailAndPassword(
            email: _emailField.text, password: _passwordField.text)
        .then((firebaseUser) {
      setState(() {
        _firebaseUser = firebaseUser;
        firebaseUser.getIdToken().then((idToken) {
          print("====token: " + idToken);
          isLogging = false;
          token = idToken;
        });
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
      Lamp(),
      PlaceholderWidget(Colors.black54),
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
          title: new Text('Lamp', style: TextStyle(color: _currentIndex == 0 ? Colors.amber : Colors.black)),
        ),
        BottomNavigationBarItem(
          icon: new Icon(Icons.alarm, color: Colors.black),
          title: new Text(
            'Schedule',
            style: TextStyle(color: _currentIndex == 1 ? Colors.amber : Colors.black),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle, color: Colors.black),
          title: Text('Setting', style: TextStyle(color: _currentIndex == 2 ? Colors.amber : Colors.black)),
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

  _buildProgressBarTile() {
    return new LinearProgressIndicator();
  }
  _buildLoginWidget() {
    return ListView(
      children: <Widget>[
        isLogging ? _buildProgressBarTile() : Container(),
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
                    onPressed: isLogging ? null : _createFirebaseUser,
                    color: isLogging ? Colors.grey : Colors.black54,
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
                  onPressed: isLogging ? null : _loginFirebaseUser,
                  color: isLogging ? Colors.grey : Colors.black54,
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

// ignore: must_be_immutable
class AccountWidget extends StatefulWidget {
  _MyHomePageState parent;

  AccountWidget(this.parent);

  @override
  _AccountWidget createState() => new _AccountWidget(this.parent);
}

class _AccountWidget extends State<AccountWidget> {
  _MyHomePageState parent;
  _AccountWidget(this.parent);
  bool deviceSaving = false;


  String barcode = "";
  TextEditingController wifiName;
  TextEditingController wifiPassword;

  _logout() {
    _auth.signOut();
    _firebaseUser = null;
    this.parent.setState(() {});
  }

  FlutterBlue _flutterBlue = FlutterBlue.instance;

  // Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;

  // State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  // Device
  BluetoothDevice device;

  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  BluetoothCharacteristic characteristic;

  var params = [];
  var data = "";

  @override
  void initState() {
    super.initState();
    // Immediately get the state of FlutterBlue
    _flutterBlue.state.then((s) {
      setState(() {
        state = s;
      });
    });
    // Subscribe to state changes
    _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
      setState(() {
        state = s;
      });
    });

    wifiName = new TextEditingController(text: 'TOR-WIFI');
    wifiPassword = new TextEditingController(text: '12345789');
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    super.dispose();
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  _buildProgressBarTile() {
    return new LinearProgressIndicator();
  }

  _startScan() {
    scanResults.clear();
    _scanSubscription = _flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((scanResult) {
      print('localName: ${scanResult.advertisementData.localName}');
      setState(() {
        if (scanResult.advertisementData.localName.isNotEmpty) {
          scanResults[scanResult.device.id] = scanResult;
          if (params.length == 3) {
            if (params[0] == scanResult.device.id.toString() &&
                isConnected == false) {
              _stopScan();
              _connect(scanResult.device);
            }
          }
        }
      });
    }, onDone: _stopScan);

    setState(() {
      isScanning = true;
    });
  }

  _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    barcode = "";
    setState(() {
      isScanning = false;
    });
  }

  _disconnect() {
    // Remove all value changed listeners
    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    barcode = "";
    setState(() {
      device = null;
      characteristic = null;
    });
  }

  _connect(BluetoothDevice d) async {
    device = d;
    // Connect to device
    deviceConnection = _flutterBlue
        .connect(device, timeout: const Duration(seconds: 4))
        .listen(
          null,
          onDone: null,
        );

    // Update the connection state immediately
    device.state.then((s) {
      setState(() {
        deviceState = s;
      });
    });

    // Subscribe to connection changes
    deviceStateSubscription = device.onStateChanged().listen((s) {
      print("====== state changed");
      setState(() {
        deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        device.discoverServices().then((s) {
          setState(() {
            services = s;
            services.forEach((ser) {
              ser.characteristics.forEach((char) {
                print("====== uuid: " + char.uuid.toString());
                if (char.properties.write) {
                  setState(() {
                    characteristic = char;
                  });
                }
              });
            });
          });
        });
      } else if (s == BluetoothDeviceState.disconnected) {
        print("====== state disconnected");
        setState(() {
          _disconnect();
          _startScan();
        });
      }
    });
  }

  List<Widget> buildDeviceListView() {
    return scanResults.values
        .map((r) => Container(
              child: RaisedButton(
                onPressed: () => _connect(r.device),
                child: Text(r.advertisementData.localName),
                color: Colors.blue,
                textColor: Colors.white,
                splashColor: Colors.blueGrey,
              ),
              padding: EdgeInsets.all(10.0),
            ))
        .toList();
  }

  saveCharToDevice(json20) async {
    await device.writeCharacteristic(
        characteristic,
        json20,
        type: CharacteristicWriteType.withoutResponse
    ).then((success) {
      setState(() {
        deviceSaving = false;
      });
    }).catchError((error) {
      print(error);
    });
  }

  void saveDeviceSetting() {
    deviceSaving = true;
//    var json = '{"ssid":"' + wifiName.text + '","password":"' + wifiPassword.text + '","token":"' + token + '"}';
    var json = '{"ssid":"' + wifiName.text + '","password":"' + wifiPassword.text + '"}';
//    print("===== json: " + json);
    var jsonList = json.codeUnits;
    var json20 = new List<int>();
    var size = jsonList.length;
    var count = 0;
    jsonList.forEach((intData) {
      json20.add(intData);
      if (json20.length == 20 || (size - 1) == count) {
        saveCharToDevice(json20);
        json20 = new List<int>();
      }
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var qrBtn = Container(
        padding: EdgeInsets.all(4.0),
        child: RaisedButton(
          onPressed: scan,
          color: isScanning ? Colors.grey : Colors.black54,
          child: Text("Scan QR Code",
            style: TextStyle(color: Colors.white),
          ))
    );
    var scanBtn = Container(
      padding: EdgeInsets.all(4.0),
        child:
        RaisedButton(
            onPressed: isScanning ? null : _startScan,
            color: isScanning ? Colors.grey : Colors.black54,
            child: Text("Search Device",
            style: TextStyle(color: Colors.white),
            ))
    );
    var bleRow = Row(
      children: <Widget>[qrBtn, scanBtn],
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
    );
    var disconnectBtn = RaisedButton(
        onPressed: () => _disconnect(), child: new Text("Disconnect"));
    var accountRow = Row(children: <Widget>[
      Container(
        child: Text(_firebaseUser.email, style: TextStyle(fontWeight: FontWeight.bold),),
        padding: EdgeInsets.all(10.0),
      ),
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
      mainAxisAlignment: MainAxisAlignment.center,
    );
    var deviceSetting = Column(children: <Widget>[
      Container(child: Text('Device Settting', style: TextStyle(fontWeight: FontWeight.bold),),),
      Container(child: TextField(controller: wifiName, decoration: InputDecoration(labelText: 'WiFi Name'),),
        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      ),
      Container(child: TextField(controller: wifiPassword, decoration: InputDecoration(labelText: 'WiFi Password'),
        obscureText: true,),
        padding: EdgeInsets.fromLTRB(20, 0, 0, 0)
      ),
      Container(child: RaisedButton(
        onPressed: deviceSaving ? null : saveDeviceSetting,
        color: (deviceSaving || isConnected == false) ? Colors.grey : Colors.black54,
        child: Text("Save Device Setting", style: TextStyle(color: Colors.white),),
      ),
          padding: EdgeInsets.fromLTRB(20, 10, 0, 0)
      )
    ],
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
    );
    return Container(child: Column(
      children: <Widget>[
        (isScanning || deviceSaving) ? _buildProgressBarTile() : Container(),
        accountRow,
        Container(
            child: isConnected ? disconnectBtn : bleRow),
        (scanResults != null && isConnected == false)
            ? new Flexible(child: new ListView(children: buildDeviceListView()))
            : new Container(child: deviceSetting,)
      ],
      mainAxisSize: MainAxisSize.max,
    ),
      color: Colors.black54,
    );
  }
}

class Lamp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(child: 
    Container(
      padding: EdgeInsets.all(8.0),
      width: (double.infinity * 0.5),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        shape: BoxShape.circle,
        color: Colors.black54,
      ),
    ),
      padding: EdgeInsets.all(20),
      color: Colors.black54,
    );
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
