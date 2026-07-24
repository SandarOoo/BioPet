class TimeAgo {
  static String format(DateTime datetime) {
    final now =DateTime.now();
    final diff= now.difference(datetime);

    if(diff.inSeconds <10 ) {
      return "Just now";
    } else if (diff.inMinutes < 1) {
      return "${diff.inSeconds} sec ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hr ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} days ago";
    } else {
      return "${datetime.day}/${datetime.month}/${datetime.year}";
    }
  }
}