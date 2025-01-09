import 'dart:async';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverfit_annotation/riverfit_annotation.dart';
import 'package:source_gen/source_gen.dart';

import './generator_delegates/generator_delegate.dart';
import './visitor.dart';

const riverpodOutputExtension = '.riverpod.g';
const retrofitOutputExtension = '.retrofit.g';

const riverfitTypeChecker = TypeChecker.fromRuntime(Riverfit);
const restApiTypeChecker = TypeChecker.fromRuntime(RestApi);
const methodTypeChecker = TypeChecker.fromRuntime(Method);

/// Generator for Riverfit (a union of Riverpod Generator and Retrofit Extensions)
@immutable
class RiverfitGenerator extends Generator {
  final GeneratorDelegate riverpodDelegate;
  final GeneratorDelegate retrofitDelegate;

  RiverfitGenerator(
    this.riverpodDelegate,
    this.retrofitDelegate,
  );

  /// Generates the union of the RiverpodGeneratorDelegate and the RetrofitGeneratorDelegate
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Ensure the library conatins a Riverfit element
    final annotatedElements = library.annotatedWith(riverfitTypeChecker);
    if (annotatedElements.isEmpty) {
      return '';
    }

    // Parse and modify the input source code
    final originalSource = await buildStep.readAsString(buildStep.inputId);
    final modifiedSource = _modifySourceAnnotations(originalSource);

    // Write appropriate source code to output assets and resolve the resulting LibraryElements
    final riverpodElement = await _writeAndResolve(buildStep, riverpodOutputExtension, modifiedSource);
    final retrofitElement = await _writeAndResolve(buildStep, retrofitOutputExtension, originalSource);

    // Generate the Riverpod and the Retrofit code
    final riverpodCode = await riverpodDelegate.generate(LibraryReader(riverpodElement), buildStep);
    final retrofitCode = await retrofitDelegate.generate(LibraryReader(retrofitElement), buildStep);

    // Combine the outputs
    return [riverpodCode, retrofitCode].join('\n\n');
  }

  /// Modifies annotations in the source code
  String _modifySourceAnnotations(String source) {
    try {
      final parsedResult = parseString(content: source, throwIfDiagnostics: true);
      final visitor = VisitorForAnnotationReplacement(source);
      parsedResult.unit.visitChildren(visitor);
      return visitor.getModifiedSource();
    } catch (e) {
      throw InvalidGenerationSourceError('Failed to parse or modify source for ${source}...');
    }
  }

  /// Writes supplied source code to the specified output asset and then resolves the LibraryElement of the asset
  Future<LibraryElement> _writeAndResolve(BuildStep buildStep, String outputExtension, String source) async {
    final outputAsset = _findOutputAssetId(buildStep, outputExtension);
    await buildStep.writeAsString(outputAsset, source);
    return await buildStep.resolver.libraryFor(outputAsset);
  }

  /// Find the appropriate AssetId for a given name
  AssetId _findOutputAssetId(BuildStep buildStep, String name) {
    return buildStep.allowedOutputs.firstWhere(
      (output) => output.path.contains(name),
      orElse: () => throw StateError('Output path containing "$name" not found in allowedOutputs for ${buildStep.inputId}.'),
    );
  }
}
