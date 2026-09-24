class DateFormatter {
  DateFormatter._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String short(DateTime date) => '${_months[date.month - 1]} ${date.day}';

  static String long(DateTime date) => '${_months[date.month - 1]} ${date.day}, ${date.year}';
}
