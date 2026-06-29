import 'package:flutter/material.dart';

class OhabolanaDetailPage extends StatelessWidget {
  final String ohabolanaId;
  const OhabolanaDetailPage({super.key, required this.ohabolanaId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: Center(child: Text(ohabolanaId)));
}
