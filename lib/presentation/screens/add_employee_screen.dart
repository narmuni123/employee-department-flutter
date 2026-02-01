import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/add_employee/add_employee_cubit.dart';
import '../bloc/add_employee/add_employee_state.dart';
import '../widgets/custom_text_field.dart';

class AddEmployeeScreen extends StatelessWidget {
  const AddEmployeeScreen({super.key});

  void _onSubmitPressed(BuildContext context) {
    context.read<AddEmployeeCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Employee'), centerTitle: true),
      body: BlocConsumer<AddEmployeeCubit, AddEmployeeState>(
        listener: (context, state) {
          // Navigate back on success and show success message
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.successMessage ?? 'Employee added successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form header
                  Icon(
                    Icons.person_add,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'New Employee',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the details below to add a new employee',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Employee ID field
                  CustomTextField(
                    label: 'Employee ID',
                    hint: 'Enter numeric employee ID',
                    value: state.id,
                    errorText: state.idError,
                    onChanged: (value) {
                      context.read<AddEmployeeCubit>().idChanged(value);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: Icons.badge_outlined,
                    textInputAction: TextInputAction.next,
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Employee Name field
                  CustomTextField(
                    label: 'Name',
                    hint: 'Enter employee name',
                    value: state.name,
                    errorText: state.nameError,
                    onChanged: (value) {
                      context.read<AddEmployeeCubit>().nameChanged(value);
                    },
                    keyboardType: TextInputType.name,
                    prefixIcon: Icons.person_outlined,
                    textInputAction: TextInputAction.next,
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Employee Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter employee email',
                    value: state.email,
                    errorText: state.emailError,
                    onChanged: (value) {
                      context.read<AddEmployeeCubit>().emailChanged(value);
                    },
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.next,
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Employee Position field
                  CustomTextField(
                    label: 'Position',
                    hint: 'Enter employee position',
                    value: state.position,
                    errorText: state.positionError,
                    onChanged: (value) {
                      context.read<AddEmployeeCubit>().positionChanged(value);
                    },
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.work_outlined,
                    textInputAction: TextInputAction.next,
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Employee Salary field
                  CustomTextField(
                    label: 'Salary',
                    hint: 'Enter employee salary',
                    value: state.salary,
                    errorText: state.salaryError,
                    onChanged: (value) {
                      context.read<AddEmployeeCubit>().salaryChanged(value);
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.attach_money,
                    textInputAction: TextInputAction.done,
                    onSubmitted: state.isSubmitting
                        ? null
                        : () => _onSubmitPressed(context),
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 8),

                  // API error message (for general API errors)
                  if (state.apiError != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.apiError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Submit button with loading state
                  SizedBox(
                    height: 48,
                    child: state.isSubmitting
                        ? const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: () => _onSubmitPressed(context),
                            icon: const Icon(Icons.add),
                            label: const Text(
                              'Add Employee',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel button
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
