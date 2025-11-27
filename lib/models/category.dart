import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class SubCategory {
  final String id;
  final String name;
  final String icon;
  final String parentCategoryId;

  const SubCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.parentCategoryId,
  });
}
