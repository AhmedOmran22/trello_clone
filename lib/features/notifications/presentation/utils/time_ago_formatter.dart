class TimeAgoFormatter {
  TimeAgoFormatter._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String format(DateTime dateTime, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = reference.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    }

    final today = DateTime(reference.year, reference.month, reference.day);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final dayDifference = today.difference(day).inDays;

    if (dayDifference == 1) return 'Yesterday';
    if (dayDifference < 7) return '$dayDifference days ago';

    final datePart = '${_months[dateTime.month - 1]} ${dateTime.day}';
    return dateTime.year == reference.year ? datePart : '$datePart, ${dateTime.year}';
  }
}
