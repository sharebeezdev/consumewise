import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

String generateImageHash(Uint8List imageBytes) {
  var bytes =
      utf8.encode(imageBytes.toString()); // Convert image bytes to string
  var digest = sha256.convert(bytes); // Generate SHA-256 hash
  return digest.toString(); // Return the unique ID
}
