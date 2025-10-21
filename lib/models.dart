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

  // Convert BusinessCard to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'company': company,
      'email': email,
      'phone': phone,
      'website': website,
      'location': location,
      'color': color.value,
    };
  }

  // Create BusinessCard from JSON
  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      location: json['location'] ?? '',
      color: Color(json['color'] ?? Colors.blue.value),
    );
  }
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