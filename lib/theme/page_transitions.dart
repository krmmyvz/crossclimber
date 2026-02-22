import 'package:flutter/material.dart';
import 'package:crossclimber/theme/animations.dart';

/// Custom page route with slide + fade transition.
///
/// Provides consistent, smooth transitions across the app.
/// Uses standardized animation tokens from [AnimDurations] and [AppCurves].
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final slideTween = Tween<Offset>(
             begin: const Offset(1.0, 0.0),
             end: Offset.zero,
           ).chain(CurveTween(curve: AppCurves.fastOutSlowIn));

           final fadeTween = Tween<double>(
             begin: 0.0,
             end: 1.0,
           ).chain(CurveTween(curve: AppCurves.easeOut));

           // Outgoing page slides slightly left and fades
           final secondarySlide = Tween<Offset>(
             begin: Offset.zero,
             end: const Offset(-0.3, 0.0),
           ).chain(CurveTween(curve: AppCurves.fastOutSlowIn));

           final secondaryFade = Tween<double>(
             begin: 1.0,
             end: 0.85,
           ).chain(CurveTween(curve: AppCurves.easeOut));

           return SlideTransition(
             position: secondarySlide.animate(secondaryAnimation),
             child: FadeTransition(
               opacity: secondaryFade.animate(secondaryAnimation),
               child: SlideTransition(
                 position: slideTween.animate(animation),
                 child: FadeTransition(
                   opacity: fadeTween.animate(animation),
                   child: child,
                 ),
               ),
             ),
           );
         },
         transitionDuration: AnimDurations.normal,
         reverseTransitionDuration: AnimDurations.normal,
       );
}

/// Fade-through transition — ideal for sibling destinations
/// (e.g., Settings, Statistics, Achievements from the same home screen).
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  FadeThroughPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: AppCurves.easeOut));

          final scaleTween = Tween<double>(
            begin: 0.92,
            end: 1.0,
          ).chain(CurveTween(curve: AppCurves.fastOutSlowIn));

          return FadeTransition(
            opacity: fadeTween.animate(animation),
            child: ScaleTransition(
              scale: scaleTween.animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: AnimDurations.normal,
        reverseTransitionDuration: AnimDurations.fast,
      );
}

/// Bottom-to-top slide transition — for modals and overlays
/// (e.g., ShopScreen opened from within a game).
class BottomSlidePageRoute<T> extends PageRouteBuilder<T> {
  BottomSlidePageRoute({required WidgetBuilder builder, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideTween = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: AppCurves.fastOutSlowIn));

          final fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: AppCurves.easeOut));

          return SlideTransition(
            position: slideTween.animate(animation),
            child: FadeTransition(
              opacity: fadeTween.animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: AnimDurations.medium,
        reverseTransitionDuration: AnimDurations.normal,
      );
}

/// Spring bottom-to-top slide with overshoot — for bottom sheets and popups.
///
/// Uses [AppCurves.spring] (easeOutBack) for a playful bounce overshoot
/// as the sheet enters from the bottom. Ideal for settings panels,
/// confirmation dialogs, and any modal surface.
class SpringBottomSheetRoute<T> extends PageRouteBuilder<T> {
  SpringBottomSheetRoute({
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog = true,
  }) : super(
         opaque: false,
         barrierColor: Colors.black54,
         barrierDismissible: true,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final slideTween = Tween<Offset>(
             begin: const Offset(0.0, 1.0),
             end: Offset.zero,
           ).chain(CurveTween(curve: AppCurves.spring));

           final fadeTween = Tween<double>(
             begin: 0.0,
             end: 1.0,
           ).chain(CurveTween(curve: AppCurves.easeOut));

           final scaleTween = Tween<double>(
             begin: 0.95,
             end: 1.0,
           ).chain(CurveTween(curve: AppCurves.spring));

           return SlideTransition(
             position: slideTween.animate(animation),
             child: FadeTransition(
               opacity: fadeTween.animate(animation),
               child: ScaleTransition(
                 scale: scaleTween.animate(animation),
                 child: child,
               ),
             ),
           );
         },
         transitionDuration: AnimDurations.medium,
         reverseTransitionDuration: AnimDurations.normal,
       );
}
