bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

String camelToSnake(String input) {
  return input.replaceAllMapped(
    RegExp(r'(?<=[a-z])[A-Z]'),
    (m) => '_${m.group(0)!.toLowerCase()}',
  );
}

String snakeToCamel(String input) {
  if (!input.contains(RegExp(r'(_|-)+'))) {
    return input;
  }
  return input.toLowerCase().replaceAllMapped(
    RegExp(r'(_|-)+([a-z])'),
    (Match m) => m[2]!.toUpperCase(),
  );
}
