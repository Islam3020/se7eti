List<int> getAvailableAppointments(DateTime selectedDate, String start, String end) {
  int startHour = int.parse(start);
  int endHour = int.parse(end);

  List<int> availableHours = [];

  DateTime now = DateTime.now();
  bool isToday = selectedDate.day == now.day &&
      selectedDate.month == now.month &&
      selectedDate.year == now.year;
      

  for (int i = startHour; i < endHour; i++) {
    if (isToday) {
      if (i > now.hour) {
        availableHours.add(i);
      }
    } else {
      availableHours.add(i);
    }
  }

  return availableHours;
}