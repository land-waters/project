import 'package:flutter/material.dart';
import 'package:project/model/foodData.dart';

class FoodDetail extends StatelessWidget {
  final foodData food;
  FoodDetail({required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(food.RESTRT_NM ?? "음식점 상세정보")),
        body: Column(
          children: [
            Text("음식점 이름 : ${food.RESTRT_NM}"),
            Text("음식점 전화번호 : ${food.TASTFDPLC_TELNO}"),
            Text("음식점 대표음식 : ${food.REPRSNT_FOOD_NM}"),
            Text("음식점 우편번호 : ${food.REFINE_ZIP_CD}"),
            Text("음식점 주소 : ${food.REFINE_ROADNM_ADDR}"),
          ],
        ));
  }
}
