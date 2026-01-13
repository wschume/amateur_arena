import 'package:dart_mappable/dart_mappable.dart';

part 'event.mapper.dart';

@MappableClass()
class Event with EventMappable {
  @MappableField(key: 'id')
  final String? id;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final DateTime deadline;
  final String club;
  final String contact;
  final bool lookingForPlayers;

  Event({
    this.id,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.deadline,
    required this.club,
    required this.contact,
    required this.lookingForPlayers,
  });
}
