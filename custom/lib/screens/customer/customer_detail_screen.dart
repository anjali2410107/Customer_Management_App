import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_cubit.dart';
import 'edit_customer_screen.dart';
class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;
  const CustomerDetailScreen({super.key, required this.customer});
  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}
class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late CustomerModel _currentCustomer;
  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
  }
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Customer'),
            ],
          ),
          content: Text('Are you sure you want to delete this customer, ${_currentCustomer.name}?'),
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
    if (confirmed == true && mounted) {
      final success = await context.read<CustomerCubit>().deleteCustomer(_currentCustomer.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_currentCustomer.name} deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
  void _mockDialCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling +91 ${_currentCustomer.mobile}...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  void _mockSendEmail() {
    if (_currentCustomer.email.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening email app for ${_currentCustomer.email}...'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(_currentCustomer.createdAt);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () async {
              final updatedCustomer = await Navigator.push<CustomerModel>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCustomerScreen(customer: _currentCustomer),
                ),
              );
              if (updatedCustomer != null) {
                setState(() {
                  _currentCustomer = updatedCustomer;
                });
              }
            },
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Delete Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'avatar_${_currentCustomer.id}',
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            _currentCustomer.name.isNotEmpty
                                ? _currentCustomer.name.trim().substring(0, 1).toUpperCase()
                                : 'C',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentCustomer.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_currentCustomer.companyName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _currentCustomer.companyName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCommunicationButton(
                            icon: Icons.phone_rounded,
                            label: 'Call',
                            color: Colors.green,
                            onTap: _mockDialCall,
                          ),
                          const SizedBox(width: 24),
                          _buildCommunicationButton(
                            icon: Icons.mail_rounded,
                            label: 'Email',
                            color: _currentCustomer.email.isNotEmpty ? Colors.indigo : Colors.grey,
                            onTap: _currentCustomer.email.isNotEmpty ? _mockSendEmail : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact & Detail Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      _buildDetailRow(
                        icon: Icons.phone_android_rounded,
                        label: 'Mobile Number',
                        value: '+91 ${_currentCustomer.mobile}',
                      ),
                      const SizedBox(height: 18),

                      _buildDetailRow(
                        icon: Icons.alternate_email_rounded,
                        label: 'Email Address',
                        value: _currentCustomer.email.isNotEmpty ? _currentCustomer.email : 'Not Provided',
                      ),
                      const SizedBox(height: 18),

                      _buildDetailRow(
                        icon: Icons.business_rounded,
                        label: 'Company',
                        value: _currentCustomer.companyName.isNotEmpty ? _currentCustomer.companyName : 'Not Provided',
                      ),
                      const SizedBox(height: 18),

                      _buildDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: _currentCustomer.address.isNotEmpty ? _currentCustomer.address : 'Not Provided',
                      ),
                      const SizedBox(height: 18),
                      _buildDetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Created Date',
                        value: formattedDate,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCommunicationButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEnabled ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isEnabled ? color : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade200 : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
