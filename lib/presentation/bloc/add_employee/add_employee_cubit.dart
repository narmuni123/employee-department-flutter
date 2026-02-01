import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/usecases/add_employee.dart';
import 'add_employee_state.dart';

class AddEmployeeCubit extends Cubit<AddEmployeeState> {
  final AddEmployee _addEmployee;
  final int departmentId;

  AddEmployeeCubit({
    required AddEmployee addEmployee,
    required this.departmentId,
  }) : _addEmployee = addEmployee,
       super(const AddEmployeeState());

  void idChanged(String id) {
    final idError = Validators.validateEmployeeId(id);
    final newErrors = Map<String, String?>.from(state.errors);
    newErrors['id'] = idError;
    emit(state.copyWith(id: id, errors: newErrors, apiError: () => null));
  }

  void nameChanged(String name) {
    final nameError = Validators.validateEmployeeName(name);
    final newErrors = Map<String, String?>.from(state.errors);
    newErrors['name'] = nameError;
    emit(state.copyWith(name: name, errors: newErrors, apiError: () => null));
  }

  void emailChanged(String email) {
    final emailError = Validators.validateEmail(email);
    final newErrors = Map<String, String?>.from(state.errors);
    newErrors['email'] = emailError;
    emit(state.copyWith(email: email, errors: newErrors, apiError: () => null));
  }

  void positionChanged(String position) {
    final positionError = Validators.validatePosition(position);
    final newErrors = Map<String, String?>.from(state.errors);
    newErrors['position'] = positionError;
    emit(
      state.copyWith(
        position: position,
        errors: newErrors,
        apiError: () => null,
      ),
    );
  }

  void salaryChanged(String salary) {
    final salaryError = Validators.validateSalary(salary);
    final newErrors = Map<String, String?>.from(state.errors);
    newErrors['salary'] = salaryError;
    emit(
      state.copyWith(salary: salary, errors: newErrors, apiError: () => null),
    );
  }

  void validateForm() {
    final newErrors = <String, String?>{
      'id': Validators.validateEmployeeId(state.id),
      'name': Validators.validateEmployeeName(state.name),
      'email': Validators.validateEmail(state.email),
      'position': Validators.validatePosition(state.position),
      'salary': Validators.validateSalary(state.salary),
    };

    emit(state.copyWith(errors: newErrors));
  }

  Future<void> submit() async {
    validateForm();

    if (!state.isValid) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, apiError: () => null));

    final employee = Employee(
      id: int.parse(state.id),
      name: state.name,
      email: state.email,
      position: state.position,
      salary: double.parse(state.salary),
    );

    final result = await _addEmployee(departmentId, employee);

    result.fold(
      (exception) {
        emit(
          state.copyWith(
            isSubmitting: false,
            apiError: () => exception.message,
          ),
        );
      },
      (createdEmployee) {
        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            successMessage: () => 'Employee added successfully',
          ),
        );
      },
    );
  }

  void reset() {
    emit(const AddEmployeeState());
  }
}
