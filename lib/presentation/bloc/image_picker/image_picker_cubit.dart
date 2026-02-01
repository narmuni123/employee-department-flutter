import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/image_picker_service.dart';
import 'image_picker_state.dart';

class ImagePickerCubit extends Cubit<ImagePickerState> {
  final ImagePickerService _imagePickerService;

  ImagePickerCubit({required ImagePickerService imagePickerService})
    : _imagePickerService = imagePickerService,
      super(const ImagePickerState());

  Future<void> pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    emit(
      state.copyWith(
        status: ImagePickerStatus.picking,
        errorMessage: () => null,
      ),
    );

    final result = await _imagePickerService.pickImage(source);

    result.fold(
      (exception) {
        emit(
          state.copyWith(
            status: ImagePickerStatus.error,
            errorMessage: () => exception.message,
          ),
        );
      },
      (file) {
        if (file == null) {
          emit(state.copyWith(status: ImagePickerStatus.cancelled));
        } else {
          emit(
            state.copyWith(
              status: ImagePickerStatus.success,
              selectedImage: () => file,
              errorMessage: () => null,
            ),
          );
        }
      },
    );
  }

  void clearImage() {
    emit(const ImagePickerState());
  }

  void resetStatus() {
    if (state.hasImage) {
      emit(
        state.copyWith(
          status: ImagePickerStatus.success,
          errorMessage: () => null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: ImagePickerStatus.initial,
          errorMessage: () => null,
        ),
      );
    }
  }
}
