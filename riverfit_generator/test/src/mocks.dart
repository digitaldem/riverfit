import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source.dart';
import 'package:mockito/annotations.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:riverfit_generator/src/generator_delegates/generator_delegate.dart';
import 'package:source_gen/source_gen.dart';

@GenerateMocks([
  BuildStep,
  LibraryElement,
  LibraryReader,
  Resolver,
  GeneratorDelegate,
  ElementAnnotation,
  InterfaceType,
  InterfaceElement,
  ClassElement,
  MethodElement,
  ParameterElement,
  FieldElement,
  Source,
  DartType,
  DartObject,
])
void main() {}
