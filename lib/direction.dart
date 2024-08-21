  import 'dart:math';
  import 'package:flutter/material.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:http/http.dart' as http;
  import 'package:project/detailView.dart';
  import 'dart:convert';

  import 'package:project/detailWebView.dart';
  import 'package:project/roadGuide.dart';
  import 'package:url_launcher/url_launcher.dart';

  class DirectionsAndRestaurantsScreen extends StatefulWidget {
    final String startAddress;
    final String endAddress;
    final double startLat;
    final double startLng;
    final double endLat;
    final double endLng;

    const DirectionsAndRestaurantsScreen({
      Key? key,
      required this.startAddress,
      required this.endAddress,
      required this.startLat,
      required this.startLng,
      required this.endLat,
      required this.endLng,
    }) : super(key: key);

    @override
    _DirectionsAndRestaurantsScreenState createState() =>
        _DirectionsAndRestaurantsScreenState();
  }

  class _DirectionsAndRestaurantsScreenState
      extends State<DirectionsAndRestaurantsScreen>
      with SingleTickerProviderStateMixin {
    late GoogleMapController _mapController;
    late LatLng _secondpoint;
    late LatLng _firstpoint;
    late LatLng _thirdpoint;
    List<Map<String, dynamic>> _firstRestaurants = [];
    List<Map<String, dynamic>> _secondRestaurants = [];
    List<Map<String, dynamic>> _thirdRestaurants = [];
    List<Map<String, dynamic>> _totalRestaurants = [];
    late TabController _tabController;
    String? _selectedPoint;

    @override
    void initState() {
      super.initState();
      _secondpoint = getMidpoint(
          widget.startLat, widget.startLng, widget.endLat, widget.endLng);
      _firstpoint = getMidpoint(widget.startLat, widget.startLng,
          _secondpoint.latitude, _secondpoint.longitude);
      _thirdpoint = getMidpoint(_secondpoint.latitude, _secondpoint.longitude,
          widget.endLat, widget.endLng);
      _fetchNearbyRestaurants();
      _tabController = TabController(length: 2, vsync: this);
    }

    LatLng getMidpoint(
        double startLat, double startLng, double endLat, double endLng) {
      final lat1 = startLat * pi / 180;
      final lon1 = startLng * pi / 180;
      final lat2 = endLat * pi / 180;
      final lon2 = endLng * pi / 180;

      final dLon = lon2 - lon1;

      final Bx = cos(lat2) * cos(dLon);
      final By = cos(lat2) * sin(dLon);

      final lat3 = atan2(sin(lat1) + sin(lat2),
          sqrt((cos(lat1) + Bx) * (cos(lat1) + Bx) + By * By));
      final lon3 = lon1 + atan2(By, cos(lat1) + Bx);

      return LatLng(lat3 * 180 / pi, lon3 * 180 / pi);
    }

    Future<void> _fetchNearbyRestaurants() async {
      final apiKey =
          'AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y'; // 환경변수로 API 키를 처리하는 것이 좋습니다
      final radius = 5000; // 5km radius
      final firstUrl =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=${_firstpoint.latitude},${_firstpoint.longitude}'
          '&radius=$radius'
          '&type=restaurant'
          '&language=ko'
          '&key=$apiKey';
      final secondUrl =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=${_secondpoint.latitude},${_secondpoint.longitude}'
          '&radius=$radius'
          '&type=restaurant'
          '&language=ko'
          '&key=$apiKey';
      final thirdUrl =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=${_thirdpoint.latitude},${_thirdpoint.longitude}'
          '&radius=$radius'
          '&type=restaurant'
          '&language=ko'
          '&key=$apiKey';

      final firstResponse = await http.get(Uri.parse(firstUrl));
      final secondResponse = await http.get(Uri.parse(secondUrl));
      final thirdResponse = await http.get(Uri.parse(thirdUrl));

      if (firstResponse.statusCode == 200 &&
          secondResponse.statusCode == 200 &&
          thirdResponse.statusCode == 200) {
        final firstData = jsonDecode(firstResponse.body);
        final secondData = jsonDecode(secondResponse.body);
        final thirdData = jsonDecode(thirdResponse.body);
        setState(() {
           _firstRestaurants = List<Map<String, dynamic>>.from(firstData['results']);
  _secondRestaurants = List<Map<String, dynamic>>.from(secondData['results']);
  _thirdRestaurants = List<Map<String, dynamic>>.from(thirdData['results']);
         _totalRestaurants.addAll(_firstRestaurants);
  _totalRestaurants.addAll(_secondRestaurants);
  _totalRestaurants.addAll(_thirdRestaurants);
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
              Tab(text: 'Map'),
              Tab(text: 'List'),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            Stack(children: [
              _buildMapView(),
              Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white10, // 드롭다운 버튼 배경색
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedPoint,
                      hint: Text('지점을 선택하세요'),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                      underline: Container(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      items: <String>['첫번째 지점', '두번째 지점', '세번째 지점']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPoint = newValue;
                          if (newValue == '첫번째 지점') {
                            _moveToPosition(_firstpoint);
                          } else if (newValue == '두번째 지점') {
                            _moveToPosition(_secondpoint);
                          } else if (newValue == '세번째 지점') {
                            _moveToPosition(_thirdpoint);
                          }
                        });
                      },
                    ),
                  ))
            ]),
            _buildRestaurantsList(),
          ],
        ),
      );
    }
    
