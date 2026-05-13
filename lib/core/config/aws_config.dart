// File: lib/core/config/aws_config.dart
// Purpose: AWS Rekognition endpoint + credentials. Empty stubs — fill before integration.
// Used by: self_attendance/face screen, labour/face_in screen, labour/face_out screen.

class AwsConfig {
  // Fill before integration. Do NOT commit real keys — load from env/secrets manager.
  static const String rekognitionEndpoint = '';
  static const String accessKeyId = '';
  static const String secretAccessKey = '';
  static const String region = '';

  static bool get isConfigured =>
      rekognitionEndpoint.isNotEmpty &&
      accessKeyId.isNotEmpty &&
      secretAccessKey.isNotEmpty &&
      region.isNotEmpty;
}
