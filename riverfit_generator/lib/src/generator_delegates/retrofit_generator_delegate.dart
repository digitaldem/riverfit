import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import '../generator.dart';
import './generator_delegate.dart';

@immutable
class RetrofitGeneratorDelegate extends GeneratorDelegate {
  final Map<String, Object?> mapConfig; // Currently not used, Left for consistency
  RetrofitGeneratorDelegate(this.mapConfig);

  /// Generates code for an extension class containing wrapper methods for Retrofit members
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Validate annotated elements exist
    final annotatedElements = library.annotatedWithExact(riverfitTypeChecker);
    if (annotatedElements.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    // Validate the annotated element type
    for (final annotatedElement in annotatedElements) {
      if (annotatedElement.element is! ClassElement) {
        throw InvalidGenerationSourceError('@Riverfit can only be applied to classes.', element: annotatedElement.element);
      }

      // Collect matching fields
      final element = annotatedElement.element as ClassElement;
      final matchingFields = element.fields.where((field) {
        if (field.isStatic) {
          return false;
        }
        final fieldType = field.type.element;
        return fieldType is ClassElement && _classHasAnnotation(fieldType, restApiTypeChecker);
      }).toList();

      // Ensure there are matching members
      if (matchingFields.isEmpty) {
        return '';
      }

      // Begin extension declaration
      buffer.writeln('extension ${element.displayName}Extension on ${element.displayName} {');

      // Iterate over the matching members
      for (final field in matchingFields) {
        final fieldType = field.type.element as ClassElement;

        // Generate wrapper methods for each HTTP Method annotated method in the RestApi class
        for (final method in fieldType.methods.where((method) => method.isAbstract)) {
          if (_methodHasAnnotation(method, methodTypeChecker)) {
            buffer.writeln(_generateMethodWrapper(field.name, method));
          }
        }
      }

      // Close extension declaration
      buffer.writeln('}');
    }

    // All done, return the generated code
    return buffer.toString();
  }

  /// Checks if a class has the specified annotation
  bool _classHasAnnotation(ClassElement element, TypeChecker typeChecker) {
    return typeChecker.hasAnnotationOf(element);
  }

  /// Checks if a method has the specified annotation
  bool _methodHasAnnotation(MethodElement method, TypeChecker typeChecker) {
    return method.metadata.any((annotation) {
      final constantValue = annotation.computeConstantValue();
      return constantValue != null && typeChecker.isAssignableFromType(constantValue.type!);
    });
  }

  /// Generates the extension method that wraps the member method
  String _generateMethodWrapper(String memberName, MethodElement method) {
    final buffer = StringBuffer();

    // Method signature
    buffer.write('  ${method.returnType.getDisplayString()} ${method.name}(');

    // Method parameters
    final parameters = method.parameters.map((param) => '${param.type.getDisplayString()} ${param.name}').join(', ');
    buffer.write(parameters);
    buffer.writeln(') {');

    // Method body
    buffer.write('    return $memberName.${method.name}(');

    // Method arguments
    if (method.parameters.isNotEmpty) {
      final arguments = method.parameters.map((param) => param.name).join(', ');
      buffer.writeln();
      buffer.writeln('      $arguments');
      buffer.write('    ');
    }
    buffer.writeln(');');
    buffer.writeln('  }');

    return buffer.toString();
  }
}
