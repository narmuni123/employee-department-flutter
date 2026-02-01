import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/employee.dart';
import '../bloc/employee/employee_bloc.dart';
import '../bloc/employee/employee_event.dart';
import '../bloc/employee/employee_state.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_indicator.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late int _departmentId;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _departmentId = ModalRoute.of(context)!.settings.arguments as int;
      context.read<EmployeeBloc>().add(LoadEmployees(_departmentId));
      _isInitialized = true;
    }
  }

  Future<void> _onRefresh() async {
    context.read<EmployeeBloc>().add(RefreshEmployees(_departmentId));
    await context.read<EmployeeBloc>().stream.firstWhere(
      (state) => state is! EmployeeLoading,
    );
  }

  void _onRetry() {
    context.read<EmployeeBloc>().add(RefreshEmployees(_departmentId));
  }

  Future<void> _showDeleteConfirmation(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${employee.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<EmployeeBloc>().add(
        DeleteEmployee(_departmentId, employee.id),
      );
    }
  }

  void _navigateToAddEmployee() {
    Navigator.of(context).pushNamed('/add-employee', arguments: _departmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employees'), centerTitle: true),
      body: BlocConsumer<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          if (state is EmployeeDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is EmployeeDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            EmployeeInitial() => const LoadingIndicator(
              message: 'Loading employees...',
            ),
            EmployeeLoading() => const LoadingIndicator(
              message: 'Loading employees...',
            ),
            EmployeeLoaded(:final employees) => _buildContent(employees, null),
            EmployeeDeleting(:final employees, :final deletingId) =>
              _buildContent(employees, deletingId),
            EmployeeDeleteSuccess(:final employees) => _buildContent(
              employees,
              null,
            ),
            EmployeeDeleteError(:final employees) => _buildContent(
              employees,
              null,
            ),
            EmployeeError(:final message) => ErrorView(
              message: message,
              onRetry: _onRetry,
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEmployee,
        tooltip: 'Add Employee',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(List<Employee> employees, int? deletingId) {
    if (employees.isEmpty) {
      return EmptyStateView(
        message: 'No employees in this department',
        icon: Icons.people_outline,
        actionButtonText: 'Add Employee',
        onAction: _navigateToAddEmployee,
      );
    }

    return _buildEmployeeList(employees, deletingId);
  }

  Widget _buildEmployeeList(List<Employee> employees, int? deletingId) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          final isDeleting = deletingId == employee.id;
          return _EmployeeCard(
            employee: employee,
            isDeleting: isDeleting,
            onDelete: () => _showDeleteConfirmation(employee),
          );
        },
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isDeleting;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.isDeleting,
    required this.onDelete,
  });

  String _formatSalary(double salary) {
    return '\$${salary.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Center(
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
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
                    employee.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          employee.position,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          employee.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatSalary(employee.salary),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isDeleting)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                tooltip: 'Delete employee',
              ),
          ],
        ),
      ),
    );
  }
}
