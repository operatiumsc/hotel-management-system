import 'guest.dart';

class Room {
  int? floor;
  String? roomNo;
  int? keyCardNo;
  RoomStatus? status;
  Guest? guest;

  Room({this.floor, this.roomNo, this.keyCardNo, this.status, this.guest});
}

enum RoomStatus { available, booked }
