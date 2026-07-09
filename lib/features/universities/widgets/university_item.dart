import 'package:flutter/material.dart';

import '../models/university.dart';
import 'university_item_card.dart';

class UniversityItem extends StatelessWidget {
  const UniversityItem({super.key, required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return UniversityItemCard(university: university);
  }
}
