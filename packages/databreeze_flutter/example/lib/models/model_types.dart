import 'dart:ui';
import 'package:databreeze/databreeze.dart';

class XFile {
  final String path;

  XFile(this.path);

  Future<void> delete() async {
    // ignore: avoid_print
    print('### Delete file: $path');
  }
}

class XFileConverter extends BreezeBaseTypeConverter<XFile, String> {
  @override
  XFile toDart(String value) => XFile(value);

  @override
  String toStorage(XFile value) => value.path;
}

final modelTypeConverters = <BreezeBaseTypeConverter>{
  XFileConverter(),
  BreezeTypeConverter<Color, int>(
    from: (value) => Color(value),
    to: (value) => value.toARGB32(),
  ),
};
