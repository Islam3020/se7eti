List<int> getAvailableAppointments(
    DateTime selectedDate, String start, String end) {
  int startHour = int.parse(start.split(':')[0]);
  int endHour = int.parse(end.split(':')[0]);

  List<int> availableHours = [];
  for (int i = startHour; i < endHour; i++) {
    DateTime configuredDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int diffInDays = selectedDate.difference(configuredDate).inDays;
    if (diffInDays != 0) {
      availableHours.add(i);
    } else {
      // we are today
      if (i > DateTime.now().hour) {
        availableHours.add(i);
      }
    }
  }

  return availableHours;
}
