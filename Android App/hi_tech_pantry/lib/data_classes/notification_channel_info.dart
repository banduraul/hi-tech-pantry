class NotificationChannelInfo {

  const NotificationChannelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.groupKey,
    required this.summaryText,
    required this.subText,
    required this.groupID,
  });

  final String id;
  final String name;
  final String description;
  final String groupKey;
  final String summaryText;
  final String subText;
  final int groupID;
}