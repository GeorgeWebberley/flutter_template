import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads all environment variables for easier access. Can then be used in the app
/// e.g. [Environment.name].
class Environment {
  static String get name => dotenv.env['ENVIRONMENT'] ?? '';

  static ExampleEnvironment get example => ExampleEnvironment();
}

class ExampleEnvironment {
  String get exampleField => dotenv.env['EXAMPLE_FIELD'] ?? '';
}
