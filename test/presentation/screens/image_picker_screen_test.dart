import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:employment_department/presentation/bloc/image_picker/image_picker_cubit.dart';
import 'package:employment_department/presentation/bloc/image_picker/image_picker_state.dart';
import 'package:employment_department/presentation/screens/image_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePickerCubit extends MockCubit<ImagePickerState>
    implements ImagePickerCubit {}

class MockFile extends Mock implements File {}

void main() {
  late MockImagePickerCubit mockCubit;
  late MockFile mockFile;

  setUp(() {
    mockCubit = MockImagePickerCubit();
    mockFile = MockFile();

    // Setup mock file path
    when(() => mockFile.path).thenReturn('/test/path/image.jpg');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ImagePickerCubit>.value(
        value: mockCubit,
        child: const ImagePickerScreen(),
      ),
    );
  }

  group('ImagePickerScreen', () {
    testWidgets('displays app bar with title', (tester) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Select Image'), findsOneWidget);
    });

    testWidgets('displays placeholder when no image is selected', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.text('No image selected\nTap a button below to select an image'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    });

    testWidgets('displays camera and gallery buttons', (tester) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());

      await tester.pumpWidget(createWidgetUnderTest());

      // Validates: Requirement 8.1 - Display options to select from Camera or Gallery
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    });

    testWidgets('displays "Select Image Source" label', (tester) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Select Image Source'), findsOneWidget);
    });

    testWidgets('calls pickFromCamera when camera button is tapped', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());
      when(() => mockCubit.pickFromCamera()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Validates: Requirement 8.2 - Open the device camera for capturing an image
      await tester.tap(find.text('Camera'));
      await tester.pump();

      verify(() => mockCubit.pickFromCamera()).called(1);
    });

    testWidgets('calls pickFromGallery when gallery button is tapped', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());
      when(() => mockCubit.pickFromGallery()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Validates: Requirement 8.3 - Open the device gallery for selecting an image
      await tester.tap(find.text('Gallery'));
      await tester.pump();

      verify(() => mockCubit.pickFromGallery()).called(1);
    });

    testWidgets('displays loading indicator when picking', (tester) async {
      when(
        () => mockCubit.state,
      ).thenReturn(const ImagePickerState(status: ImagePickerStatus.picking));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Opening...'), findsOneWidget);
    });

    testWidgets('disables buttons when picking', (tester) async {
      when(
        () => mockCubit.state,
      ).thenReturn(const ImagePickerState(status: ImagePickerStatus.picking));

      await tester.pumpWidget(createWidgetUnderTest());

      // Find the ElevatedButtons and check they are disabled
      final cameraButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Camera'),
          matching: find.byType(ElevatedButton),
        ),
      );
      final galleryButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Gallery'),
          matching: find.byType(ElevatedButton),
        ),
      );

      expect(cameraButton.onPressed, isNull);
      expect(galleryButton.onPressed, isNull);
    });

    testWidgets('displays error message when permission is denied', (
      tester,
    ) async {
      // Validates: Requirement 8.6 - Display a message requesting permission if access is denied
      when(() => mockCubit.state).thenReturn(
        const ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage:
              'Camera access denied. Please grant camera permission in your device settings to capture photos.',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.text(
          'Camera access denied. Please grant camera permission in your device settings to capture photos.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('calls resetStatus when error dismiss button is tapped', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage: 'Some error',
        ),
      );
      when(() => mockCubit.resetStatus()).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      verify(() => mockCubit.resetStatus()).called(1);
    });

    testWidgets('displays clear button when image is selected', (tester) async {
      when(() => mockCubit.state).thenReturn(
        ImagePickerState(
          status: ImagePickerStatus.success,
          selectedImage: mockFile,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('does not display clear button when no image is selected', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('calls clearImage when clear button is tapped', (tester) async {
      when(() => mockCubit.state).thenReturn(
        ImagePickerState(
          status: ImagePickerStatus.success,
          selectedImage: mockFile,
        ),
      );
      when(() => mockCubit.clearImage()).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      verify(() => mockCubit.clearImage()).called(1);
    });

    testWidgets('shows snackbar when selection is cancelled', (tester) async {
      // Validates: Requirement 8.5 - Return to previous state without changes if user cancels
      final stateController = StreamController<ImagePickerState>.broadcast();

      when(() => mockCubit.state).thenReturn(const ImagePickerState());
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
      when(() => mockCubit.resetStatus()).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      // Emit cancelled state
      stateController.add(
        const ImagePickerState(status: ImagePickerStatus.cancelled),
      );
      await tester.pump();

      expect(find.text('Image selection cancelled'), findsOneWidget);

      await stateController.close();
    });
  });

  group('ImagePickerWidget', () {
    Widget createImagePickerWidget({
      void Function(File)? onImageSelected,
      VoidCallback? onImageCleared,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<ImagePickerCubit>.value(
            value: mockCubit,
            child: ImagePickerWidget(
              onImageSelected: onImageSelected,
              onImageCleared: onImageCleared,
            ),
          ),
        ),
      );
    }

    testWidgets('displays placeholder when no image is selected', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());

      await tester.pumpWidget(createImagePickerWidget());

      expect(find.text('Tap to select an image'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    });

    testWidgets('displays camera and gallery buttons', (tester) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());

      await tester.pumpWidget(createImagePickerWidget());

      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
    });

    testWidgets('calls pickFromCamera when camera button is tapped', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());
      when(() => mockCubit.pickFromCamera()).thenAnswer((_) async {});

      await tester.pumpWidget(createImagePickerWidget());

      await tester.tap(find.text('Camera'));
      await tester.pump();

      verify(() => mockCubit.pickFromCamera()).called(1);
    });

    testWidgets('calls pickFromGallery when gallery button is tapped', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const ImagePickerState());
      when(() => mockCubit.pickFromGallery()).thenAnswer((_) async {});

      await tester.pumpWidget(createImagePickerWidget());

      await tester.tap(find.text('Gallery'));
      await tester.pump();

      verify(() => mockCubit.pickFromGallery()).called(1);
    });

    testWidgets('displays loading indicator when picking', (tester) async {
      when(
        () => mockCubit.state,
      ).thenReturn(const ImagePickerState(status: ImagePickerStatus.picking));

      await tester.pumpWidget(createImagePickerWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when there is an error', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const ImagePickerState(
          status: ImagePickerStatus.error,
          errorMessage: 'Permission denied',
        ),
      );

      await tester.pumpWidget(createImagePickerWidget());

      expect(find.text('Permission denied'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('calls onImageSelected callback when image is selected', (
      tester,
    ) async {
      File? selectedFile;
      final stateController = StreamController<ImagePickerState>.broadcast();

      when(() => mockCubit.state).thenReturn(const ImagePickerState());
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(
        createImagePickerWidget(onImageSelected: (file) => selectedFile = file),
      );

      // Emit success state with image
      stateController.add(
        ImagePickerState(
          status: ImagePickerStatus.success,
          selectedImage: mockFile,
        ),
      );
      await tester.pump();

      expect(selectedFile, mockFile);

      await stateController.close();
    });

    testWidgets('calls onImageCleared callback when clear button is tapped', (
      tester,
    ) async {
      bool cleared = false;

      when(() => mockCubit.state).thenReturn(
        ImagePickerState(
          status: ImagePickerStatus.success,
          selectedImage: mockFile,
        ),
      );
      when(() => mockCubit.clearImage()).thenReturn(null);

      await tester.pumpWidget(
        createImagePickerWidget(onImageCleared: () => cleared = true),
      );

      // Find and tap the clear button (X icon on the image)
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(cleared, true);
      verify(() => mockCubit.clearImage()).called(1);
    });
  });
}
