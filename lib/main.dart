import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/services/sync_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/post/data/models/post_model.dart';
import 'features/post/presentation/bloc/post_bloc.dart';
import 'injection_container.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // NOTE: You need to run 'flutterfire configure' and add config files
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('⚠️  Firebase initialization failed: $e');
    print(
      '📝 Please run "flutterfire configure" and add Firebase config files',
    );
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(PostModelAdapter());

  // Initialize dependency injection
  await initializeDependencies();

  // Initialize and start sync service
  final syncService = initializeSyncService();

  runApp(MyApp(syncService: syncService));
}

class MyApp extends StatelessWidget {
  final SyncService syncService;

  const MyApp({super.key, required this.syncService});

  @override
  Widget build(BuildContext context) {
    // Create AuthBloc instance
    final authBloc = sl<AuthBloc>();

    // Check auth status on app start
    authBloc.add(AuthCheckRequested());

    // Create router with auth guard
    final appRouter = AppRouter(authBloc: authBloc);

    return MultiBlocProvider(
      providers: [
        // Provide AuthBloc globally
        BlocProvider<AuthBloc>.value(value: authBloc),

        // Provide PostBloc globally
        BlocProvider<PostBloc>(create: (_) => sl<PostBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Clean Architecture App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter.router,
      ),
    );
  }
}
