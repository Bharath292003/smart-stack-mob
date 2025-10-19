import 'package:flutter/material.dart';

// Data Models
class BusinessCard {
  final int id;
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final String website;
  final String location;
  final Color color;

  BusinessCard({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.email,
    required this.phone,
    required this.website,
    required this.location,
    required this.color,
  });
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final int count;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
  });
}