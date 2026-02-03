import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/add_department/add_department_cubit.dart';
import '../bloc/add_department/add_department_state.dart';
import '../widgets/custom_text_field.dart';

class AddDepartmentScreen extends StatelessWidget {
  const AddDepartmentScreen({super.key});

  void _onSubmitPressed(BuildContext context) {
    context.read<AddDepartmentCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Department'), centerTitle: true),
      body: BlocConsumer<AddDepartmentCubit, AddDepartmentState>(
        listener: (context, state) {
          // Navigate back on success and show success message
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.successMessage ?? 'Department added successfully',
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
                    Icons.business_center,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'New Department',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the details below to add a new department',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Department ID field
                  CustomTextField(
                    label: 'Department ID',
                    hint: 'Enter numeric department ID',
                    value: state.id,
                    errorText: state.idError,
                    onChanged: (value) {
                      context.read<AddDepartmentCubit>().idChanged(value);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: Icons.tag,
                    textInputAction: TextInputAction.next,
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Department Name field
                  CustomTextField(
                    label: 'Department Name',
                    hint: 'Enter department name',
                    value: state.name,
                    errorText: state.nameError,
                    onChanged: (value) {
                      context.read<AddDepartmentCubit>().nameChanged(value);
                    },
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.business,
                    textInputAction: TextInputAction.next,
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Location field
                  CustomTextField(
                    label: 'Location',
                    hint: 'Enter department location',
                    value: state.location,
                    errorText: state.locationError,
                    onChanged: (value) {
                      context.read<AddDepartmentCubit>().locationChanged(value);
                    },
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.location_on,
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
                              'Add Department',
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
