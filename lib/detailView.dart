
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailView extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  DetailView({required this.restaurant});

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
        title: Text(widget.restaurant['name']),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.restaurant['photos'] != null &&
              widget.restaurant['photos'].isNotEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3, // 원하는 높이로 설정
              child:Container(
                    
                    child: Image.network(
                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${widget.restaurant['photos'][0]['photo_reference']}&key=AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y',
                      width: MediaQuery.of(context).size.width, // 원하는 너비로 설정
                      fit: BoxFit.cover,
                    ),
                  )
            ),

          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurant['name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  widget.restaurant['vicinity'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "평점: ${widget.restaurant['rating']} , 평점 참여자 : ${widget.restaurant['user_ratings_total']}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  "리뷰",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "리뷰는 최대 5개까지만 보여집니다", 
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.normal),
                )
               
              ],
            ),
          ),
          
          // ListView.builder를 Expanded로 감싸기
          Expanded(
            child: _reviews.isNotEmpty
                ? ListView.builder(
                    itemCount: _reviews.length,
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
          ),
        ],
      ),
    );
  }
}
