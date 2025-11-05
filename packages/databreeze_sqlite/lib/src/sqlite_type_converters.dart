import 'package:databreeze/databreeze.dart';

class BreezeSqliteBoolIntConverter extends BreezeBaseTypeConverter<bool, int> {
  @override
  bool toDart(int value) => (value == 1);

  @override
  int toStorage(bool value) => (value ? 1 : 0);
}

class BreezeSqliteDurationIntConverter extends BreezeBaseTypeConverter<Duration, int> {
  @override
  Duration toDart(int value) => Duration(milliseconds: value);

  @override
  int toStorage(Duration value) => value.inMilliseconds;
}

class BreezeSqliteDateTimeIntConverter extends BreezeBaseTypeConverter<DateTime, int> {
  @override
  DateTime toDart(int value) => DateTime.fromMillisecondsSinceEpoch(value);

  @override
  int toStorage(DateTime value) => value.millisecondsSinceEpoch;
}

class BreezeSqliteDateTimeStringConverter extends BreezeBaseTypeConverter<DateTime, String> {
  @override
  DateTime toDart(String value) => DateTime.parse(value);

  @override
  String toStorage(DateTime value) => value.toSqliteDateTime();
}

extension BreezeSqliteDateTime on DateTime {
  String toSqliteDateTime() {
    // final datetime = toUtc();
    final datetime = toLocal();

    String y = (datetime.year >= -9999 && datetime.year <= 9999)
        ? _fourDigits(datetime.year)
        : _sixDigits(datetime.year);
    String m = _twoDigits(datetime.month);
    String d = _twoDigits(datetime.day);
    String h = _twoDigits(datetime.hour);
    String min = _twoDigits(datetime.minute);
    String sec = _twoDigits(datetime.second);
    String ms = _threeDigits(datetime.millisecond);

    return "$y-$m-${d}T$h:$min:$sec.$ms";
  }

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _sixDigits(int n) {
    assert(n < -9999 || n > 9999);
    int absN = n.abs();
    String sign = n < 0 ? "-" : "+";
    if (absN >= 100000) return "$sign$absN";
    return "${sign}0$absN";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "$n";
    if (n >= 10) return "0$n";
    return "00$n";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}
