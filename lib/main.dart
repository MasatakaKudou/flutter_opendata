import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';

import 'config.dart';
import 'odpt.dart';

const String app_title ='近くの駅';
const String term_of_use =
    '本アプリケーション等が利用する公共交通データは、'
    '東京公共交通オープンデータチャレンジにおいて提供されるものです。'
    '公共交通事業者により提供されたデータを元にしていますが、'
    '必ずしも正確・完全なものとは限りません。本アプリケーションの表示内容について、'
    '公共交通事業者への直接の問合せは行わないでください。'
    '本アプリケーションに関するお問い合わせは、以下のメールアドレスにお願いします。'
    '\n\n$contact_email';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: OpenData(title: 'Open-Data'),
    );
  }
}

class OpenData extends StatefulWidget {
  OpenData({Key key, this.title}) : super(key: key);
  final String title;
  @override
  OpenDataState createState() => OpenDataState();
}

class OpenDataState extends State<OpenData> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> _currentListView;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    // Setup location　// 解説1
    final Location location = Location();

    await location.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 5000);
    try {
      bool _serviceStatus = await location.serviceEnabled();
      print("Service status: $_serviceStatus");
      if (!_serviceStatus) {
        bool serviceStatusResult = await location.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          initPlatformState();
        }
        return;
      }
      bool permission = await location.requestPermission();
      print("Permission: $permission");
      if (!permission) return;
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    await for(final LocationData currentLocation
    in location.onLocationChanged()) {  // 解説2
      print('Handling location stream at:${DateTime.now()}');
      // Setup String List for ListView
      List<String> listString = [];
      final Odpt odpt = Odpt();
      List<OdptStation> listStation =
      await odpt.placesStation(currentLocation); // 解説3
      if (listStation == null) {
        print('There is no or an error response from DDPT-API.');
        listString.add('オープンデータAPIにアクセスできないか、エラーが返却されました');
      } else if (listStation.isEmpty) {
        print('There is no station around here.');
        listString.add('近くに駅はみつかりませんでした');
      } else {
        final Distance distance = Distance();
        for(OdptStation element in listStation) {
          listString.add(
              '${element.dcTitle}: '
                  '${distance(LatLng(currentLocation.latitude,
                  currentLocation.longitude),
                  LatLng(element.geoLat, element.geoLong)).toString()}m'
          );
        }
      }
      setState(() {  // 解説4
        _currentListView = listString;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) => DefaultTabController(  // 解説5
    length: 2,
    initialIndex: 0,
    child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
              tabs: <Widget>[
                Tab(text: 'ホーム', icon: Icon(Icons.home,),),
                Tab(text: '利用条件', icon: Icon(Icons.info,),),
              ]
          )
      ),

      body: TabBarView(
        children: <Widget>[
          _currentListView == null
              ? CircularProgressIndicator()
              : ListView.builder(   // 解説6
              itemCount: _currentListView.length,
              itemBuilder: (context, int index) => Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(_currentListView[index]),
              )
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(term_of_use),
          ),
        ],
      ),
    ),
  );
}