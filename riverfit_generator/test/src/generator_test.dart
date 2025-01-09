import 'package:build/build.dart';
import 'package:mockito/mockito.dart';
import 'package:riverfit_generator/src/generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import './mocks.mocks.dart';

final AssetId inputAssetId = AssetId('test', 'lib/test_file.dart');
final AssetId riverpodAssetId = AssetId('test', 'lib/test_file.riverpod.g.dart');
final AssetId retrofitAssetId = AssetId('test', 'lib/test_file.retrofit.g.dart');

void main() {
  group('RiverfitGenerator', () {
    late MockBuildStep buildStep;
    late MockLibraryElement libraryElement;
    late MockLibraryReader libraryReader;
    late MockResolver resolver;
    late MockGeneratorDelegate riverpodGeneratorDelegate;
    late MockGeneratorDelegate retrofitGeneratorDelegate;
    late RiverfitGenerator generator;

    setUp(() {
      buildStep = MockBuildStep();
      libraryElement = MockLibraryElement();
      libraryReader = MockLibraryReader();
      resolver = MockResolver();
      riverpodGeneratorDelegate = MockGeneratorDelegate();
      retrofitGeneratorDelegate = MockGeneratorDelegate();
      generator = RiverfitGenerator(riverpodGeneratorDelegate, retrofitGeneratorDelegate);
    });

    mockForSuccess() {
      // Mock LibraryReader behavior
      final annotatedElement = AnnotatedElement(ConstantReader(null), libraryElement);
      when(libraryReader.annotatedWith(any)).thenReturn([annotatedElement]);
      when(libraryReader.annotatedWithExact(any)).thenReturn([annotatedElement]);

      // Mock BuildStep behavior
      when(buildStep.inputId).thenReturn(inputAssetId);
      when(buildStep.readAsString(any)).thenAnswer((_) async => '');
      when(buildStep.allowedOutputs).thenReturn([
        riverpodAssetId,
        retrofitAssetId,
      ]);
      when(buildStep.resolver).thenReturn(resolver);

      // Mock Resolver behavior
      when(resolver.libraryFor(any)).thenAnswer((_) async => libraryElement);
    }

    test('returns empty string if no annotated elements', () async {
      // Arrange
      when(libraryReader.annotatedWith(any)).thenReturn([]);

      // Act
      final result = await generator.generate(libraryReader, buildStep);

      // Assert
      expect(result, isEmpty);
      verifyNever(buildStep.writeAsString(any, any));
      verifyNever(riverpodGeneratorDelegate.generate(any, any));
      verifyNever(retrofitGeneratorDelegate.generate(any, any));
    });

    test('generates code for annotated elements', () async {
      // Arrange
      mockForSuccess();
      // Mock GeneratorDelegates behavior
      when(riverpodGeneratorDelegate.generate(any, any)).thenAnswer((_) async => 'Riverpod code');
      when(retrofitGeneratorDelegate.generate(any, any)).thenAnswer((_) async => 'Retrofit code');

      // Act
      final result = await generator.generate(libraryReader, buildStep);

      // Assert
      verify(buildStep.writeAsString(
        riverpodAssetId,
        any,
      )).called(1);
      verify(buildStep.writeAsString(
        retrofitAssetId,
        any,
      )).called(1);
      expect(result, contains('Riverpod code'));
      expect(result, contains('Retrofit code'));
    });

    test('handles error in modifying source annotations', () async {
      // Arrange
      mockForSuccess();
      // Mock BuildStep behavior
      when(buildStep.readAsString(any)).thenAnswer((_) async => 'malformed source');

      // Act & Assert
      expect(
        () async => await generator.generate(libraryReader, buildStep),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });

    test('handles delegate generation failures gracefully (riverpod)', () async {
      // Arrange
      mockForSuccess();
      // Mock GeneratorDelegates behavior
      when(riverpodGeneratorDelegate.generate(any, any)).thenThrow(Exception('Riverpod generation failed'));
      when(retrofitGeneratorDelegate.generate(any, any)).thenAnswer((_) async => 'Retrofit code');

      // Act & Assert
      expect(
        () async => await generator.generate(libraryReader, buildStep),
        throwsA(isA<Exception>().having((e) => e.toString(), 'description', contains('Riverpod generation failed'))),
      );
    });

    test('handles delegate generation failures gracefully (retrofit)', () async {
      // Arrange
      mockForSuccess();
      // Mock GeneratorDelegates behavior
      when(riverpodGeneratorDelegate.generate(any, any)).thenAnswer((_) async => 'Riverpod code');
      when(retrofitGeneratorDelegate.generate(any, any)).thenThrow(Exception('Retrofit generation failed'));

      // Act & Assert
      expect(
        () async => await generator.generate(libraryReader, buildStep),
        throwsA(isA<Exception>().having((e) => e.toString(), 'description', contains('Retrofit generation failed'))),
      );
    });

    test('throws StateError when output path not found in allowedOutputs', () async {
      // Arrange
      mockForSuccess();
      when(buildStep.inputId).thenReturn(AssetId('test', 'lib/test_file.dart'));
      when(buildStep.allowedOutputs).thenReturn([]);

      // Act & Assert
      expect(
        () => generator.generate(libraryReader, buildStep),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Output path containing ".riverpod.g" not found in allowedOutputs'),
          ),
        ),
      );
    });
  });
}
