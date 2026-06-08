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

  factory CustomerModel.fromMap(Map<String, dynamic> map, String docId) {
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

  String toJson() => json.encode(toJsonMap());
  factory CustomerModel.fromJson(String source) => CustomerModel.fromJsonMap(json.decode(source));
}
