import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../shared/blocs/auth_bloc.dart';
import '../core/services/theme_notifier.dart';
import 'router.dart';
import 'theme.dart';

class MusicTeamApp extends StatefulWidget {
  const MusicTeamApp({super.key});

  @override
  State<MusicTeamApp> createState() => _MusicTeamAppState();
}

class _MusicTeamAppState extends State<MusicTeamApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _router = buildRouter(_authBloc);
    ThemeNotifier.instance.init();
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: ListenableBuilder(
        listenable: ThemeNotifier.instance,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'GRM Music Team',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeNotifier.instance.mode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
