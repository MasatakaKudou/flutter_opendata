import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:csv/csv.dart';
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

  List<List<dynamic>> data = [];

  loadCSV() async {
    final myData = await rootBundle.loadString("assets/SalesJan2009.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);

    data = csvTable;
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    initialIndex: 0,
    child: Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () async {
            await loadCSV();
            print(data);
          }),
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
          Table(
            columnWidths: {
              0: FixedColumnWidth(100.0),
              1: FixedColumnWidth(200.0),
            },
            border: TableBorder.all(width: 1.0),
            children: data.map((item) {
              return TableRow(
                  children: item.map((row) {
                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          row.toString(),
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    );
                  }).toList()
              );
            }).toList(),
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