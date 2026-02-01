import 'package:equatable/equatable.dart';

class AddEmployeeState extends Equatable {
  final String id;
  final String name;
  final String email;
  final String position;
  final String salary;
  final Map<String, String?> errors;
  final bool isSubmitting;
  final bool isSuccess;
  final String? successMessage;
  final String? apiError;

  const AddEmployeeState({
    this.id = '',
    this.name = '',
    this.email = '',
    this.position = '',
    this.salary = '',
    this.errors = const {},
    this.isSubmitting = false,
    this.isSuccess = false,
    this.successMessage,
    this.apiError,
  });

  bool get isValid =>
      errors.values.every((error) => error == null) &&
      id.isNotEmpty &&
      name.isNotEmpty &&
      email.isNotEmpty &&
      position.isNotEmpty &&
      salary.isNotEmpty;

  String? get idError => errors['id'];
  String? get nameError => errors['name'];
  String? get emailError => errors['email'];
  String? get positionError => errors['position'];
  String? get salaryError => errors['salary'];

  AddEmployeeState copyWith({
    String? id,
    String? name,
    String? email,
    String? position,
    String? salary,
    Map<String, String?>? errors,
    bool? isSubmitting,
    bool? isSuccess,
    String? Function()? successMessage,
    String? Function()? apiError,
  }) {
    return AddEmployeeState(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      successMessage: successMessage != null
          ? successMessage()
          : this.successMessage,
      apiError: apiError != null ? apiError() : this.apiError,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    position,
    salary,
    errors,
    isSubmitting,
    isSuccess,
    successMessage,
    apiError,
  ];
}
