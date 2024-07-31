import 'package:flutter/material.dart';
import 'package:project/model/foodData.dart';
import 'package:project/roadGuide.dart';
import 'detailWebView.dart';

class FoodDetail extends StatelessWidget {
  final String startAddress;
  final double startLat;
  final double startLng;
  final foodData food;
  FoodDetail({required this.startAddress,required this.startLat, required this.startLng, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Restaurant Information"),
           backgroundColor: Colors.blue[200]),
        body: Column(
          children: [
            Text("음식점 이름 : ${food.RESTRT_NM}"),
            Text("음식점 전화번호 : ${food.TASTFDPLC_TELNO}"),
            Text("음식점 대표음식 : ${food.REPRSNT_FOOD_NM}"),
            Text("음식점 우편번호 : ${food.REFINE_ZIP_CD}"),
            Text("음식점 주소 : ${food.REFINE_ROADNM_ADDR}"),

            SizedBox(height: 30,),

            ElevatedButton(onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DetailWebView(restaurant: food.REFINE_ROADNM_ADDR.toString()))), child: Text("해당 음식점의 자세한 정보 보기 (네이버 지도)")),
            ElevatedButton(onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => RoadGuide(startAddress: startAddress, endAddress: food.REFINE_ROADNM_ADDR.toString(), startLat: startLat.toString(), startLng: startLng.toString(), endLat: food.REFINE_WGS84_LAT.toString(), endLng: food.REFINE_WGS84_LOGT.toString()))
            ), child: Text("해당 지점으로 이동하기"))
          ],
        ));
  }
}
