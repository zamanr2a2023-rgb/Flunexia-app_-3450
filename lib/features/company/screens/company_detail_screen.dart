import 'package:flutter/material.dart';

class CompanyDetailScreen extends StatelessWidget {
  const CompanyDetailScreen({super.key, required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Company Detail: $companyId')),
    );
  }
}
