import 'package:flutter/material.dart';

/// Root navigator used by widgets outside the route tree
/// (e.g. the global mini player in [MaterialApp.builder]).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
