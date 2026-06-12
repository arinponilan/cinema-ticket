import 'package:flutter/foundation.dart';

String get apiBaseUrl {
  const configuredUrl = String.fromEnvironment('API_BASE_URL');
  if (configuredUrl.isNotEmpty) {
    return configuredUrl;
  }

  return defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:8081'
      : 'http://localhost:8081';
}
