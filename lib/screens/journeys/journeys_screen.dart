import 'package:flutter/material.dart';
import './journey_selection_screen.dart';

/// Journeys Screen Wrapper
/// Delegates to JourneySelectionScreen
class JourneysScreen extends StatelessWidget {
  const JourneysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const JourneySelectionScreen();
  }
}
