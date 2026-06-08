import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_cubit.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});
  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}
class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Future<bool?> _showDeleteConfirmation(BuildContext context, CustomerModel customer) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirm Delete'),
            ],
          ),
          content: Text('Are you sure you want to delete this customer, ${customer.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 40),
              ),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers Directory'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Customer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CustomerCubit>().searchCustomers('');
                    setState(() {});
                  },
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                context.read<CustomerCubit>().searchCustomers(value);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CustomerError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 60, color: theme.colorScheme.error),
                          const SizedBox(height: 16),
                          Text(state.errorMessage, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<CustomerCubit>().refreshCustomers(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state is CustomerLoaded) {
                  final list = state.filteredCustomers;
                  if (list.isEmpty) {
                    final hasQuery = state.searchQuery.isNotEmpty;
                    return RefreshIndicator(
                      onRefresh: () => context.read<CustomerCubit>().refreshCustomers(),
                      child: ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                          Icon(
                            hasQuery ? Icons.search_off_rounded : Icons.people_outline_rounded,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            hasQuery ? 'No customers match your search' : 'No customers listed yet',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasQuery ? 'Try refinement or clear query' : 'Tap the floating button below to create one',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => context.read<CustomerCubit>().refreshCustomers(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final customer = list[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Dismissible(
                            key: Key(customer.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await _showDeleteConfirmation(context, customer);
                            },
                            onDismissed: (direction) {
                              context.read<CustomerCubit>().deleteCustomer(customer.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${customer.name} deleted successfully'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                            ),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomerDetailScreen(customer: customer),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Hero(
                                        tag: 'avatar_${customer.id}',
                                        child: CircleAvatar(
                                          radius: 26,
                                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                          child: Text(
                                            customer.name.isNotEmpty
                                                ? customer.name.trim().substring(0, 1).toUpperCase()
                                                : 'C',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customer.name,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.phone_iphone_rounded, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  customer.mobile,
                                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                            if (customer.companyName.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.business_rounded, size: 14, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      customer.companyName,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.secondary,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}