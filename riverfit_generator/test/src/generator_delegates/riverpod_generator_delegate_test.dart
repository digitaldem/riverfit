import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:mockito/mockito.dart';
import 'package:riverfit_generator/src/generator_delegates/riverpod_generator_delegate.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../mocks.mocks.dart';
import './mock_riverfit_library.dart';

void main() {
  group('RiverpodGeneratorDelegate', () {
    late RiverpodGeneratorDelegate generator;
    late MockLibraryReader libraryReader;
    late MockBuildStep buildStep;
    late MockResolver resolver;

    setUp(() {
      generator = RiverpodGeneratorDelegate({});
      libraryReader = MockLibraryReader();
      buildStep = MockBuildStep();
      resolver = MockResolver();
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

    test('forwards call to RiverpodGenerator.generate', () async {
      // Arrange
      final mockLibrary = createMockLibraryElementWithoutRestApiMember();
      when(libraryReader.annotatedWithExact(any)).thenReturn(mockLibrary);
      final parsedResult = parseString(content: '''
        import 'package:riverpod_annotation/riverpod_annotation.dart';

        @Riverpod()
        class ApiClient {
          @override
          Future<ApiClient> build() async {
            return this;
          }
        }
      ''');
      when(resolver.astNodeFor(any, resolve: true)).thenAnswer((_) async => parsedResult.unit);
      when(buildStep.resolver).thenReturn(resolver);

      // Act
      final result = await generator.generate(libraryReader, buildStep);
      // Note: generator.generate() won't actually return any riverpod code with these simple mocks
      //       becasue it is not necessary to test any riverpod_generator behavior here

      // Assert
      expect(result, '');
    });
  });
}
