class Formatters {
  Formatters._();

  static String fee(dynamic value) {
    final number = value is num ? value : num.tryParse('$value') ?? 0;
    if (number == number.roundToDouble()) {
      return 'Rs ${number.toInt()}';
    }
    return 'Rs ${number.toStringAsFixed(0)}';
  }

  static String relativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return '${time.day}/${time.month}/${time.year}';
  }
}
