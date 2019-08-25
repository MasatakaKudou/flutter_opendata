import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

const String base_uri ='https://api-tokyochallenge.odpt.org/api/v4/';

// rdf:type of odpt:Station
class OdptStation {  // 解説7
  final String context;
  final String id;
  final String type;
  final String dcDate;
  final String owlSameAs;
  final String dcTitle;
  final String odptOperator;
  final String odptRailway;
  final String odptStationCode;
  final double geoLong;
  final double geoLat;

  OdptStation.fromJson(Map<String, dynamic> json)
      : context = json['@context'],
        id = json['@id'],
        type = json['@tyoe'],
        dcDate = json['dc:date'],
        owlSameAs = json['owl:sameAs'],
        dcTitle = json['dc:title'],
        odptOperator = json['odpt:operator'],
        odptRailway = json['odpt:railway'],
        odptStationCode = json['odpt:stationCode'],
        geoLong = json['geo:long'],
        geoLat = json['geo:lat'];
}

class Odpt {
  // places API with odpt:Station  // 解説8
  Future<List<OdptStation>> placesStation(
      LocationData location, [int radius = 1000]) async {
    if (location == null) return null;
    final String requestUri =
        '${base_uri}places/odpt:Station?lon='
        '${location.longitude.toString()}&lat=${location.latitude.toString()}'
        '&radius=${radius.toString()}&acl:consumerKey=$apikey_opendata';
    print('Getting: $requestUri at:${DateTime.now()}');
    http.Response response;
    try {
      response = await http.get(requestUri).timeout(Duration(seconds: 10));
    } catch (e) {
      print(e);
      return null;
    }
    print('Got response at:${DateTime.now()}');
    if (response.statusCode == 200) {
      List<OdptStation> list = [];
      List<dynamic> decoded = json.decode(response.body);
      for (var item in decoded) {
        list.add(OdptStation.fromJson(item));
      }
      print('Success to call places API.');
      return list;
    } else {
      print('Fail to call places API.');
      return null;
    }
  }
}