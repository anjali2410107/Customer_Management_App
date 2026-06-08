import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';

abstract class CustomerState {
  const CustomerState();
}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> allCustomers;
  final List<CustomerModel> filteredCustomers;
  final String searchQuery;

  CustomerLoaded({
    required this.allCustomers,
    required this.filteredCustomers,
    this.searchQuery = '',
  });

  CustomerLoaded copyWith({
    List<CustomerModel>? allCustomers,
    List<CustomerModel>? filteredCustomers,
    String? searchQuery,
  }) {
    return CustomerLoaded(
      allCustomers: allCustomers ?? this.allCustomers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerError extends CustomerState {
  final String errorMessage;
  CustomerError(this.errorMessage);
}

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;
  StreamSubscription<List<CustomerModel>>? _subscription;

  CustomerCubit(this._repository) : super(CustomerLoading()) {
    _subscribeToCustomers();
  }

  void _subscribeToCustomers() {
    emit(CustomerLoading());
    _subscription?.cancel();
    _subscription = _repository.getCustomersStream().listen(
      (customers) {
        final currentQuery = state is CustomerLoaded
            ? (state as CustomerLoaded).searchQuery
            : '';
        _emitFilteredState(customers, currentQuery);
      },
      onError: (error) {
        emit(CustomerError(error.toString()));
      },
    );
  }

  void _emitFilteredState(List<CustomerModel> all, String query) {
    if (query.isEmpty) {
      emit(CustomerLoaded(
        allCustomers: all,
        filteredCustomers: all,
        searchQuery: '',
      ));
    } else {
      final filtered = all.where((c) {
        final nameLower = c.name.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();

      emit(CustomerLoaded(
        allCustomers: all,
        filteredCustomers: filtered,
        searchQuery: query,
      ));
    }
  }

  void searchCustomers(String query) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      _emitFilteredState(currentState.allCustomers, query);
    }
  }

  Future<void> refreshCustomers() async {
    _subscribeToCustomers();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<bool> addCustomer({
    required String name,
    required String mobile,
    String email = '',
    String companyName = '',
    String address = '',
  }) async {
    try {
      final newCustomer = CustomerModel(
        id: '',
        name: name,
        mobile: mobile,
        email: email,
        companyName: companyName,
        address: address,
        createdAt: DateTime.now(),
      );
      await _repository.addCustomer(newCustomer);
      return true;
    } catch (e) {
      emit(CustomerError('Failed to add customer: ${e.toString()}'));
      return false;
    }
  }

  Future<bool> updateCustomer(CustomerModel updatedCustomer) async {
    try {
      await _repository.updateCustomer(updatedCustomer);
      return true;
    } catch (e) {
      emit(CustomerError('Failed to update customer: ${e.toString()}'));
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      return true;
    } catch (e) {
      emit(CustomerError('Failed to delete customer: ${e.toString()}'));
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
