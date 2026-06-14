import 'dart:convert';
import 'package:http/http.dart' as http;

/// A Dart model class representing a Customer in the REST backend.
class Customer {
  final String? id;
  final String name;
  final String mobile;
  final String? email;
  final String? company;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({
    this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.company,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory method to construct a Customer object from JSON map.
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      company: json['company'],
      address: json['address'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Convert Customer object to JSON map for request bodies.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'mobile': mobile,
      if (email != null) 'email': email,
      if (company != null) 'company': company,
      if (address != null) 'address': address,
    };
  }
}

/// An API service to integrate the Flutter frontend with the Next.js REST API.
class CustomerApiService {
  /// The base URL of the Next.js API.
  final String baseUrl;

  CustomerApiService({required this.baseUrl});

  /// 1. Fetch all customers (GET /api/customers)
  Future<List<Customer>> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((item) => Customer.fromJson(item)).toList();
        } else {
          throw Exception(responseData['error'] ?? 'Failed to load customers');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  /// 2. Fetch a single customer by ID (GET /api/customers/[id])
  Future<Customer> fetchCustomerById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return Customer.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['error'] ?? 'Failed to load customer');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customer: $e');
    }
  }

  /// 3. Create a new customer (POST /api/customers)
  Future<Customer> createCustomer(Customer customer) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(customer.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return Customer.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['error'] ?? 'Failed to create customer');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['error'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  /// 4. Update an existing customer (PUT /api/customers/[id])
  Future<Customer> updateCustomer(String id, Customer customer) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(customer.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return Customer.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['error'] ?? 'Failed to update customer');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['error'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  /// 5. Delete a customer (DELETE /api/customers/[id])
  Future<void> deleteCustomer(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return;
        } else {
          throw Exception(responseData['error'] ?? 'Failed to delete customer');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }
}
