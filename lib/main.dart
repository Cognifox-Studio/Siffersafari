import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siffersafari/app/bootstrap/presentation/startup_flow_gate.dart';
import 'package:siffersafari/app/bootstrap/presentation/startup_splash_gate.dart';
import 'package:siffersafari/domain/enums/app_theme.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/providers/app_theme_provider.dart';
import 'core/theme/app_theme_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isTestBinding = _isRunningUnderTestBinding();

  // Global felhantering för Flutter-ramverket
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    final isKnownTestTeardownAnimationWarning = message.contains(
      'An animation is still running even after the widget tree was disposed.',
    );

    if (isKnownTestTeardownAnimationWarning && isTestBinding) {
      return;
    }

    FlutterError.presentError(details);
    debugPrint('Flutter error: $message');
    debugPrintStack(stackTrace: details.stack);
  };

  // Global felhantering för asynkrona fel utanför ramverket
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Platform error: $error');
    debugPrintStack(stackTrace: stack);
    return true; // Förhindra krasch
  };

  // Global felhantering för isolerade processer
  Isolate.current.addErrorListener(
    RawReceivePort((dynamic pair) {
      final errorAndStacktrace = pair as List<dynamic>;
      debugPrint('Isolate error: ${errorAndStacktrace.first}');
      if (errorAndStacktrace.length > 1) {
        debugPrint('Isolate stacktrace: ${errorAndStacktrace[1]}');
      }
    }).sendPort,
  );

  // Registrera beroenden direkt så att moduler (t.ex. tema) kan
  // hitta sina GetIt-instanser direkt vid första ritningen (Frame).
  // Hive initieras efteråt i [_initializeAsync].
  await _measureAsync(
    'initializeDependencies(initializeHive: false)',
    () => initializeDependencies(initializeHive: false),
  );

  // Kör all tung uppstart före Flutter anropar "runApp".
  // Androids startskärm ligger kvar orörd tills den första widget-vyen renderas,
  // vilket gör att vi kan visa resultatet utan mellansteg.
  final initError = await _initializeAsync();

  runApp(
    ProviderScope(
      child: SiffersafariApp(
        initError: initError,
      ),
    ),
  );
}

bool _isRunningUnderTestBinding() {
  final bindingType = WidgetsBinding.instance.runtimeType.toString();
  return bindingType.contains('TestWidgets') ||
      bindingType.contains('AutomatedTestWidgets') ||
      bindingType.contains('LiveTestWidgets') ||
      bindingType.contains('IntegrationTestWidgets');
}

Future<String?> _initializeAsync() async {
  try {
    await _measureAsync('Hive.initFlutter', () => Hive.initFlutter());

    await _measureAsync(
      'initializeDependencies(openQuizHistoryBox: false)',
      () => initializeDependencies(openQuizHistoryBox: false),
    );

    // Boxen quiz_history öppnas asynkront efter primära core-beroenden
    unawaited(
      _measureAsync('Hive.openBox(quiz_history)', () async {
        await Hive.openBox('quiz_history');
      }).catchError((e) {
        debugPrint('quiz_history box open failed: $e');
      }),
    );

    return null; // Uppstart slutförd korrret
  } catch (e, st) {
    debugPrint('Initialization failed: $e');
    debugPrintStack(stackTrace: st);
    return e.toString();
  }
}

Future<T> _measureAsync<T>(String name, Future<T> Function() fn) async {
  if (!kProfileMode) return fn();

  final task = developer.TimelineTask(filterKey: 'perf');
  final sw = Stopwatch()..start();
  task.start(name);
  try {
    return await fn();
  } finally {
    sw.stop();
    task.finish();
    debugPrint('[PERF] $name: ${sw.elapsedMilliseconds}ms');
  }
}

class SiffersafariApp extends ConsumerWidget {
  const SiffersafariApp({super.key, required this.initError});

  final String? initError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultTheme = AppThemeConfig.forTheme(AppTheme.jungle).themeData();
    final theme =
        (initError == null) ? ref.watch(appThemeDataProvider) : defaultTheme;

    final Widget home;
    if (initError != null) {
      home = _BootstrapErrorScreen(error: initError!);
    } else {
      home = const StartupSplashGate(child: StartupFlowGate());
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Siffersafari',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: home,
        );
      },
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    // Kräver ingen import eftersom färgkod kan läggas direkt.
    // Låt oss garantera att styling fungerar även om tema failar.
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F1722), // Hardkodad fallback spaceBackground
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Text(
            'Kunde inte starta appen:\n$error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
