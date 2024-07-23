import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DetailWebView extends StatelessWidget {
  final String restaurant;
  DetailWebView({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant),
        backgroundColor: Colors.blue,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri('https://map.naver.com/p/search/$restaurant')),
      ),
    );
  }
}