// Wraps the disease library with repository-backed loading state.

import 'package:flutter/material.dart';
import 'library_screen.dart';

class LibraryWrapper extends StatelessWidget {
  const LibraryWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep library-detail navigation independent of the main tab navigator.
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LibraryScreen());
      },
    );
  }
}
