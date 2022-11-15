import 'dart:math';
import 'package:date_only_field/src/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Date implements Comparable<Date> {
  static String defaultDateFormat = ('dd-MM-yyyy');
  static const int monthsPerYear = 12;
  static const int maxDaysPerMonth = 31;
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  static final DateFormat _monthOnlyFormat = DateFormat('MMMM');
  static final DateFormat _dayFormat = DateFormat('dd');
  static final DateFormat _firstDayFormat = DateFormat('MMM dd');
  static final DateFormat _fullDayFormat = DateFormat('EEE MMM dd, yyyy');
  static final DateFormat _apiDayFormat = DateFormat('yyyy-MM-dd');

  /// Creates a date only.
  /// The [year] [month] [day].
  Date(int year, [int month = 1, int day = 1]) {
    _year = year;
    _month = month;
    _day = day;
  }

  Date.withFields({required int year, int month = 1, int day = 1}) : this(year, month, day);

  /// Creates a time of day based on the given time.
  ///
  /// The [year] is set to the time's hour and the [month] is set to the time's
  /// minute in the timezone of the given [DateTime].
  Date.fromDateTime(DateTime dateTime)
      : _year = dateTime.year,
        _month = dateTime.month,
        _day = dateTime.day;

  /// Creates a time of day based on the current time.
  ///
  /// The [year] is set to the current hour and the [month] is set to the
  /// current minute in the local time zone.
  factory Date.now() => Date.fromDateTime(DateTime.now());

  static Date parse(String formattedString, {String? dateFormat}) {
    dateFormat ??= Date.defaultDateFormat;
    return Date.fromDateTime(DateFormat(dateFormat).parse(formattedString));
  }

  /// Constructs a new [DateTime] instance based on [formattedString].
  ///
  /// Works like [parse] except that this function returns `null`
  /// where [parse] would throw a [FormatException].
  static Date? tryParse(String formattedString) {
    // TODO: Optimize to avoid throwing.
    try {
      return parse(formattedString);
    } on FormatException {
      return null;
    }
  }

  Date.fromMillisecondsSinceEpoch(int millisecondsSinceEpoch, {bool isUtc = false}) : this.fromDateTime(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));
  Date.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch, {bool isUtc = false}) : this.fromDateTime(DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch));

  /// Returns a new TimeOfDay with the hour and/or minute replaced.
  Date copyWith({int? year, int? month, int? day}) {
    assert(month == null || (month >= 0 && month < monthsPerYear));
    assert(day == null || (day >= 0 && day < maxDaysPerMonth));
    return Date(year ?? this.year, month ?? this.month, day ?? this.day);
  }

  DateTime toDateTime([TimeOfDay? time]) => DateTime(year, month, day, (time?.hour ?? 0), (time?.minute ?? 0));

  /// The selected year.
  int _year = 0;

  /// The selected month.
  int _month = 1;

  /// The selected m1onth.
  int _day = 1;

  int get year => _year;

  int get month => _month;

  int get day => _day;

  int get millisecondsSinceEpoch => toDateTime().millisecondsSinceEpoch;

  /// The number of microseconds since
  /// the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  ///
  /// This value is independent of the time zone.
  ///
  /// This value is at most
  /// 8,640,000,000,000,000,000us (100,000,000 days) from the Unix epoch.
  /// In other words: `microsecondsSinceEpoch.abs() <= 8640000000000000000`.
  ///
  /// Note that this value does not fit into 53 bits (the size of a IEEE double).
  /// A JavaScript number is not able to hold this value.
  int get microsecondsSinceEpoch => toDateTime().microsecondsSinceEpoch;

  /// The time zone name.
  ///
  String get timeZoneName => toDateTime().timeZoneName;

  /// The time zone offset, which
  /// is the difference between local time and UTC.
  ///
  /// The offset is positive for time zones east of UTC.
  ///
  /// Note, that JavaScript, Python and C return the difference between UTC and
  /// local time. Java, C# and Ruby return the difference between local time and
  /// UTC.
  ///
  /// For example, using local time in San Francisco, United States:
  /// ```dart
  /// final dateUS = DateTime.parse('2021-11-01 20:18:04Z').toLocal();
  /// print(dateUS); // 2021-11-01 13:18:04.000
  /// print(dateUS.timeZoneName); // PDT ( Pacific Daylight Time )
  /// print(dateUS.timeZoneOffset.inHours); // -7
  /// print(dateUS.timeZoneOffset.inMinutes); // -420
  /// ```
  ///
  /// For example, using local time in Canberra, Australia:
  /// ```dart
  /// final dateAus = DateTime.parse('2021-11-01 20:18:04Z').toLocal();
  /// print(dateAus); // 2021-11-02 07:18:04.000
  /// print(dateAus.timeZoneName); // AEDT ( Australian Eastern Daylight Time )
  /// print(dateAus.timeZoneOffset.inHours); // 11
  /// print(dateAus.timeZoneOffset.inMinutes); // 660
  /// ```
  Duration get timeZoneOffset => toDateTime().timeZoneOffset;

  /// The day of the week [monday]..[sunday].
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  ///
  /// ```dart
  /// final moonLanding = DateTime.parse('1969-07-20 20:18:04Z');
  /// print(moonLanding.weekday); // 7
  /// assert(moonLanding.weekday == DateTime.sunday);
  /// ```
  int get weekday => toDateTime().weekday;

  /// Whether or not two times are on the same week.
  bool isSameWeek(Date other) {
    var diff = (day - other.day);
    if (diff.abs() >= 7) {
      return false;
    }

    var min = isBefore(other) ? this : other;
    var max = isBefore(other) ? other : this;
    var result = max.weekday % 7 - min.weekday % 7 >= 0;
    return result;
  }

  bool isSameMonth(Date other) {
    return month == other.month;
  }

  bool isBefore(Date other) {
    return year < other.year || month < other.month || day < other.day;
  }

  bool isBeforeOrGreater(Date other) {
    return year <= other.year || month <= other.month || day <= other.day;
  }

  bool isAfter(Date other) {
    return year > other.year || month > other.month || day > other.day;
  }

  bool isAfterOrGreater(Date other) {
    return year >= other.year || month >= other.month || day >= other.day;
  }

  bool operator <(Date other) => isBefore(other);
  bool operator <=(Date other) => isBeforeOrGreater(other);
  bool operator >(Date other) => isAfter(other);
  bool operator >=(Date other) => isAfterOrGreater(other);

  @override
  bool operator ==(Object other) {
    return other is Date && isSameAs(other);
  }

  /// Whether or not two times are on the same day.
  bool isSameAs(Date other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool equals(Date other) => isSameAs(other);

  Date operator +(dynamic other) => add(other);

  Date add(dynamic other) {
    if (other is Date) {
      return Date(year + other.year, (month) + (other.month), (day) + (other.day));
    } else if (other is DateTime) {
      return Date(year + other.year, (month) + (other.month), (day) + (other.day));
    } else if (other is Duration) {
      return Date(year, month, (day) + (other.inDays));
    } else if (other is num) {
      return Date(year, month, (day) + (other.toInt()));
    }
    return this;
  }

  Date operator -(dynamic other) => subtract(other);

  Date subtract(dynamic other) {
    if (other is Date) {
      return Date(year - other.year, (month) - (other.month), max(1, (day) - (other.day)));
    } else if (other is DateTime) {
      return Date(year - other.year, (month) - (other.month), max(1, (day) - (other.day)));
    } else if (other is Duration) {
      return Date(year, month, (day) - (other.inDays));
    } else if (other is num) {
      return Date(year, month, (day) - (other.toInt()));
    }
    return this;
  }

  Duration difference(dynamic other) {
    if (other is Date) {
      return toDateTime().difference(other.toDateTime());
    } else if (other is DateTime) {
      return toDateTime().difference(other);
    } else {
      return 0.days;
    }
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => format();

  /// Returns the localized string representation of this time of day.
  ///
  /// This is a shortcut for [MaterialLocalizations.formatTimeOfDay].
  String format([String? dateFormat]) {
    dateFormat ??= Date.defaultDateFormat;
    return DateFormat(dateFormat).format(toDateTime());
  }

  String formatWithDateFormat([DateFormat? dateFormat]) {
    dateFormat ??= DateFormat(Date.defaultDateFormat);
    return dateFormat.format(toDateTime());
  }

  String get formatMonth => _monthFormat.format(toDateTime());
  String get formatMonthOnly => _monthOnlyFormat.format(toDateTime());
  String get formatDay => _dayFormat.format(toDateTime());
  String get formatFirstDay => _firstDayFormat.format(toDateTime());
  String get formatFullDay => _fullDayFormat.format(toDateTime());
  String get formatApiDay => _apiDayFormat.format(toDateTime());

  /// The last day of a given month
  Date get lastDayOfMonth {
    var beginningNextMonth = (month < 12) ? Date(year, month + 1, 1) : Date(year + 1, 1, 1);
    return beginningNextMonth - 1.days;
  }

  bool get isLastDayOfMonth {
    return lastDayOfMonth == this;
  }

  bool get isFirstDayOfMonth {
    return lastDayOfMonth == this;
  }

  Date get firstDayOfMonth {
    return Date(year, month);
  }

  Date get firstDayOfWeek {
    /// Weekday is on a 1-7 scale Monday - Sunday,
    /// This Calendar works from Sunday - Monday
    var decreaseNum = weekday % 7;
    return this - decreaseNum.days;
  }

  /// The previousMonth
  Date get previousMonth {
    if (month == 1) {
      return Date(year - 1, 12);
    } else {
      return Date(year, month - 1);
    }
  }

  /// The previousMonth
  Date get nextMonth {
    if (month == 12) {
      return Date(year + 1);
    } else {
      return Date(year, month + 1);
    }
  }

  @override
  int compareTo(Date other) {
    if (isBefore(other)) {
      return -1;
    } else if (isAfter(other)) {
      return 1;
    }
    return 0;
  }

  /// The list of days in a given month
  static List<Date> daysInMonth(Date monthDate) {
    var first = getFirstDayOfMonth(monthDate);
    var daysBefore = first.toDateTime().weekday;
    var firstToDisplay = first - daysBefore;
    var last = getLastDayOfMonth(monthDate);

    int daysAfter = 7 - last.toDateTime().weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    var lastToDisplay = last + daysAfter;
    return daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  static Date getLastDayOfWeek(Date day) {
    var increaseNum = day.weekday % 7;
    return day + (7 - increaseNum).days;
  }

  static Date getFirstDayOfMonth(Date date) {
    return Date(date.year, date.month);
  }

  static Date getLastDayOfMonth(Date date) {
    var beginningNextMonth = (date.month < 12) ? Date(date.year, date.month + 1, 1) : Date(date.year + 1, 1, 1);
    return beginningNextMonth - 1.days;
  }

  static Iterable<Date> daysInRange(Date start, Date end) sync* {
    var i = start;
    while (i.isBefore(end)) {
      yield i;
      i = i + 1.days;
    }
  }

  /// The previousMonth
  static Date getPreviousMonth(Date m) {
    var year = m.year;
    var month = m.month;
    if (month == 1) {
      year--;
      month = 12;
    } else {
      month--;
    }
    return Date(year, month);
  }

  /// The nextMonth
  static Date getNextMonth(Date m) {
    var year = m.year;
    var month = m.month;

    if (month == 12) {
      year++;
      month = 1;
    } else {
      month++;
    }
    return Date(year, month);
  }

  /// The previousWeek
  static Date previousWeek(Date w) {
    return w - 7.days;
  }

  /// The nextWeek
  static Date nextWeek(Date w) {
    return w + 7.days;
  }
}
