import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Visitor to replace `@Riverfit` with `@Riverpod` and adjust relevant imports
class VisitorForAnnotationReplacement extends GeneralizingAstVisitor<void> {
  static const _importTarget = 'riverfit_annotation';
  static const _importReplacement = 'riverpod_annotation';
  static const _annotationTarget = 'riverfit';
  static const _annotationReplacement = 'riverpod';

  final String originalSource;
  final StringBuffer buffer = StringBuffer();
  int currentOffset = 0;

  VisitorForAnnotationReplacement(this.originalSource);

  @override
  void visitImportDirective(ImportDirective node) {
    // Write the unmodified text before this import
    _appendUnmodifiedSource(node.offset);

    // Replace specific import for riverfit_annotation
    final importSource = originalSource.substring(node.offset, node.end);
    if (node.uri.stringValue?.contains(_importTarget) ?? false) {
      buffer.write(importSource.replaceAll(_importTarget, _importReplacement));
    } else {
      buffer.write(importSource);
    }

    _updateOffset(node.end);
    super.visitImportDirective(node);
  }

  @override
  void visitAnnotation(Annotation node) {
    // Write the unmodified text before this annotation
    _appendUnmodifiedSource(node.offset);

    // Replace `@Riverfit` with `@Riverpod` while preserving case
    final annotationSource = originalSource.substring(node.offset, node.end);
    if (node.name.name.toLowerCase() == _annotationTarget) {
      buffer.write(_replaceAnnotation(annotationSource));
    } else {
      buffer.write(annotationSource);
    }

    _updateOffset(node.end);
    super.visitAnnotation(node);
  }

  @override
  void visitNode(AstNode node) {
    node.visitChildren(this);
  }

  /// Returns the modified source code after all replacements
  String getModifiedSource() {
    // Append any remaining unprocessed source
    if (currentOffset < originalSource.length) {
      buffer.write(originalSource.substring(currentOffset));
    }
    return buffer.toString();
  }

  /// Writes unmodified source text from the current offset to the given end offset
  void _appendUnmodifiedSource(int endOffset) {
    if (currentOffset < endOffset) {
      buffer.write(originalSource.substring(currentOffset, endOffset));
    }
  }

  /// Updates the current offset
  void _updateOffset(int newOffset) {
    currentOffset = newOffset;
  }

  /// Replaces the annotation while preserving the case (of the first letter)
  String _replaceAnnotation(String annotationSource) {
    final index = annotationSource.toLowerCase().indexOf(_annotationTarget);
    if (index == -1) {
      return annotationSource;
    }

    // Preserve the casing of the first letter
    final originalFirstLetter = annotationSource[index];
    final replacementFirstLetter = _annotationReplacement[0];
    final replacement = (originalFirstLetter == originalFirstLetter.toUpperCase())
        ? replacementFirstLetter.toUpperCase() + _annotationReplacement.substring(1)
        : _annotationReplacement;

    return annotationSource.replaceRange(
      index,
      index + _annotationTarget.length,
      replacement,
    );
  }
}
