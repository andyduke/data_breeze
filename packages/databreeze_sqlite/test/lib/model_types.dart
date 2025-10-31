import 'package:databreeze/databreeze.dart';

class XFile {
  final String path;

  XFile(this.path);

  Future<void> delete() async {
    print('### Delete file: $path');
  }

  @override
  String toString() => 'XFile($path)';

  @override
  bool operator ==(covariant XFile other) => path == other.path;

  @override
  int get hashCode => path.hashCode;
}

class XFileConverter extends BreezeTypeConverter<XFile, String> {
  @override
  XFile toDart(String value) => XFile(value);

  @override
  String toStorage(XFile value) => value.path;
}

final modelTypeConverters = {
  XFileConverter(),
};
