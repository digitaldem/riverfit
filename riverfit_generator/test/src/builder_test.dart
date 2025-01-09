import 'package:build/build.dart';
import 'package:riverfit_generator/src/builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  group('riverfitBuilder', () {
    test('should create a SharedPartBuilder', () {
      final options = BuilderOptions({'key': 'value'});
      final builder = riverfitBuilder(options);

      // Verify the builder is of the correct type
      expect(builder, isA<SharedPartBuilder>());
    });

    test('should use correct build extensions', () {
      final options = BuilderOptions({});
      final builder = riverfitBuilder(options);

      // Validate the build extensions
      final buildExtensions = builder.buildExtensions;
      expect(buildExtensions.containsKey('.dart'), isTrue);

      final extensions = buildExtensions['.dart'];
      expect(
        extensions,
        containsAll([
          '.riverfit.riverpod.g.part',
          '.riverfit.retrofit.g.part',
        ]),
      );
    });
  });
}
