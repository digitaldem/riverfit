import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:riverpod_generator/src/riverpod_generator.dart';

import './generator_delegate.dart';

@immutable
class RiverpodGeneratorDelegate implements GeneratorDelegate {
  final Map<String, Object?> mapConfig;

  RiverpodGeneratorDelegate(this.mapConfig);

  /// Generates code for a Riverpod provider via RiverpodGenerator
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Validate annotated elements exist
    final annotatedElements = library.annotatedWithExact(riverpodTypeChecker);
    if (annotatedElements.isEmpty) {
      return '';
    }

    // Validate the annotated element type
    for (final annotatedElement in annotatedElements) {
      if (annotatedElement.element is! ClassElement) {
        throw InvalidGenerationSourceError('@Riverfit can only be applied to classes.', element: annotatedElement.element);
      }
    }

    return await RiverpodGenerator(mapConfig).generate(library, buildStep);
  }
}
