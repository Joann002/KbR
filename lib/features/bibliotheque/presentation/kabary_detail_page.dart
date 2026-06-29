import 'package:flutter/material.dart';

class KabaryDetailPage extends StatelessWidget {
  final String kabaryId;
  const KabaryDetailPage({super.key, required this.kabaryId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: Center(child: Text(kabaryId)));
}
