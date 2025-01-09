import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import './generator_delegates/retrofit_generator_delegate.dart';
import './generator_delegates/riverpod_generator_delegate.dart';
import './generator.dart';

/// Builds generators for `build_runner` to run
Builder riverfitBuilder(BuilderOptions options) => SharedPartBuilder(
      [
        RiverfitGenerator(
          RiverpodGeneratorDelegate(options.config),
          RetrofitGeneratorDelegate(options.config),
        ),
      ],
      'riverfit',
      additionalOutputExtensions: [
        '.riverfit.riverpod.g.part',
        '.riverfit.retrofit.g.part',
      ],
    );
