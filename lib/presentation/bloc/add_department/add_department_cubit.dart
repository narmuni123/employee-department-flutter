import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/usecases/create_department.dart';
import 'add_department_state.dart';

class AddDepartmentCubit extends Cubit<AddDepartmentState> {
  final CreateDepartment _createDepartment;

  AddDepartmentCubit({required CreateDepartment createDepartment})
    : _createDepartment = createDepartment,
      super(const AddDepartmentState());

  void idChanged(String value) {
    final error = _validateId(value);
    emit(state.copyWith(id: value, idError: error, apiError: null));
  }

  void nameChanged(String value) {
    final error = _validateName(value);
    emit(state.copyWith(name: value, nameError: error, apiError: null));
  }

  void locationChanged(String value) {
    final error = _validateLocation(value);
    emit(state.copyWith(location: value, locationError: error, apiError: null));
  }

  String? _validateId(String value) {
    if (value.isEmpty) {
      return 'Department ID is required';
    }
    final id = int.tryParse(value);
    if (id == null) {
      return 'Department ID must be a number';
    }
    if (id <= 0) {
      return 'Department ID must be positive';
    }
    return null;
  }

  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Department name is required';
    }
    if (value.length < 2) {
      return 'Department name must be at least 2 characters';
    }
    return null;
  }

  String? _validateLocation(String value) {
    if (value.isEmpty) {
      return 'Location is required';
    }
    if (value.length < 2) {
      return 'Location must be at least 2 characters';
    }
    return null;
  }

  Future<void> submit() async {
    // Validate all fields
    final idError = _validateId(state.id);
    final nameError = _validateName(state.name);
    final locationError = _validateLocation(state.location);

    // Update state with validation errors
    emit(
      state.copyWith(
        idError: idError,
        nameError: nameError,
        locationError: locationError,
        apiError: null,
      ),
    );

    // If any validation errors, don't submit
    if (!state.isValid) {
      return;
    }

    // Start submitting
    emit(state.copyWith(isSubmitting: true, apiError: null));

    // Create department entity
    final department = Department(
      id: int.parse(state.id),
      name: state.name,
      location: state.location,
      employees: [],
    );

    // Call use case
    final result = await _createDepartment(department);

    result.fold(
      (exception) {
        // Handle error
        emit(
          state.copyWith(
            isSubmitting: false,
            apiError: _mapExceptionToMessage(exception),
          ),
        );
      },
      (department) {
        // Handle success
        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            successMessage:
                'Department "${department.name}" added successfully',
          ),
        );
      },
    );
  }

  String _mapExceptionToMessage(AppException exception) {
    return switch (exception) {
      NetworkException() => 'No internet connection',
      ServerException(statusCode: 404) => 'Resource not found',
      ServerException(statusCode: 409) => 'Department ID already exists',
      ServerException(statusCode: 500) =>
        'Server error, please try again later',
      ServerException(:final message) => message,
      ValidationException(:final message) => message,
      ParsingException(:final message) => 'Data parsing error: $message',
    };
  }
}
