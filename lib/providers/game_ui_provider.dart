import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameUIState {
  final int? selectedRowIndex;
  final bool isTopSelected;
  final bool isBottomSelected;
  final Map<String, String> temporaryInputs;

  GameUIState({
    this.selectedRowIndex,
    this.isTopSelected = false,
    this.isBottomSelected = false,
    this.temporaryInputs = const {},
  });

  GameUIState copyWith({
    int? selectedRowIndex,
    bool? isTopSelected,
    bool? isBottomSelected,
    Map<String, String>? temporaryInputs,
    bool clearSelection = false,
  }) {
    return GameUIState(
      selectedRowIndex: clearSelection ? null : (selectedRowIndex ?? this.selectedRowIndex),
      isTopSelected: clearSelection ? false : (isTopSelected ?? this.isTopSelected),
      isBottomSelected: clearSelection ? false : (isBottomSelected ?? this.isBottomSelected),
      temporaryInputs: temporaryInputs ?? this.temporaryInputs,
    );
  }
}

class GameUINotifier extends Notifier<GameUIState> {
  @override
  GameUIState build() {
    return GameUIState();
  }

  void selectMiddleWord(int index, String currentInput) {
    _saveInput(currentInput);
    state = state.copyWith(
      selectedRowIndex: index,
      isTopSelected: false,
      isBottomSelected: false,
    );
  }

  void selectEndWord(bool isTop, String currentInput) {
    _saveInput(currentInput);
    state = state.copyWith(
      selectedRowIndex: null,
      isTopSelected: isTop,
      isBottomSelected: !isTop,
    );
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }

  void updateTemporaryInput(String key, String value) {
    final newInputs = Map<String, String>.from(state.temporaryInputs);
    newInputs[key] = value;
    state = state.copyWith(temporaryInputs: newInputs);
  }

  void _saveInput(String value) {
    final newInputs = Map<String, String>.from(state.temporaryInputs);
    if (state.selectedRowIndex != null) {
      newInputs['middle_${state.selectedRowIndex}'] = value;
    } else if (state.isTopSelected) {
      newInputs['top'] = value;
    } else if (state.isBottomSelected) {
      newInputs['bottom'] = value;
    }
    state = state.copyWith(temporaryInputs: newInputs);
  }

  String getSelectedInput() {
    if (state.selectedRowIndex != null) {
      return state.temporaryInputs['middle_${state.selectedRowIndex}'] ?? '';
    } else if (state.isTopSelected) {
      return state.temporaryInputs['top'] ?? '';
    } else if (state.isBottomSelected) {
      return state.temporaryInputs['bottom'] ?? '';
    }
    return '';
  }
}

final gameUIProvider = NotifierProvider<GameUINotifier, GameUIState>(() {
  return GameUINotifier();
});
