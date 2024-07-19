import 'package:flutter/material.dart';
import 'package:project/service/foodData_service.dart';
import 'model/foodData.dart';
import 'package:project/locator/locator.dart';

class Foodlist extends StatefulWidget {
  const Foodlist({super.key});

  @override
  State<Foodlist> createState() => _FoodlistState();
}

class _FoodlistState extends State<Foodlist> {
  final foodDataService _service = locator<foodDataService>();

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: const Text("음식점 리스트"),
      ),
      body: FutureBuilder(
        future: _service.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<foodData>? list = snapshot.data;
            return ListView.builder(
              itemCount: list?.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(15),
                  child: Text("${list?[index].RESTRT_NM} : ${list?[index].REFINE_WGS84_LAT} : ${list?[index].REFINE_WGS84_LOGT}"),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("error"),
            );
          }
          else {
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