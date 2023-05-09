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

  static List<DateTime> getRecurringDates(Frequency frequency, int count){
    final List<Map<String, Object>> selectedDays = selectedWeekdays
                                              .where((item) => item['selected'] as bool == true)
                                              .map((item) => {
                                                'day': item['day'].toString(),
                                                'number': WeekDaysHelper.selectedWeekdays.indexOf(item) + 1
                                              },)
                                              .toList();
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
    final DateTime currentDate = DateTime.now().copyWith(isUtc: true);
    final List<DateTime> datesList = rrule.getInstances(start: currentDate).toList();
    return datesList;
  }
}
