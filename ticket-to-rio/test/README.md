# Ticket to Rio - Test Suite

This directory contains comprehensive unit tests for the Ticket to Rio game project. The tests are written using GdUnit4, a testing framework for Godot.

## Test Files Overview

### Core Game Logic Tests
- **`test_deck_extended.gd`** - Comprehensive deck functionality tests
  - Card drawing, shuffling, distribution
  - Edge cases (empty deck, invalid operations)
  - Signal emission and visual updates
  - Train card counts and validation

- **`test_player_hand.gd`** - Player hand management tests
  - Card addition and removal
  - UI updates and validation
  - Multiple card type management
  - Error handling for invalid operations

- **`test_turn_manager.gd`** - Game state management tests
  - Turn logic and state transitions
  - Player and IA management
  - Objective tracking
  - Game over conditions

### UI and Interaction Tests
- **`test_card_manager.gd`** - Card interaction tests
  - Drag and drop functionality
  - Card highlighting and hover effects
  - Collision detection
  - Input event handling

- **`test_route.gd`** - Route system tests
  - Route setup and configuration
  - Wagon spawning and positioning
  - Visual updates and color changes
  - Input event handling

### Game State Management Tests
- **`test_global.gd`** - Global state tests
  - Participant management (players and IAs)
  - Color assignment and validation
  - Display name management
  - Edge cases and error handling

### Legacy Tests
- **`test_draw.gd`** - Original deck drawing tests
- **`teste_deck.gd`** - Original deck integration tests

### Documentation
- **`test_runner.gd`** - Test suite overview and documentation
- **`README.md`** - This file

## Running Tests

### Using GdUnit4 in Godot Editor
1. Open the project in Godot
2. Navigate to the test directory
3. Right-click on any test file and select "Run Tests"
4. View results in the GdUnit4 panel

### Using Command Line
```bash
# Run all tests
godot --headless --script addons/gdUnit4/bin/GdUnitCmdTool.gd

# Run specific test file
godot --headless --script addons/gdUnit4/bin/GdUnitCmdTool.gd --test-suite test_player_hand.gd

# Run tests with verbose output
godot --headless --script addons/gdUnit4/bin/GdUnitCmdTool.gd --verbose
```

## Test Coverage

### High Coverage Areas
- ✅ Deck management (drawing, shuffling, distribution)
- ✅ Player hand management (addition, removal, UI updates)
- ✅ Card interaction (drag/drop, highlighting)
- ✅ Game state management (turns, players, objectives)
- ✅ Route system (setup, wagons, visuals)
- ✅ Global state (participants, colors)

### Medium Coverage Areas
- ⚠️ Map system (basic route functionality)
- ⚠️ AI logic (participant management only)
- ⚠️ UI components (card manager and route visuals)

### Low/No Coverage Areas
- ❌ Map pathfinding algorithms
- ❌ Objective completion logic
- ❌ Score calculation details
- ❌ AI decision making
- ❌ Network multiplayer functionality
- ❌ Save/load game state
- ❌ Audio system integration
- ❌ Animation systems
- ❌ Performance optimization

## Test Quality Metrics

- **Total Test Files**: 8
- **Core Logic Coverage**: High
- **Edge Case Coverage**: Medium
- **Integration Test Coverage**: Low
- **Performance Test Coverage**: None
- **Documentation Quality**: High

## Recommended Next Steps

1. **Add Integration Tests**
   - Complete game flow from start to finish
   - Multi-player scenarios
   - AI vs human player interactions

2. **Add Performance Tests**
   - Large game states with many players
   - Memory usage under stress
   - Frame rate performance

3. **Add Missing Feature Tests**
   - Map pathfinding algorithms
   - Objective completion logic
   - Score calculation
   - AI decision making

4. **Add Edge Case Tests**
   - Network disconnections
   - Invalid game states
   - Resource cleanup
   - Error recovery

## Test Maintenance Guidelines

### Before Each Commit
- [ ] Run all tests to ensure they pass
- [ ] Add tests for any new functionality
- [ ] Update tests if existing functionality changes
- [ ] Ensure test names are descriptive and clear

### Test Writing Guidelines
- Use descriptive test names that explain what is being tested
- Write meaningful assertions with clear error messages
- Clean up test resources properly (use `auto_free()` when possible)
- Document complex test scenarios with comments
- Maintain test independence (tests should not depend on each other)

### Test Organization
- Group related tests in the same file
- Use consistent naming conventions
- Keep tests focused on a single responsibility
- Avoid testing implementation details

## Test Dependencies

| Test File | Dependencies |
|-----------|--------------|
| `test_global.gd` | None |
| `test_deck_extended.gd` | None |
| `test_player_hand.gd` | None |
| `test_card_manager.gd` | None |
| `test_route.gd` | None |
| `test_turn_manager.gd` | Global state management |
| `test_draw.gd` | Deck functionality |
| `teste_deck.gd` | Deck and player hand integration |

## Troubleshooting

### Common Issues

1. **Tests fail due to missing dependencies**
   - Ensure all required scenes and scripts are properly loaded
   - Check that preload paths are correct
   - Verify that GdUnit4 is properly installed

2. **Tests fail due to timing issues**
   - Use `await get_tree().process_frame` for frame-dependent operations
   - Add appropriate delays for animations or async operations
   - Consider using signals for synchronization

3. **Tests fail due to resource cleanup**
   - Use `auto_free()` for test objects
   - Manually clean up any resources created during tests
   - Ensure proper teardown in test functions

### Getting Help

- Check the GdUnit4 documentation for framework-specific issues
- Review existing tests for examples of proper test patterns
- Consult the main project documentation for game-specific logic
- Create issues in the project repository for test-related problems

## Contributing to Tests

When adding new tests:

1. Follow the existing naming conventions
2. Add tests to the appropriate category
3. Update this README with new test information
4. Ensure tests are independent and don't affect other tests
5. Add appropriate documentation for complex test scenarios

## Performance Considerations

- Tests should run quickly (under 1 second per test file)
- Avoid creating unnecessary objects or complex setups
- Use mocks when possible to avoid heavy dependencies
- Consider running performance tests separately from unit tests

## Continuous Integration

The test suite is designed to work with continuous integration systems:

- All tests can be run headlessly
- Tests provide clear pass/fail results
- Test output is machine-readable
- Tests are deterministic and repeatable

For CI setup, see the main project documentation for specific configuration details. 