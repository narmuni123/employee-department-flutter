import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/department.dart';
import '../bloc/department/department_bloc.dart';
import '../bloc/department/department_event.dart';
import '../bloc/department/department_state.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_indicator.dart';

class DepartmentListScreen extends StatefulWidget {
  const DepartmentListScreen({super.key});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  @override
  void initState() {
    super.initState();
    // Load departments when the screen initializes
    context.read<DepartmentBloc>().add(const LoadDepartments());
  }

  void _onDepartmentTap(Department department) {
    Navigator.of(context).pushNamed('/employees', arguments: department.id);
  }

  void _onRetry() {
    context.read<DepartmentBloc>().add(const RefreshDepartments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments'), centerTitle: true),
      body: BlocBuilder<DepartmentBloc, DepartmentState>(
        builder: (context, state) {
          return switch (state) {
            // Initial state - show loading
            DepartmentInitial() => const LoadingIndicator(
              message: 'Loading departments...',
            ),

            // Loading state - show loading indicator
            DepartmentLoading() => const LoadingIndicator(
              message: 'Loading departments...',
            ),

            // Loaded state - show departments or empty state
            DepartmentLoaded(:final departments) =>
              departments.isEmpty
                  // Empty state - show message indicating no departments
                  ? const EmptyStateView(
                      message: 'No departments found',
                      icon: Icons.business_outlined,
                    )
                  // Show department list
                  : _buildDepartmentList(departments),

            // Error state - show error with retry option
            DepartmentError(:final message) => ErrorView(
              message: message,
              onRetry: _onRetry,
            ),
          };
        },
      ),
    );
  }

  Widget _buildDepartmentList(List<Department> departments) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DepartmentBloc>().add(const RefreshDepartments());
        // Wait for the state to change from loading
        await context.read<DepartmentBloc>().stream.firstWhere(
          (state) => state is! DepartmentLoading,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final department = departments[index];
          return _DepartmentCard(
            department: department,
            onTap: () => _onDepartmentTap(department),
          );
        },
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback onTap;

  const _DepartmentCard({required this.department, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Department icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  Icons.business,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),

              // Department details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Department name
                    Text(
                      department.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Department location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            department.location,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Employee count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${department.employeeCount}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation arrow
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