Widget _buildRestaurantsList() {
  return ListView(
    padding: EdgeInsets.all(16.0),
    children: [
      _buildRestaurantSection(
        '첫번째 지점의 식당들',
        _firstRestaurants,
        Icons.restaurant,
        Colors.blue,
      ),
      SizedBox(height: 10), // 섹션 간 간격 추가
      _buildRestaurantSection(
        '두번째 지점의 식당들',
        _secondRestaurants,
        Icons.local_dining,
        Colors.brown,
      ),
      SizedBox(height: 10), // 섹션 간 간격 추가
      _buildRestaurantSection(
        '세번째 지점의 식당들',
        _thirdRestaurants,
        Icons.food_bank,
        Colors.black,
      ),
    ],
  );
}

Widget _buildRestaurantSection(String title, List<Map<String, dynamic>> restaurants, IconData icon, Color color) 
 {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    elevation: 4,
    child: ExpansionTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      children: restaurants.map<Widget>((restaurant) {
        return _buildRestaurantItem(restaurant);
      }).toList(),
    ),
  );
}

Widget _buildRestaurantItem(Map<String, dynamic> restaurant) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    elevation: 2,
    child: ExpansionTile(
      title: Text(
        restaurant['name'],
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      subtitle: Text("${restaurant['vicinity']}"),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 8),
              Text("음식점 이름: ${restaurant['name']}",
                 style: TextStyle(fontSize: 16, color: Colors.black87),
                 ),
              SizedBox(height: 8),
              if (restaurant.containsKey('rating'))
                  Text(
                    "음식점 평점: ${restaurant['rating']}",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
 
              SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailWebView(restaurant: restaurant['vicinity'])),
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
                            endLat: restaurant['geometry']['location']['lat']
                                .toString(),
                            endLng: restaurant['geometry']['location']['lng']
                                .toString()),
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
}

    Widget _buildMapView() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_firstpoint.latitude, _firstpoint.longitude),
        zoom: 12,
      ),
      markers: {
        Marker(
          markerId: MarkerId(widget.startAddress),
          position: LatLng(widget.startLat, widget.startLng),
          icon: AssetMapBitmap("assets/images/start_point.png", width: 48, height: 48),
          infoWindow: InfoWindow(
            title: "출발지",
            snippet: widget.startAddress,
          ),
        ),
        Marker(
          markerId: MarkerId(widget.endAddress),
          position: LatLng(widget.endLat, widget.endLng),
          icon: AssetMapBitmap("assets/images/end_point.png", width: 48, height: 48),
          infoWindow: InfoWindow(
            title: "도착지",
            snippet: widget.endAddress,
          ),
        ),
        ..._totalRestaurants.where((restaurant) => restaurant['business_status'] == 'OPERATIONAL').map((restaurant) {
          return Marker(
            markerId: MarkerId(restaurant['place_id']),
            position: LatLng(restaurant['geometry']['location']['lat'], restaurant['geometry']['location']['lng']),
            icon: AssetMapBitmap("assets/images/restaurant.png", width: 48, height: 48),
            infoWindow: InfoWindow(
              title: restaurant['name'],
              snippet: restaurant['vicinity'],
            ),
            onTap: () => _onMarkerTapped(restaurant),
          );
        }).toSet(),
      },
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }


    void _moveToPosition(LatLng position) {
      _mapController.animateCamera(CameraUpdate.newLatLng(position));
    }

    void _onMarkerTapped(Map<String, dynamic> restaurant) {
      Map<String, dynamic> _selectedRestaurant = {}; 

      setState(() {
        _selectedRestaurant = restaurant;
      });
    showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // 배경을 투명하게 설정하여 모서리 둥근 효과를 강조
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0, 
              spreadRadius: 2.0, 
              offset: Offset(0, 4), 
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  restaurant['name'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // 글자 색상
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(), // 닫기 버튼 추가
                ),
              ],
            ),
            SizedBox(height: 8),
            if (restaurant['photos'] != null && restaurant['photos'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0), // 이미지 모서리를 둥글게
                child: Image.network(
                  'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${restaurant['photos'][0]['photo_reference']}&key=AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y',
                  width: double.infinity, // 화면 너비에 맞게 설정
                  height: 200,
                  fit: BoxFit.cover, // 이미지 비율 유지하며 맞춤
                ),
              ),
            SizedBox(height: 8),
            Text(
              "도로명 주소 : ${restaurant['vicinity']}",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 8),
            if (restaurant.containsKey('rating'))
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orangeAccent),
                  SizedBox(width: 4),
                  Text(
                    "음식점 평점: ${restaurant['rating']}",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            if (restaurant.containsKey('user_ratings_total'))
              Text(
                "평점 수 : ${restaurant['user_ratings_total']}",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼 간격 균등하게
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetailView(
                        restaurant: _selectedRestaurant,
                        startAddress: widget.startAddress,
                        startLat: widget.startLat,
                        startLng: widget.startLng,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.info_outline),
                  label: Text("정보 보기"),
                  style: ElevatedButton.styleFrom(
                  
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RoadGuide(
                        startAddress: widget.startAddress,
                        endAddress: restaurant['vicinity'],
                        startLat: widget.startLat.toString(),
                        startLng: widget.startLng.toString(),
                        endLat: restaurant['geometry']['location']['lat']
                            .toString(),
                        endLng: restaurant['geometry']['location']['lng']
                            .toString(),
                      ),
                    ),
                  ),
                  icon: Icon(Icons.directions),
                  label: Text("경로 찾기"),
                  style: ElevatedButton.styleFrom(
                
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );


    }
  }
