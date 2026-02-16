# Combo System Integration Guide

## Overview
The Combo System tracks consecutive correct guesses and rewards players with bonus points through multipliers.

## Features Implemented

### 1. GameState Extensions
- `currentCombo`: Current consecutive correct guesses
- `maxCombo`: Highest combo achieved in the level
- `comboBonus`: Total bonus points earned from combos
- `comboMultiplier`: Computed multiplier based on combo count

### 2. Combo Multipliers
- **2-3 combos**: 1.0x multiplier (10 points each)
- **3-4 combos**: 1.5x multiplier (15 points each)
- **5-7 combos**: 2.0x multiplier (20 points each)
- **8+ combos**: 2.5x multiplier (25 points each)

### 3. Combo Logic
- Increments on every correct guess (middle words and final words)
- Resets to 0 on any wrong guess
- Adds bonus points to final score
- Tracks max combo for statistics

### 4. Combo Widgets

#### ComboIndicator
Large combo display with icon and multiplier info.
```dart
ComboIndicator(
  comboCount: gameState.currentCombo,
  multiplier: gameState.comboMultiplier,
)
```

#### ComboCounter (Compact)
Small combo counter for top bar.
```dart
ComboCounter(
  comboCount: gameState.currentCombo,
  multiplier: gameState.comboMultiplier,
)
```

#### ComboPopup
Animated popup showing combo increase and points earned.
```dart
ComboPopup(
  comboCount: gameState.currentCombo,
  points: (10 * gameState.comboMultiplier).round(),
  multiplier: gameState.comboMultiplier,
)
```

#### ComboBreakIndicator
Animation shown when combo breaks.
```dart
ComboBreakIndicator(
  lostCombo: previousCombo, // Pass the combo count before it broke
)
```

## Integration Example for GameScreen

### 1. Add Combo Counter to Top Bar
Add to the AppBar or top info row:

```dart
// In the top row with timer, hints, etc.
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Timer
    if (settings.showTimer)
      Text(_formatTime(gameState.timeElapsed)),
    
    // Combo Counter
    ComboCounter(
      comboCount: gameState.currentCombo,
      multiplier: gameState.comboMultiplier,
    ),
    
    // Other info
    Text('Hints: ${gameState.hintsRemaining}'),
  ],
)
```

### 2. Add Combo Indicator to Game Area
Add between phases or near the word ladder:

```dart
// In the main game area
Column(
  children: [
    // Game phase content
    _buildGameContent(),
    
    // Combo Indicator
    if (gameState.currentCombo >= 2)
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ComboIndicator(
          comboCount: gameState.currentCombo,
          multiplier: gameState.comboMultiplier,
        ),
      ),
  ],
)
```

### 3. Show Combo Popup on Correct Guess
Use an OverlayEntry or Stack to show popup:

```dart
class _GameScreenState extends ConsumerState<GameScreen> {
  OverlayEntry? _comboPopupEntry;
  
  void _showComboPopup() {
    _comboPopupEntry?.remove();
    
    _comboPopupEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 0,
        right: 0,
        child: Center(
          child: ComboPopup(
            comboCount: ref.read(gameProvider).currentCombo,
            points: (10 * ref.read(gameProvider).comboMultiplier).round(),
            multiplier: ref.read(gameProvider).comboMultiplier,
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_comboPopupEntry!);
    
    // Auto remove after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      _comboPopupEntry?.remove();
      _comboPopupEntry = null;
    });
  }
  
  @override
  void dispose() {
    _comboPopupEntry?.remove();
    super.dispose();
  }
}
```

### 4. Listen for Combo Changes
Add a listener to show popups automatically:

```dart
@override
void initState() {
  super.initState();
  
  // Listen for combo changes
  ref.listenManual(
    gameProvider.select((state) => state.currentCombo),
    (previous, next) {
      if (next > (previous ?? 0) && next >= 2) {
        _showComboPopup();
      } else if (next == 0 && (previous ?? 0) >= 2) {
        _showComboBreakAnimation(previous ?? 0);
      }
    },
  );
}
```

### 5. Show Combo Break Animation
Similar to combo popup:

```dart
void _showComboBreakAnimation(int lostCombo) {
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.3,
      left: 0,
      right: 0,
      child: Center(
        child: ComboBreakIndicator(lostCombo: lostCombo),
      ),
    ),
  );
  
  Overlay.of(context).insert(entry);
  
  Future.delayed(const Duration(milliseconds: 1700), () {
    entry.remove();
  });
}
```

## Level Completion Integration

Show combo stats in the level completion screen:

```dart
// In LevelCompletionScreen
Column(
  children: [
    // Score
    Text('Score: ${gameState.score}'),
    
    // Combo stats
    if (gameState.maxCombo >= 2) ...[
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.whatshot, color: Colors.orange),
          const SizedBox(width: 8),
          Text('Max Combo: ${gameState.maxCombo}x'),
        ],
      ),
      Text(
        'Combo Bonus: +${gameState.comboBonus} points',
        style: TextStyle(color: Colors.orange),
      ),
    ],
  ],
)
```

## Testing Checklist

- [ ] Combo increments on correct middle word guess
- [ ] Combo increments on correct final word guess
- [ ] Combo resets to 0 on wrong guess
- [ ] Multiplier changes at correct thresholds (3, 5, 8)
- [ ] Bonus points are calculated correctly
- [ ] Final score includes combo bonus
- [ ] ComboCounter appears when combo >= 2
- [ ] ComboPopup shows on combo increase
- [ ] ComboBreakIndicator shows when combo breaks
- [ ] Max combo is tracked correctly
- [ ] Combo stats show in completion screen

## Visual Color Guide

- **Blue (2 combo)**: 1.0x multiplier - Beginner level
- **Orange (3-4 combo)**: 1.5x multiplier - Getting warmed up
- **Deep Orange (5-7 combo)**: 2.0x multiplier - On fire!
- **Purple (8+ combo)**: 2.5x multiplier - Legendary!

## Performance Notes

- Widgets only render when combo >= 2
- Animations are optimized with flutter_animate
- Overlay entries are properly disposed
- Shimmer effect loops efficiently
