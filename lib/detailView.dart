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
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPlaceDetails(widget.restaurant['place_id']);
  }

  Future<void> _fetchPlaceDetails(String placeId) async {
    final apiKey = 'AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y'; // 유효한 API 키로 교체 필요
    final url = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,rating,reviews,photos'
        '&language=ko'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 확인: 'result'와 'reviews'가 유효한지 확인
        if (data.containsKey('result') && data['result'].containsKey('reviews')) {
          setState(() {
            _reviews = data['result']['reviews'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = '리뷰 정보를 가져오는 데 실패했습니다.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = '장소 세부정보를 불러오는 데 실패했습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류 발생: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant['name']),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.restaurant['photos'] != null &&
                        widget.restaurant['photos'].isNotEmpty)
                      Image.network(
                        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${widget.restaurant['photos'][0]['photo_reference']}&key=AIzaSyDMKs41kiiacK9CNt_nNEZXkv0gwoVC36Y',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                            "평점: ${widget.restaurant['rating']}",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "리뷰",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          _reviews.isNotEmpty
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: _reviews.length,
                                    itemBuilder: (context, index) {
                                      final review = _reviews[index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(review['author_name'] ?? 'Unknown'),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 4),
                                              Text(review['text'] ?? 'No review text'),
                                              SizedBox(height: 4),
                                              Text("평점: ${review['rating'] ?? 'No rating'}"),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(child: Text('리뷰가 없습니다')),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
