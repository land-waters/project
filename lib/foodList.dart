import 'package:flutter/material.dart';
import 'package:project/service/foodData_service.dart';
import 'model/foodData.dart';
import 'package:project/locator/locator.dart';
import 'foodDetail.dart'; // 상세 정보 화면을 import

class Foodlist extends StatefulWidget {
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  const Foodlist({Key? key, required this.startLat, required this.startLng, required this.endLat, required this.endLng}) : super(key: key);

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
      body: FutureBuilder<List<foodData>>(
        future: _service.fetchData(widget.startLat, widget.startLng, widget.endLat, widget.endLng),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            List<foodData> list = snapshot.data!;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FoodDetail(food: list[index]),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(list[index].RESTRT_NM ?? 'Unknown'),
                    isThreeLine: true,
                    subtitle: Text(list[index].REPRSNT_FOOD_NM ?? 'Unknown'),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text("No data found"),
            );
          }
        },
      ),
    );
  }
}
