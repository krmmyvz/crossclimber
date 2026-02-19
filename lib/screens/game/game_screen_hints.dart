import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mixin providing hint system functionality for GameScreen
/// [DEPRECATED] Most build methods moved to standalone widgets in widgets/
mixin GameScreenHints<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Logic-only methods can stay here if needed, 
  // but build methods have been moved to HintQuickAccessBar and ClueDisplay
}
