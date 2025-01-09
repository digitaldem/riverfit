import 'package:mockito/mockito.dart';
import 'package:riverfit_generator/src/generator_delegates/retrofit_generator_delegate.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../mocks.mocks.dart';
import './mock_riverfit_library.dart';

void main() {
  group('RetrofitGeneratorDelegate', () {
    late RetrofitGeneratorDelegate generator;
    late MockLibraryReader libraryReader;
    late MockBuildStep buildStep;

    setUp(() {
      generator = RetrofitGeneratorDelegate({});
      libraryReader = MockLibraryReader();
      buildStep = MockBuildStep();
    });

    test('aborts when not annotated with @Riverfit', () async {
      // Arrange
      when(libraryReader.annotatedWithExact(any)).thenReturn([]);

      // Act
      final result = await generator.generate(libraryReader, buildStep);

      // Assert
      expect(result, '');
    });

    test('throws error when @Riverfit is applied to non-class elements', () async {
      // Arrange
      when(libraryReader.annotatedWithExact(any)).thenReturn([
        AnnotatedElement(ConstantReader(null), MockFieldElement()),
      ]);

      // Act & Assert
      expect(
        () async => await generator.generate(libraryReader, buildStep),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });

    test('generates wrapper methods for fields that are classes annotated with @RestApi', () async {
      // Arrange
      final mockLibrary = createMockLibraryElementWithRestApiMember();
      when(libraryReader.annotatedWithExact(any)).thenReturn(mockLibrary);

      // Act
      final result = await generator.generate(libraryReader, buildStep);

      // Assert
      expect(result, contains('extension ApiClientExtension on ApiClient'));

      expect(result, contains('Future<String> fetchData()'));
      expect(result, contains('return api.fetchData();'));

      expect(result, contains('Future<void> pushData(int id)'));
      expect(result, contains('return api.pushData'));
    });

    test('skips fields that are not classes annotated with @RestApi', () async {
      // Arrange
      final mockLibrary = createMockLibraryElementWithoutRestApiMember();
      when(libraryReader.annotatedWithExact(any)).thenReturn(mockLibrary);

      // Act
      final result = await generator.generate(libraryReader, buildStep);

      // Assert
      expect(result, isNot(contains('extension')));
    });
  });
}
