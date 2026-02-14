/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:build/build.dart';
import 'package:databreeze_generator/src/model_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Entry point for build_runner
Builder breezeModelBuilder(BuilderOptions config) {
  return SharedPartBuilder([BreezeModelGenerator()], 'model');
}
