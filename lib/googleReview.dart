import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Googlereview extends StatelessWidget {
  final String restaurant;
  final String place_id;
  Googlereview({required this.restaurant,required this.place_id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri('https://www.google.com/maps/place/?q=place_id:${place_id}')),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.05,
            child: ElevatedButton(
              onPressed: () => {Navigator.of(context).pop()},
              child: Text("뒤로 가기"),
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.blue)
              ),
            ),
          )
          
        ],
      ),
    );
  }
}