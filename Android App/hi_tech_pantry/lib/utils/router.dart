import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/login_page.dart';
import '../screens/splash_page.dart';
import '../screens/profile_page.dart';
import '../screens/register_page.dart';
import '../screens/products_page.dart';
import '../screens/forgot_password_page.dart';

class Router {
  static final GoRouter goRouter = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: SplashPage.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/products',
        name: ProductsPage.productsName,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ProductsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        routes: [
          GoRoute(
            path: 'profile',
            name: ProfilePage.profileName,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const ProfilePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ), 
        ]
      ),
      GoRoute(
        path: '/login',
        name: LoginPage.loginName,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const LoginPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
        ),
        routes: [
          GoRoute(
            path: 'forgot-password',
            name: ForgotPasswordPage.forgotPasswordName,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const ForgotPasswordPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
          GoRoute(
            path: 'register',
            name: RegisterPage.registerName,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const RegisterPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
        ]
      )
    ],
  );
}