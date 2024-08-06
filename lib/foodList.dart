import 'package:flutter/material.dart';
import 'package:project/detailWebView.dart';
import 'package:project/roadGuide.dart';
import 'package:project/service/foodData_service.dart';
import 'model/foodData.dart';
import 'package:project/locator/locator.dart';
import 'dart:math';

class Foodlist extends StatefulWidget {
  final String startAddress;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  const Foodlist(
      {super.key,
      required this.startAddress,
      required this.startLat,
      required this.startLng,
      required this.endLat,
      required this.endLng});

  @override
  State<Foodlist> createState() => _FoodlistState();
}

class _FoodlistState extends State<Foodlist> {
  final foodDataService _service = locator<foodDataService>();

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const R = 6371e3; // Earth radius in meters
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lng2 - lng1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  List<foodData> _filterAndSortRestaurants(List<foodData> list) {
    List<foodData> filteredList = list.where((restaurant) {
      double lat = double.parse(restaurant.REFINE_WGS84_LAT ?? '0');
      double lng = double.parse(restaurant.REFINE_WGS84_LOGT ?? '0');

      bool isLatInRange = (lat >= widget.startLat && lat <= widget.endLat) ||
          (lat <= widget.startLat && lat >= widget.endLat);
      bool isLngInRange = (lng >= widget.startLng && lng <= widget.endLng) ||
          (lng <= widget.startLng && lng >= widget.endLng);

      return isLatInRange && isLngInRange;
    }).toList();

    filteredList.sort((a, b) {
      double distanceA = _calculateDistance(
          widget.startLat,
          widget.startLng,
          double.parse(a.REFINE_WGS84_LAT ?? '0'),
          double.parse(a.REFINE_WGS84_LOGT ?? '0'));
      double distanceB = _calculateDistance(
          widget.startLat,
          widget.startLng,
          double.parse(b.REFINE_WGS84_LAT ?? '0'),
          double.parse(b.REFINE_WGS84_LOGT ?? '0'));
      return distanceA.compareTo(distanceB);
    });

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant List"),
        backgroundColor: Colors.blue[200],
      ),
      body: FutureBuilder(
        future: _service.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<foodData>? list = snapshot.data;
            List<foodData> filteredAndSortedList =
                _filterAndSortRestaurants(list!);
            return ListView.builder(
              itemCount: filteredAndSortedList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ExpansionTile(
                    title: Text(
                      filteredAndSortedList[index].RESTRT_NM.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text(
                        "대표 음식 : ${filteredAndSortedList[index].REPRSNT_FOOD_NM.toString()}"),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "위치 : ${filteredAndSortedList[index].REFINE_ROADNM_ADDR.toString()}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                                "음식점 이름 : ${filteredAndSortedList[index].RESTRT_NM}"),
                            SizedBox(height: 8),
                            Text(
                                "음식점 전화번호 : ${filteredAndSortedList[index].TASTFDPLC_TELNO}"),
                            SizedBox(height: 8),
                            Text(
                                "음식점 우편번호 : ${filteredAndSortedList[index].REFINE_ZIP_CD}"),
                            SizedBox(height: 8),
                            Text(
                                "음식점 주소 : ${filteredAndSortedList[index].REFINE_ROADNM_ADDR}"),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => DetailWebView(
                                              restaurant:
                                                  filteredAndSortedList[index]
                                                      .REFINE_ROADNM_ADDR
                                                      .toString()))),
                                  child: Text("정보 보기"),
                                  style: TextButton.styleFrom(
                                    side: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => RoadGuide(
                                        startAddress: widget.startAddress,
                                        endAddress: filteredAndSortedList[index]
                                            .REFINE_ROADNM_ADDR
                                            .toString(),
                                        startLat: widget.startLat.toString(),
                                        startLng: widget.startLng.toString(),
                                        endLat: filteredAndSortedList[index]
                                            .REFINE_WGS84_LAT
                                            .toString(),
                                        endLng: filteredAndSortedList[index]
                                            .REFINE_WGS84_LOGT
                                            .toString())),
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
          } else if (snapshot.hasError) {
            return Center(
              child: Text("error: ${snapshot.error}"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
        },
      ),
    );
  }
}
