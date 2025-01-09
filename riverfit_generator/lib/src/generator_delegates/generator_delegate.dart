import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

@immutable
abstract class GeneratorDelegate {
  Future<String> generate(LibraryReader library, BuildStep buildStep);
}
