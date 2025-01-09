import 'package:test/test.dart';
import 'package:riverfit_annotation/riverfit_annotation.dart';

void main() {
  group('RiverfitAnnotation', () {
    test('Default constructor sets keepAlive to false and dependencies to null', () {
      const annotation = Riverfit();

      expect(annotation.keepAlive, isFalse);
      expect(annotation.dependencies, isNull);
    });

    test('Constructor allows setting keepAlive to true', () {
      const annotation = Riverfit(keepAlive: true);

      expect(annotation.keepAlive, isTrue);
    });

    test('Constructor allows setting dependencies', () {
      const mockDependencies = [Object(), Object()];
      const annotation = Riverfit(dependencies: mockDependencies);

      expect(annotation.dependencies, equals(mockDependencies));
    });

    test('Constant riverfit uses the default constructor', () {
      expect(riverfit.keepAlive, isFalse);
      expect(riverfit.dependencies, isNull);
    });
  });
}
