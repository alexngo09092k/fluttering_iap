import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttering_iap/fluttering_iap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AwesomeIAP iap;
  @override
  void initState() {
    super.initState();
    iap = AwesomeIAP();
    iap.initial(const IAPConfig(products: []));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text(
            'This is a example for in app purchase for flutter',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
