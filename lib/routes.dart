import 'package:flutter/material.dart';
import './pages/pages.dart';

Map<String, Widget Function(BuildContext)> routes = {
  "/not-a-robot": (context) => const NotARobotView(),
};