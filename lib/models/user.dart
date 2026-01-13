import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

@MappableClass()
class AmateurArenaUser with AmateurArenaUserMappable {
  final String uid;
  final String email;

  AmateurArenaUser({required this.uid, required this.email});
}
