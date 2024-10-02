import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class ConfigUtil {
  static Map<String, dynamic>? _config;

  // Load the configuration file from assets
  static Future<void> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.yaml');
    final yamlData = loadYaml(configString);
    _config = json.decode(json.encode(yamlData)); // Convert YAML to a Map
  }

  // Get configuration values by key
  static String getConfigValue(String keyPath) {
    if (_config == null) {
      throw Exception("Configuration has not been loaded.");
    }

    final keys = keyPath.split('.');
    dynamic value = _config;
    for (final key in keys) {
      value = value[key];
    }

    if (value == null) {
      throw Exception("Key $keyPath not found in configuration.");
    }
    return value;
  }

  // Get the API host
  static String getHost() {
    return getConfigValue('api.host');
  }

  // Get a specific resource endpoint by key
  static String getResource(String key) {
    return getConfigValue('api.endpoints.$key');
  }

  // Get the content type for requests
  static String getContentType() {
    return getConfigValue('api.headers.Content-Type');
  }
}
