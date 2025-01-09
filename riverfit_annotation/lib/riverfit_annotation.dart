/// Riverfit API Client Generator
/// Use `build_runner` to generate your riverfit-compatible code.
library riverfit_annotation;

// Re-export riverpod and riverpod_annotation as a convenience
export 'package:riverpod_annotation/riverpod_annotation.dart'
    show
        ProviderFor,
        ProviderOrFamily,
        Provider,
        Family,
        Notifier,
        NotifierProvider,
        AsyncNotifier,
        AsyncNotifierProvider,
        StreamNotifier,
        StreamNotifierProvider,
        AutoDisposeNotifier,
        AutoDisposeNotifierProvider,
        AutoDisposeAsyncNotifier,
        AutoDisposeAsyncNotifierProvider,
        AutoDisposeStreamNotifier,
        AutoDisposeStreamNotifierProvider;

export './src/annotation.dart';
