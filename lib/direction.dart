import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project/detailWebView.dart';
import 'package:project/roadGuide.dart';

class DirectionsAndRestaurantsScreen extends StatefulWidget {
  final String startAddress;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  const DirectionsAndRestaurantsScreen({
    Key? key,
    required this.startAddress,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
  }) : super(key: key);

  @override
  _DirectionsAndRestaurantsScreenState createState() => _DirectionsAndRestaurantsScreenState();
}

class _DirectionsAndRestaurantsScreenState extends State<DirectionsAndRestaurantsScreen> with SingleTickerProviderStateMixin {
  late GoogleMapController _mapController;
  late LatLng _secondpoint;
  late LatLng _firstpoint;
  late LatLng _thirdpoint;
  List<dynamic> _restaurants = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _secondpoint = getMidpoint(widget.startLat, widget.startLng, widget.endLat, widget.endLng);
    _firstpoint = getMidpoint(widget.startLat, widget.startLng, _secondpoint.latitude, _secondpoint.longitude);
    _thirdpoint = getMidpoint(_secondpoint.latitude, _secondpoint.longitude, widget.endLat, widget.endLng);
    _fetchNearbyRestaurants();
    _tabController = TabController(length: 2, vsync: this);
  }

  LatLng getMidpoint(double startLat, double startLng, double endLat, double endLng) {
    final lat1 = startLat * pi / 180;
    final lon1 = startLng * pi / 180;
    final lat2 = endLat * pi / 180;
    final lon2 = endLng * pi / 180;

    final dLon = lon2 - lon1;

    final Bx = cos(lat2) * cos(dLon);
    final By = cos(lat2) * sin(dLon);

    final lat3 = atan2(
      sin(lat1) + sin(lat2),
      sqrt(
        (cos(lat1) + Bx) * (cos(lat1) + Bx) + By * By
      )
    );
    final lon3 = lon1 + atan2(By, cos(lat1) + Bx);

    return LatLng(lat3 * 180 / pi, lon3 * 180 / pi);
  }

  Future<void> _fetchNearbyRestaurants() async {
    final apiKey = 'AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y'; // 환경변수로 API 키를 처리하는 것이 좋습니다
    final radius = 5000; // 5km radius
    final firstUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_firstpoint.latitude},${_firstpoint.longitude}'
        '&radius=$radius'
        '&type=restaurant'
        '&language=ko'
        '&key=$apiKey';
    final secondUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_secondpoint.latitude},${_secondpoint.longitude}'
        '&radius=$radius'
        '&type=restaurant'
        '&language=ko'
        '&key=$apiKey';
    final thirdUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_thirdpoint.latitude},${_thirdpoint.longitude}'
        '&radius=$radius'
        '&type=restaurant'
        '&language=ko'
        '&key=$apiKey';

    final firstResponse = await http.get(Uri.parse(firstUrl));
    final secondResponse = await http.get(Uri.parse(secondUrl));
    final thirdResponse = await http.get(Uri.parse(thirdUrl));

    if (firstResponse.statusCode == 200 && secondResponse.statusCode == 200 && thirdResponse.statusCode == 200) {
      final firstData = jsonDecode(firstResponse.body);
      final secondData = jsonDecode(secondResponse.body);
      final thirdData = jsonDecode(thirdResponse.body);
      setState(() {
        _restaurants.addAll(firstData['results']);
        _restaurants.addAll(secondData['results']);
        _restaurants.addAll(thirdData['results']);
      });
    } else {
      throw Exception('Failed to load nearby restaurants');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가다 뭐먹지?'),
        backgroundColor: Colors.blue[200],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Restaurants'),
            Tab(text: 'Map'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRestaurantsList(),
          Stack(
            children: [
              _buildMapView(),
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _moveToPosition(_firstpoint),
                      child: Text('첫번째 지점'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _moveToPosition(_secondpoint),
                      child: Text('두번째 지점'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _moveToPosition(_thirdpoint),
                      child: Text('세번째 지점'),
                    ),
                  ],
                ),
              )
            ]
          )
        ],
      ),
    );
  }

  Widget _buildRestaurantsList() {
    return ListView.builder(
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return Card(
          child: ExpansionTile(
            title: Text(
              restaurant['name'],
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text(
                "도로명 주소: ${restaurant['vicinity']}"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "도로명 주소: ${restaurant['vicinity']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text("음식점 이름: ${restaurant['name']}"),
                    SizedBox(height: 8),
                    Text("음식점 평점: ${restaurant['rating']}"),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailWebView(
                                restaurant: restaurant['vicinity']
                              )
                            ),
                          ),
                          child: Text("정보 보기"),
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.blue),
                          ),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RoadGuide(
                                startAddress: widget.startAddress,
                                endAddress: restaurant['vicinity'],
                                startLat: widget.startLat.toString(),
                                startLng: widget.startLng.toString(),
                                endLat: restaurant['geometry']['location']['lat'].toString(),
                                endLng: restaurant['geometry']['location']['lng'].toString()
                              ),
                            ),
                          ),
                          child: Text("경로 찾기"),
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView() {

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_firstpoint.latitude, _firstpoint.longitude),
        zoom: 12,
      ),
      markers: _restaurants.map((restaurant) {
        return Marker(
          markerId: MarkerId(restaurant['place_id']),
          position: LatLng(restaurant['geometry']['location']['lat'], restaurant['geometry']['location']['lng']),
          infoWindow: InfoWindow(
            title: restaurant['name'],
            snippet: restaurant['vicinity'],
          ),
        );
      }).toSet(),
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
  void _moveToPosition(LatLng position) {
    _mapController.animateCamera(CameraUpdate.newLatLng(position));
  }
}
