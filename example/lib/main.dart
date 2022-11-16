import 'package:date_only_field/date_only_field_with_extensions.dart';
import 'package:flutter/material.dart';

void main() {
  testDate();
}

void testDate() {
  Date now = Date.now();
  Date now2 = Date.fromDateTime(DateTime.now());
  Date tomorrow = Date.tomorrow();
  Date yesterday = Date.yesterday();

  print(now); //16-11-2022

  print(now.formatFullDay); //Wed Nov 16, 2022
  print(yesterday); //15-11-2022
  print(tomorrow); //17-11-2022

  print(now.toDateTime() == DateTime.now()); //true
  print(now == now2); //true

  print(tomorrow == now + 1.days); //true
  print(tomorrow > yesterday); //true
  print(now == Date.now()); //true

  print(tomorrow.isTomorrow); //true
  print(tomorrow.isFuture); //true

  print(yesterday.isYesterday); //true
  print(yesterday.isPast); //true

  print(tomorrow.isSameMonth(yesterday)); //true
  print(tomorrow.isSameWeek(yesterday)); //true

  print(now.firstDayOfMonth); //01-11-2022
  print(now.firstDayOfWeek); //13-11-2022
  print(now.lastDayOfMonth); //30-11-2022
}
