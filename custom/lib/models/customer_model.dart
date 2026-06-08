import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String companyName;
  final String address;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email = '',
    this.companyName = '',
    this.address = '',
    required this.createdAt,
  });

  // Create a copy of the model with some fields modified
  CustomerModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? companyName,
    String? address,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to Map for Firestore.
  // Note: Firestore uses Timestamp for dates, so we convert DateTime to Timestamp.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'companyName': companyName,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document snapshot map
  factory CustomerModel.fromMap(Map<String, dynamic> map, String docId) {
    // Safely parse Firestore Timestamp or falling back to iso string representation
    DateTime parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return CustomerModel(
      id: docId,
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      companyName: map['companyName'] ?? '',
      address: map['address'] ?? '',
      createdAt: parsedDate,
    );
  }

  // Convert to JSON map for Local SharedPreferences Storage
  Map<String, dynamic> toJsonMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'companyName': companyName,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Parse from SharedPreferences JSON map
  factory CustomerModel.fromJsonMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      companyName: map['companyName'] ?? '',
      address: map['address'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // String serialization/deserialization helpers
  String toJson() => json.encode(toJsonMap());
  factory CustomerModel.fromJson(String source) => CustomerModel.fromJsonMap(json.decode(source));
}
