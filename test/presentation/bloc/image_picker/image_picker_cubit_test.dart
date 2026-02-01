import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/core/services/image_picker_service.dart';
import 'package:employment_department/presentation/bloc/image_picker/image_picker_cubit.dart';
import 'package:employment_department/presentation/bloc/image_picker/image_picker_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePickerService extends Mock implements ImagePickerService {}

class MockFile extends Mock implements File {}

void main() {
  late MockImagePickerService mockImagePickerService;
  late ImagePickerCubit imagePickerCubit;
  late MockFile mockFile;

  setUp(() {
    mockImagePickerService = MockImagePickerService();
    mockFile = MockFile();
    imagePickerCubit = ImagePickerCubit(
      imagePickerService: mockImagePickerService,
    );

    // Setup mock file path for equality checks
    when(() => mockFile.path).thenReturn('/test/path/image.jpg');
  });

  tearDown(() {
    imagePickerCubit.close();
  });

  group('ImagePickerCubit', () {
    test('initial state is correct', () {
      expect(imagePickerCubit.state, const ImagePickerState());
      expect(imagePickerCubit.state.status, ImagePickerStatus.initial);
      expect(imagePickerCubit.state.selectedImage, null);
      expect(imagePickerCubit.state.errorMessage, null);
      expect(imagePickerCubit.state.isPicking, false);
      expect(imagePickerCubit.state.hasImage, false);
      expect(imagePickerCubit.state.hasError, false);
      expect(imagePickerCubit.state.wasCancelled, false);
    });

    group('pickFromCamera', () {
      blocTest<ImagePickerCubit, ImagePickerState>(
        'emits picking then success when image is captured successfully',
        build: () {
          when(
            () => mockImagePickerService.pickImage(ImageSource.camera),
          ).thenAnswer((_) async => Right(mockFile));
          return ImagePickerCubit(imagePickerService: mockImagePickerService);
        },
        act: (cubit) => cubit.pickFromCamera(),
        expect: () => [
          const ImagePickerState(status: ImagePickerStatus.picking),
          ImagePickerState(
            status: ImagePickerStatus.success,
            selectedImage: mockFile,
          ),
        ],
        verify: (_) {
          verify(
            () => mockImagePickerService.pickImage(ImageSource.camera),
          ).called(1);
        },
      );

      blocTest<ImagePickerCubit, ImagePickerState>(
        'emits picking then cancelled when user cancels camera',
        build: () {
          when(
            () => mockImagePickerService.pickImage(ImageSource.camera),
          ).thenAnswer((_) async => const Right(null));
          return ImagePickerCubit(imagePickerService: mockImagePickerService);
        },
        act: (cubit) => cubit.pickFromCamera(),
        expect: () => [
          const ImagePickerState(status: ImagePickerStatus.picking),
          const ImagePickerState(status: ImagePickerStatus.cancelled),
        ],
      );

      blocTest<ImagePickerCubit, ImagePickerState>(
        'emits picking then error when camera permission is denied',
        build: () {
          when(
            () => mockImagePickerService.pickImage(ImageSource.camera),
          ).thenAnswer(
            (_) async => Left(
              ServerException(
                403,
                'Camera access denied. Please grant camera permission in your device settings to capture photos.',
              ),
            ),
          );
          return ImagePickerCubit(imagePickerService: mockImagePickerService);
        },
        act: (cubit) => cubit.pickFromCamera(),
        expect: () => [
          const ImagePickerState(status: ImagePickerStatus.picking),
          const ImagePickerState(
            status: ImagePickerStatus.error,
            errorMessage:
                'Camera access denied. Please grant camera permission in your device settings to capture photos.',
          ),
        ],
      );
    });

    group('pickFromGallery', () {
      blocTest<ImagePickerCubit, ImagePickerState>(
        'emits picking then success when image is selected successfully',
        build: () {
          when(
            () => mockImagePickerService.pickImage(ImageSource.gallery),
          ).thenAnswer((_) async => Right(mockFile));
          return ImagePickerCubit(imagePickerService: mockImagePickerService);
        },
        act: (cubit) => cubit.pickFromGallery(),
        expect: () => [
          const ImagePickerState(status: ImagePickerStatus.picking),
          ImagePickerState(
            status: ImagePickerStatus.success,
            selectedImage: mockFile,
          ),
        ],
        verify: (_) {
          verify(
            () => mockImagePickerService.pickImage(ImageSource.gallery),
          ).called(1);
        },
      );

      blocTest<ImagePickerCubit, ImagePickerState>(
        'emits picking then cancelled when user cancels gallery selection',
        build: () {
          when(
            () => mockImagePickerService.pickImage(ImageSource.gallery),
          ).thenAnswer((_) async => const Right(null));
          return ImagePickerCubit(imagePickerService: mockImagePickerService);
        },
        act: (cubit) => cubit.pickFromGallery(),
        expect: () => [
          const ImagePickerState(status: ImagePickerStatus.picking),
          const ImagePickerState(status: ImagePickerStatus.cancelled),
        ],
      );

      blocTest<ImagePickerCubit, ImagePickerState>(
        'emits picking then error when gallery permission is denied',
        build: () {
          when(
            () => mockImagePickerService.pickImage(ImageSource.gallery),
          ).thenAnswer(
            (_) async => Left(
              ServerException(
                403,
                'Photo library access denied. Please grant photo library permission in your device settings to select images.',
              ),
            ),
          );
          return ImagePickerCubit(imagePickerService: mockImagePickerService);
        },
        act: (cubit) => cubit.pickFromGallery(),
        expect: () => [
          const ImagePickerState(status: ImagePickerStatus.picking),
          const ImagePickerState(
            status: ImagePickerStatus.error,
            errorMessage:
                'Photo library access denied. Please grant photo library permission in your device settings to select images.',
          ),
        ],
      );
    });

    group('clearImage', () {
      blocTest<ImagePickerCubit, ImagePickerState>(
        'resets state to initial when clearing image',
        build: () =>
            ImagePickerCubit(imagePickerService: mockImagePickerService),
        seed: () => ImagePickerState(
          status: ImagePickerStatus.success,
          selectedImage: mockFile,
        ),
        act: (cubit) => cubit.clearImage(),
        expect: () => [const ImagePickerState()],
      );
    });

    group('resetStatus', () {
      blocTest<ImagePickerCubit, ImagePickerState>(
        'resets to success status when image exists',
        build: () =>
            ImagePickerCubit(imagePickerService: mockImagePickerService),
        seed: () => ImagePickerState(
          status: ImagePickerStatus.error,
          selectedImage: mockFile,
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.resetStatus(),
        expect: () => [
          ImagePickerState(
            status: ImagePickerStatus.success,
            selectedImage: mockFile,
          ),
        ],
      );

      blocTest<ImagePickerCubit, ImagePickerState>(
        'resets to initial status when no image exists',
        build: () =>
            ImagePickerCubit(imagePickerService: mockImagePickerService),
        seed: () => const ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.resetStatus(),
        expect: () => [
          const ImagePickerState(status: ImagePickerStatus.initial),
        ],
      );

      blocTest<ImagePickerCubit, ImagePickerState>(
        'clears error message when resetting status',
        build: () =>
            ImagePickerCubit(imagePickerService: mockImagePickerService),
        seed: () => const ImagePickerState(
          status: ImagePickerStatus.cancelled,
          errorMessage: 'Previous error',
        ),
        act: (cubit) => cubit.resetStatus(),
        expect: () => [
          const ImagePickerState(status: ImagePickerStatus.initial),
        ],
      );
    });

    group('state properties', () {
      test('isPicking returns true when status is picking', () {
        const state = ImagePickerState(status: ImagePickerStatus.picking);
        expect(state.isPicking, true);
      });

      test('isPicking returns false when status is not picking', () {
        const state = ImagePickerState(status: ImagePickerStatus.success);
        expect(state.isPicking, false);
      });

      test('hasImage returns true when selectedImage is not null', () {
        final state = ImagePickerState(
          status: ImagePickerStatus.success,
          selectedImage: mockFile,
        );
        expect(state.hasImage, true);
      });

      test('hasImage returns false when selectedImage is null', () {
        const state = ImagePickerState(status: ImagePickerStatus.initial);
        expect(state.hasImage, false);
      });

      test('hasError returns true when status is error', () {
        const state = ImagePickerState(status: ImagePickerStatus.error);
        expect(state.hasError, true);
      });

      test('hasError returns false when status is not error', () {
        const state = ImagePickerState(status: ImagePickerStatus.success);
        expect(state.hasError, false);
      });

      test('wasCancelled returns true when status is cancelled', () {
        const state = ImagePickerState(status: ImagePickerStatus.cancelled);
        expect(state.wasCancelled, true);
      });

      test('wasCancelled returns false when status is not cancelled', () {
        const state = ImagePickerState(status: ImagePickerStatus.success);
        expect(state.wasCancelled, false);
      });
    });

    group('state copyWith', () {
      test('copyWith creates new state with updated status', () {
        const original = ImagePickerState(status: ImagePickerStatus.initial);
        final updated = original.copyWith(status: ImagePickerStatus.picking);
        expect(updated.status, ImagePickerStatus.picking);
        expect(updated.selectedImage, null);
        expect(updated.errorMessage, null);
      });

      test('copyWith creates new state with updated selectedImage', () {
        const original = ImagePickerState(status: ImagePickerStatus.initial);
        final updated = original.copyWith(selectedImage: () => mockFile);
        expect(updated.status, ImagePickerStatus.initial);
        expect(updated.selectedImage, mockFile);
      });

      test('copyWith creates new state with updated errorMessage', () {
        const original = ImagePickerState(status: ImagePickerStatus.initial);
        final updated = original.copyWith(errorMessage: () => 'Test error');
        expect(updated.status, ImagePickerStatus.initial);
        expect(updated.errorMessage, 'Test error');
      });

      test('copyWith can set selectedImage to null', () {
        final original = ImagePickerState(
          status: ImagePickerStatus.success,
          selectedImage: mockFile,
        );
        final updated = original.copyWith(selectedImage: () => null);
        expect(updated.selectedImage, null);
      });

      test('copyWith can set errorMessage to null', () {
        const original = ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage: 'Some error',
        );
        final updated = original.copyWith(errorMessage: () => null);
        expect(updated.errorMessage, null);
      });
    });

    group('state equality', () {
      test('two states with same values are equal', () {
        const state1 = ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage: 'Test error',
        );
        const state2 = ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage: 'Test error',
        );
        expect(state1, state2);
      });

      test('two states with different status are not equal', () {
        const state1 = ImagePickerState(status: ImagePickerStatus.initial);
        const state2 = ImagePickerState(status: ImagePickerStatus.picking);
        expect(state1, isNot(state2));
      });

      test('two states with different errorMessage are not equal', () {
        const state1 = ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage: 'Error 1',
        );
        const state2 = ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage: 'Error 2',
        );
        expect(state1, isNot(state2));
      });
    });
  });
}
