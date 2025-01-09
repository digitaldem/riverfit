# Riverfit

![Build](https://github.com/digitaldem/riverfit/actions/workflows/main.yml/badge.svg)
[![Codecov](https://codecov.io/gh/digitaldem/riverfit/graph/badge.svg?token=BIMM16FVQ6)](https://codecov.io/gh/digitaldem/riverfit)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://opensource.org/licenses/MIT)


## Overview

**Riverfit** is a Dart code generation library designed to integrate the functionalities of `riverpod_generator` and `retrofit_generator`. 

### Why Riverfit?

This integration is for projects that rely on both **state management** via Riverpod and **API interactions** via Retrofit.

When using the `@Riverpod` annotation, you can choose to annotate either a function or a class. 
My preference is for class-based annotations, particularly for organization, readability, and maintainability.

- Better encapsulation: A class groups related logic and data together, making it easier to understand and manage the provider’s behavior.
- Improved readability: With a dedicated class, it’s immediately clear what the provider is meant to represent, and additional methods or properties can be added to extend its functionality.
- Extensibility: Classes allow you to add additional methods, properties, or computed values that are directly related to the provider’s state.

However, presently it is not possible to use the annotations for `riverpod_generator` and `retrofit_generator` on the same class, as `@Riverpod` expects a concrete class while `@RestApi` expects an abstract class.

Riverfit solves this by analyzing classes annotated with `@Riverfit` and:
- Delegates provider code generation to Riverpod Generator.
- Generates an provider extension class containing wrapper methods that forward calls to Retrofit members.
Which eliminates the need for manual proxy boilerplate.

---

## Subprojects

### 1. `riverfit_annotation`

Provides the `@Riverfit()`/`@riverfit` annotations used to mark classes for Riverfit processing.
Use it as a drop in replacement for the `@Riverpod()` or `@riverpod` annotations.

#### Usage

1. Create your standard Retrofit abstract class for your API contract.
```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api.g.dart';

@RestApi(baseUrl: 'https://example.com')
abstract class Api {
  factory Api(Dio dio, {String? baseUrl}) = _Api;

  @GET('/fetchData')
  Future<dynamic> fetchData();

  @PUT('/pushData/{id}')
  Future<dynamic> pushData(String id);
}
```
2. Create an API client to serve as the class being provided
```dart
import 'package:riverfit_annotation/riverfit_annotation.dart';

@Riverfit(keepAlive: true, dependencies: [OtherProvider])
class ApiClient extends _$ApiClient {
  // Declare a Retrofit member
  late final Api _api;

  @override
  Future<ApiClient> build() async {
    // Initialization logic goes here... 
    //  (Such as custom Dio configuration or adding interceptors 
    //   for cross-cutting concerns like logging or authentication)
    _api = Api(Dio());
    return this;
  }
}
```
or if using AutoDisposeProvider (keepAlive: false)
```dart
import 'package:riverfit_annotation/riverfit_annotation.dart';

@riverfit
class ApiClient extends _$ApiClient {
  // Declare a Retrofit member
  late final Api _api;

  @override
  Future<ApiClient> build() async {
    // Initialization logic goes here... 
    //  (Such as custom Dio configuration or adding interceptors 
    //   for cross-cutting concerns like logging or authentication)
    _api = Api(Dio());
    return this;
  }
}
```
3. Generate
```bash
dart run build_runner build --delete-conflicting-outputs
```


#### Implementation

The annotation proxies all parameters to Riverpod Annotation, which presently includes:

- **`keepAlive`**: Whether the state of the provider should persist even when it is no longer used. Defaults to `false`.
- **`dependencies`**: A list of Riverpod providers this class depends on.


---

### 2. `riverfit_generator`

The core generator that unions Riverpod and Retrofit code generation. It ensures annotations are processed correctly and generates both the provider and the extension methods.

#### Features
- Generates Riverpod provider code for annotated classes.
- Creates wrapper methods to call Retrofit members seamlessly.

#### Example

Run `dart run build_runner build`, and the generated code will include:
1. A Riverpod provider for `ApiClient`.
2. An extension class of wrapper methods to the RestApi `Api` member.

Generated Output:
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// Riverpod provider (a pass-through to riverpod_generator.generate())
String _$apiClientHash() => r'XXXX';

/// See also [ApiClient].
@ProviderFor(ApiClient)
final apiClientProvider = AsyncNotifierProvider<ApiClient, ApiClient>.internal(
  ApiClient.new,
  name: r'apiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ApiClient = AsyncNotifier<ApiClient>;

// Wrapper methods for Retrofit member
extension ApiClientExtension on ApiClient {
  Future<String> fetchData() {
    return _api.fetchData();
  }

  Future<void> pushData(int id) {
    return _api.pushData(id);
  }
}
```

## Installation

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  riverfit_annotation: ^1.0.0

dev_dependencies:
  riverfit_generator: ^1.0.0
  build_runner: ^2.4.0
```

---



## Limitations

- Riverfit does not handle name collisions if multiple Retrofit members in the same class define the same method name.
- Requires `build_runner` to generate code.

---

## Contributing

Contributions are welcome! Please open issues or submit pull requests to help improve Riverfit.

---

## License

Riverfit is licensed under the MIT License. See [LICENSE](LICENSE) for details.
