import 'package:flutter/material.dart';
//import 'package:csv/csv.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

const String app_title ='近くの駅';
const String term_of_use =
    '本アプリケーション等が利用するデータは、'
    '函館市の公式サイトによって、提供されるものです。'
    '公共交通事業者により提供されたデータを元にしていますが、'
    '必ずしも正確・完全なものとは限りません。本アプリケーションの表示内容について、'
    '本アプリケーションに関するお問い合わせは、以下のメールアドレスにお願いします。 \n'
    'nisino7se@gmail.com';


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

  final _stringList = [];
  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/tyoubetsuH3101.csv');
  }

  void _buildStringList() async {
    setState(() {
      loadAsset().then((String value){
        setState(() {
          print(value);
          var _splitString = value.split("\n");
          if(_splitString.length > _stringList.length){
            _stringList.addAll([]..length = _splitString.length);
            for(var i=0; i<_stringList.length; i++) {
              _stringList[i] = _splitString[i];
            }
          }
        });
      });
    });
}

  Widget _buildStringListView() {
    _buildStringList();
    return ListView.builder(
      padding: EdgeInsets.all(10.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        final index = i ~/ 2;
        return _buildString(_stringList[index]);
      },
    );
  }

  Widget _buildString(var stringList){
    return Card(
      child: Container(
        height: 100.0,
        width: double.infinity,
        color: Colors.deepOrange,
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        child: Text(stringList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2, //タブの数
    child: Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () async {
          }),
      appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
              tabs: <Widget>[
                Tab(text: 'ホーム', icon: Icon(Icons.home)),
                Tab(text: '利用条件', icon: Icon(Icons.info)),
              ]
          )
      ),

      body: TabBarView(
        children: <Widget>[
          _buildStringListView(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(term_of_use),
          ),
        ],
      ),
    ),
  );
}