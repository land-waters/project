import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project/detailWebView.dart';
import 'package:project/googleReview.dart';
import 'package:project/roadGuide.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailView extends StatefulWidget {
  final String startAddress;
  final double startLat;
  final double startLng;
  final Map<String, dynamic> restaurant;

  DetailView({required this.startAddress, required this.startLat, required this.startLng, required this.restaurant});

  @override
  _DetailViewState createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaceDetails(widget.restaurant['place_id']);
  }
  

  Future<void> _fetchPlaceDetails(String placeId) async {
    final apiKey = 'AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y';
    final url = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,rating,reviews'
        '&language=ko'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _reviews = data['result']['reviews'] ?? [];
      });
    } else {
      throw Exception('Failed to load place details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant['name'], style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.restaurant['photos'] != null &&
                widget.restaurant['photos'].isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3, // 원하는 높이로 설정
                child: Container(
                  child: Image.network(
                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${widget.restaurant['photos'][0]['photo_reference']}&key=AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y',
                    width: MediaQuery.of(context).size.width, // 원하는 너비로 설정
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "가게 이름 : ${widget.restaurant['name']}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "도로명 주소 : ${widget.restaurant['vicinity']}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "평점: ${widget.restaurant['rating']} , 평점 참여자 : ${widget.restaurant['user_ratings_total']}",
                    style: TextStyle(fontSize: 16),
                  ),
                  
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RoadGuide(
                          startAddress: widget.startAddress,
                          endAddress: widget.restaurant['vicinity'],
                          startLat: widget.startLat.toString(),
                          startLng: widget.startLng.toString(),
                          endLat: widget.restaurant['geometry']['location']['lat'].toString(),
                          endLng: widget.restaurant['geometry']['location']['lng'].toString(),
                        ),
                      ),
                    ),
                    child: Text("해당 음식점까지 경로 찾기"),
                    style: TextButton.styleFrom(side: BorderSide(color: Colors.blue),)
                 
                  ),
                  Text(
                    "리뷰",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "앱 내에서 구글 리뷰는 최대 5개까지만 보여집니다", 
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.normal),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Googlereview(
                              restaurant: widget.restaurant['name'],
                              place_id: widget.restaurant['place_id'],
                            ),
                          ),
                        ),
                        child: Text("구글 리뷰 더보러가기"),
                        style: TextButton.styleFrom(
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailWebView(
                              restaurant: widget.restaurant['name'],
                            ),
                          ),
                        ),
                        child: Text("네이버 리뷰 보러가기"),
                        style: TextButton.styleFrom(
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _reviews.isNotEmpty
                ? ListView.builder(
                    itemCount: _reviews.length,
                    shrinkWrap: true,  // ListView가 Column 내에서 크기를 자동으로 조절하게 함
                    physics: NeverScrollableScrollPhysics(), // ListView 내부에서 스크롤이 되지 않도록 설정
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['author_name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(review['text']),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.orange),
                                  SizedBox(width: 4),
                                  Text("평점: ${review['rating']}"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: Text("리뷰가 없습니다.")),
          ],
        ),
      ),
    );
  }
}
