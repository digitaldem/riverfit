import 'package:test/test.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:riverfit_generator/src/visitor.dart';

void main() {
  group('VisitorForAnnotationReplacement', () {
    test('replaces @Riverfit with @Riverpod', () {
      const originalSource = '''
        @Riverfit()
        class Example {}
      ''';

      final parsedResult = parseString(content: originalSource);
      final visitor = VisitorForAnnotationReplacement(originalSource);

      parsedResult.unit.visitChildren(visitor);

      final modifiedSource = visitor.getModifiedSource();

      expect(
        modifiedSource,
        contains('@Riverpod()'),
      );
      expect(
        modifiedSource,
        isNot(contains('@Riverfit()')),
      );
    });

    test('adjusts import for riverfit_annotation to riverpod_annotation', () {
      const originalSource = '''
        import 'package:riverfit_annotation/riverfit_annotation.dart';
      ''';

      final parsedResult = parseString(content: originalSource);
      final visitor = VisitorForAnnotationReplacement(originalSource);

      parsedResult.unit.visitChildren(visitor);

      final modifiedSource = visitor.getModifiedSource();

      expect(
        modifiedSource,
        contains("import 'package:riverpod_annotation/riverpod_annotation.dart';"),
      );
      expect(
        modifiedSource,
        isNot(contains("import 'package:riverfit_annotation/riverfit_annotation.dart';")),
      );
    });

    test('preserves casing for Riverfit -> Riverpod replacement', () {
      const originalSource = '''
        @riverfit()
        @Riverfit()
        class Example {}
      ''';

      final parsedResult = parseString(content: originalSource);
      final visitor = VisitorForAnnotationReplacement(originalSource);

      parsedResult.unit.visitChildren(visitor);

      final modifiedSource = visitor.getModifiedSource();

      expect(
        modifiedSource,
        contains('@riverpod()'),
      );
      expect(
        modifiedSource,
        contains('@Riverpod()'),
      );
      expect(
        modifiedSource,
        isNot(contains('@riverfit()')),
      );
      expect(
        modifiedSource,
        isNot(contains('@Riverfit()')),
      );
    });

    test('handles source without Riverfit annotations or imports', () {
      const originalSource = '''
        class Example {}
      ''';

      final parsedResult = parseString(content: originalSource);
      final visitor = VisitorForAnnotationReplacement(originalSource);

      parsedResult.unit.visitChildren(visitor);

      final modifiedSource = visitor.getModifiedSource();

      expect(modifiedSource, equals(originalSource));
    });

    test('handles multiple imports and annotations', () {
      const originalSource = '''
        import 'package:riverfit_annotation/riverfit_annotation.dart';
        import 'package:other_package/other.dart';

        @Riverfit()
        @SomeOtherAnnotation()
        class Example {}
      ''';

      final parsedResult = parseString(content: originalSource);
      final visitor = VisitorForAnnotationReplacement(originalSource);

      parsedResult.unit.visitChildren(visitor);

      final modifiedSource = visitor.getModifiedSource();

      expect(
        modifiedSource,
        contains("import 'package:riverpod_annotation/riverpod_annotation.dart';"),
      );
      expect(
        modifiedSource,
        contains("import 'package:other_package/other.dart';"),
      );
      expect(
        modifiedSource,
        contains('@Riverpod()'),
      );
      expect(
        modifiedSource,
        contains('@SomeOtherAnnotation()'),
      );
      expect(
        modifiedSource,
        isNot(contains('@Riverfit()')),
      );
    });
  });
}
