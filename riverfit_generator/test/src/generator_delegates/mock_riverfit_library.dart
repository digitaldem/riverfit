import 'package:analyzer/dart/element/element.dart';
import 'package:mockito/mockito.dart';
import 'package:riverfit_annotation/riverfit_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:source_gen/source_gen.dart';

import '../mocks.mocks.dart';

const mockLibraryUri = 'asset:test/lib/test_file.dart';

List<AnnotatedElement> createMockLibraryElementWithRestApiMember() {
  final source = MockSource();
  final apiClientClass = MockClassElement();
  final apiClass = MockClassElement();
  final apiClientField = MockFieldElement();
  final fetchDataMethod = MockMethodElement();
  final pushDataMethod = MockMethodElement();

  // Set the source Uri
  when(source.uri).thenReturn(Uri.parse(mockLibraryUri));

  // Annotate ApiClient with @Riverfit
  final riverfitAnnotation = _createAnnotationFor(
    Riverfit(),
    Uri.parse('asset:riverfit_annotation/lib/riverfit_annotation.dart#Riverfit'),
    'ApiClient',
  );
  when(apiClientClass.source).thenReturn(source);
  when(apiClientClass.metadata).thenReturn([riverfitAnnotation]);
  when(apiClientClass.displayName).thenReturn('ApiClient');
  when(apiClientClass.fields).thenReturn([apiClientField]);

  // Annotate Api with @RestApi
  final restApiAnnotation = _createAnnotationFor(
    RestApi(),
    Uri.parse('asset:retrofit/lib/http.dart#RestApi'),
    'Api',
  );
  when(apiClass.metadata).thenReturn([restApiAnnotation]);
  when(apiClass.displayName).thenReturn('Api');
  when(apiClass.methods).thenReturn([fetchDataMethod, pushDataMethod]);

  // Set up fetchData method in Api
  final fetchMethodDartType = MockDartType();
  when(fetchMethodDartType.getDisplayString()).thenReturn('Future<String>');
  when(fetchDataMethod.returnType).thenReturn(fetchMethodDartType);
  when(fetchDataMethod.name).thenReturn('fetchData');
  when(fetchDataMethod.isAbstract).thenReturn(true);
  when(fetchDataMethod.parameters).thenReturn([]);

  // Annotate fetchData with @Method
  final fetchMethodAnnotation = _createAnnotationFor(
    Method('GET', '/fetchData'),
    Uri.parse('asset:retrofit/lib/http.dart#Method'),
    'fetchData',
  );
  when(fetchDataMethod.metadata).thenReturn([fetchMethodAnnotation]);

  // Set up pushData method in Api
  final pushMethodDartType = MockDartType();
  when(pushMethodDartType.getDisplayString()).thenReturn('Future<void>');
  when(pushDataMethod.returnType).thenReturn(pushMethodDartType);
  when(pushDataMethod.name).thenReturn('pushData');
  when(pushDataMethod.isAbstract).thenReturn(true);
  final pushMethodParameterDartType = MockDartType();
  when(pushMethodParameterDartType.getDisplayString()).thenReturn('int');
  final pushMethodParameter = MockParameterElement();
  when(pushMethodParameter.name).thenReturn('id');
  when(pushMethodParameter.type).thenReturn(pushMethodParameterDartType);
  when(pushDataMethod.parameters).thenReturn([pushMethodParameter]);

  // Annotate pushData with @Method
  final pushMethodAnnotation = _createAnnotationFor(
    Method('PUT', '/pushData/{id}'),
    Uri.parse('asset:retrofit/lib/http.dart#Method'),
    'pushData',
  );
  when(pushDataMethod.metadata).thenReturn([pushMethodAnnotation]);

  // Set up api field in ApiClient
  final fieldDartType = MockDartType();
  when(fieldDartType.element).thenReturn(apiClass);
  when(apiClientField.type).thenReturn(fieldDartType);
  when(apiClientField.name).thenReturn('api');
  when(apiClientField.isStatic).thenReturn(false);

  return [AnnotatedElement(ConstantReader(null), apiClientClass)];
}

List<AnnotatedElement> createMockLibraryElementWithoutRestApiMember() {
  final source = MockSource();
  final apiClientClass = MockClassElement();
  final someOtherClass = MockClassElement();
  final someOtherField = MockFieldElement();

  // Set the source Uri
  when(source.uri).thenReturn(Uri.parse(mockLibraryUri));

  // Annotate ApiClient with @Riverfit
  final riverfitAnnotation = _createAnnotationFor(
    Riverfit(),
    Uri.parse('asset:riverfit_annotation/lib/riverfit_annotation.dart#Riverfit'),
    'ApiClient',
  );
  when(apiClientClass.metadata).thenReturn([riverfitAnnotation]);
  when(apiClientClass.source).thenReturn(source);
  when(apiClientClass.displayName).thenReturn('ApiClient');
  when(apiClientClass.fields).thenReturn([someOtherField]);

  // Annotate Api with @RestApi
  when(someOtherClass.metadata).thenReturn([]);
  when(someOtherClass.displayName).thenReturn('SomeOther');
  when(someOtherClass.methods).thenReturn([]);

  // Set up api field in ApiClient
  final fieldDartType = MockDartType();
  when(fieldDartType.element).thenReturn(someOtherClass);
  when(someOtherField.type).thenReturn(fieldDartType);
  when(someOtherField.name).thenReturn('someOther');
  when(someOtherField.isStatic).thenReturn(false);

  return [AnnotatedElement(ConstantReader(null), apiClientClass)];
}

ElementAnnotation _createAnnotationFor(Object annotation, Uri uri, String name) {
  final mockAnnotation = MockElementAnnotation();
  final mockInterfaceType = MockInterfaceType();
  final mockInterfaceElement = MockInterfaceElement();
  final mockInterfaceSource = MockSource();
  final mockClassElement = MockClassElement();
  final mockClassSource = MockSource();
  final mockDartObject = MockDartObject();
  final mockDartType = MockDartType();

  when(mockInterfaceSource.uri).thenReturn(uri);
  when(mockInterfaceElement.kind).thenReturn(ElementKind.CLASS);
  when(mockInterfaceElement.name).thenReturn(annotation.runtimeType.toString());
  when(mockInterfaceElement.librarySource).thenReturn(mockInterfaceSource);
  when(mockInterfaceType.element).thenReturn(mockInterfaceElement);

  when(mockClassSource.uri).thenReturn(Uri.parse('package:riverfit/test_file.dart'));
  when(mockClassElement.kind).thenReturn(ElementKind.CLASS);
  when(mockClassElement.name).thenReturn(name);
  when(mockClassElement.librarySource).thenReturn(mockClassSource);
  when(mockClassElement.allSupertypes).thenReturn([mockInterfaceType]);

  when(mockAnnotation.element).thenReturn(mockClassElement);

  when(mockDartType.element).thenReturn(mockClassElement);
  when(mockDartObject.type).thenReturn(mockDartType);
  when(mockAnnotation.computeConstantValue()).thenReturn(mockDartObject);

  return mockAnnotation;
}
