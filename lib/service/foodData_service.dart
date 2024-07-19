import 'dart:convert';

import 'package:project/model/foodData.dart';
import 'package:http/http.dart' as http;

abstract class foodDataService {
  Future<List<foodData>> fetchData();

}
class FoodDataServiceImplementation implements foodDataService {
  @override
  Future<List<foodData>> fetchData() async {
    final response = await http.get(Uri.parse("https://openapi.gg.go.kr/PlaceThatDoATasteyFoodSt?KEY=a1b0bdb305724043bad23af6a6355d10&TYPE=JSON"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> rowData = data['PlaceThatDoATasteyFoodSt'][1]['row'];
      List<foodData> result = rowData.map<foodData>((json) => foodData.fromJson(json)).toList();
      return result;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
