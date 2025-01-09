import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

/// Annotation to mark classes for Riverfit processing.
@Target({TargetKind.classType})
@sealed
class Riverfit {
  /// Whether the state of the provider should be maintained if it is no-longer used.
  ///
  /// Defaults to false.
  final bool keepAlive;

  /// The list of providers that this provider potentially depends on.
  ///
  /// This list must contains the classes/functions annotated with `@riverpod`,
  /// not the generated providers themselves.
  final List<Object>? dependencies;

  const Riverfit({
    this.keepAlive = false,
    this.dependencies,
  });
}

const riverfit = Riverfit();
