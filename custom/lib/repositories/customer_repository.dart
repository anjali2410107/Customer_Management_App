import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';

abstract class CustomerRepository {
  Stream<List<CustomerModel>> getCustomersStream();
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}


class FirestoreCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('customers');

  @override
  Stream<List<CustomerModel>> getCustomersStream() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CustomerModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    await _collection.add(customer.toMap());
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await _collection.doc(customer.id).update(customer.toMap());
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _collection.doc(id).delete();
  }
}


class LocalCustomerRepository implements CustomerRepository {
  static const String _localPrefsKey = 'local_customers_list';
  final StreamController<List<CustomerModel>> _streamController =
      StreamController<List<CustomerModel>>.broadcast();
  List<CustomerModel> _cachedCustomers = [];

  LocalCustomerRepository() {
    _initLocalData();
  }

  Future<void> _initLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_localPrefsKey);
      if (listJson != null) {
        _cachedCustomers = listJson
            .map((jsonStr) => CustomerModel.fromJson(jsonStr))
            .toList();
        _cachedCustomers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      _streamController.add(List.unmodifiable(_cachedCustomers));
    } catch (e) {
      _streamController.add([]);
    }
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = _cachedCustomers.map((cust) => cust.toJson()).toList();
    await prefs.setStringList(_localPrefsKey, listJson);
    _streamController.add(List.unmodifiable(_cachedCustomers));
  }

  @override
  Stream<List<CustomerModel>> getCustomersStream() {
    Timer.run(() {
      _streamController.add(List.unmodifiable(_cachedCustomers));
    });
    return _streamController.stream;
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    final newId = 'local_${DateTime.now().millisecondsSinceEpoch}_${customer.name.hashCode}';
    final customerWithId = customer.copyWith(id: newId);
    
    _cachedCustomers.insert(0, customerWithId);
    await _saveLocalData();
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    final index = _cachedCustomers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _cachedCustomers[index] = customer;
      await _saveLocalData();
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    _cachedCustomers.removeWhere((c) => c.id == id);
    await _saveLocalData();
  }
}
