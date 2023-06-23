import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:rrule/rrule.dart';

class WeekDaysHelper {
  static List<Map<String, Object>> weekdaysList = [
    {'day': weekDays[WeekDays.MO], 'name': 'monday'},
    {'day': weekDays[WeekDays.TU], 'name': 'tuesday'},
    {'day': weekDays[WeekDays.WE], 'name': 'wednesday'},
    {'day': weekDays[WeekDays.TH], 'name': 'thursday'},
    {'day': weekDays[WeekDays.FR], 'name': 'friday'},
    {'day': weekDays[WeekDays.SA], 'name': 'saturday'},
    {'day': weekDays[WeekDays.SU], 'name': 'sunday'},
  ];

  static List<Map<String, Object>> selectedWeekdays = [
    {'day': weekDays[WeekDays.MO], 'selected': false},
    {'day': weekDays[WeekDays.TU], 'selected': false},
    {'day': weekDays[WeekDays.WE], 'selected': false},
    {'day': weekDays[WeekDays.TH], 'selected': false},
    {'day': weekDays[WeekDays.FR], 'selected': false},
    {'day': weekDays[WeekDays.SA], 'selected': false},
    {'day': weekDays[WeekDays.SU], 'selected': false},
  ];

  static void reinitializeSelectedWeekDays(){
    selectedWeekdays = [
      {'day': weekDays[WeekDays.MO], 'selected': false},
      {'day': weekDays[WeekDays.TU], 'selected': false},
      {'day': weekDays[WeekDays.WE], 'selected': false},
      {'day': weekDays[WeekDays.TH], 'selected': false},
      {'day': weekDays[WeekDays.FR], 'selected': false},
      {'day': weekDays[WeekDays.SA], 'selected': false},
      {'day': weekDays[WeekDays.SU], 'selected': false},
    ];
  }

  static void setSelectedWeekdays(List<String> weekDays){
    for (final weekDay in selectedWeekdays) {
      weekDay['selected'] = weekDays.any((selectedWeekday) => selectedWeekday == weekDay['day']);
    }
  }

  static List<DateTime> getRecurringDates(Frequency frequency, int count, { List<String> weekDays = const [], DateTime startingDate }){
    final List<Map<String, Object>> selectedDays = weekDays.isEmpty ? selectedWeekdays
                                              .where((item) => item['selected'] as bool == true)
                                              .map((item) => {
                                                'day': item['day'].toString(),
                                                'number': WeekDaysHelper.selectedWeekdays.indexOf(item) + 1
                                              },)
                                              .toList() : 
                                              weekDays.map((item) => {
                                                'day': item,
                                                'number': selectedWeekdays.indexWhere((selectedWeekdayItem) => selectedWeekdayItem['day'].toString() == item) + 1
                                              }).toList();
    if (selectedDays.isEmpty){
      return [];
    }
    final Set<ByWeekDayEntry> selectedWeekDays = {
      ...selectedDays.map((day) => ByWeekDayEntry(day['number'] as int))
    };
    final rrule = RecurrenceRule(
      frequency: frequency,
      count: count,
      byWeekDays: selectedWeekDays,
    );
    final DateTime currentDate = startingDate != null ? startingDate.copyWith(isUtc: true) : DateTime.now().copyWith(isUtc: true);
    final List<DateTime> datesList = rrule.getInstances(start: currentDate)
                                          .map((currentDate) => currentDate.copyWith(isUtc: false))
                                          .toList();
    return datesList;
  }

  static List<DateTime> getOneWeekDatesFromNextScheduledDate(DateTime nextScheduledDate){
    const int weekDaysAmount = 7;
    final rrule = RecurrenceRule(
      frequency: Frequency.daily,
      count: weekDaysAmount,
    );
    final DateTime utcDate = nextScheduledDate.copyWith(isUtc: true);
    final List<DateTime> datesList = rrule.getInstances(start: utcDate)
                                          .map((currentDate) => currentDate.copyWith(isUtc: false))
                                          .toList();
    return datesList;
  }

  static int daysBetween(DateTime from, DateTime to) {
     final DateTime fromDate = DateTime(from.year, from.month, from.day);
     final DateTime toDate = DateTime(to.year, to.month, to.day);
   return (toDate.difference(fromDate).inHours / 24).round() + 1;
  }
}
