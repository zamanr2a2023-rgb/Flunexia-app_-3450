import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.plateNumber, this.onTap});

  final String plateNumber;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(plateNumber), onTap: onTap);
  }
}
