import '../models/guest.dart';
import '../models/room.dart';

abstract class RoomService {
  void createHotel(params);
  void book(params);
  void bookByFloor(params);
  void getAvaliableRooms();
  void checkout(params);
  void checkoutGuestByFloor(params);
  void getUniqueGuests();
  void getGuestByRoomNo(params);
  void getGuestByAge(params);
  void getGuestByFloor(params);
}

class RoomServiceImpl implements RoomService {
  List<Room> rooms = [];

  List<int> keyCards = [];

  @override
  void createHotel(params) {
    final hotel = List.from(params);
    final int floor = hotel[0];
    final int roomsPerFloor = hotel[1];

    //Build rooms
    for (int iFloor = 1; iFloor <= floor; iFloor++) {
      for (int iRoom = 1; iRoom <= roomsPerFloor; iRoom++) {
        rooms.add(Room(
          floor: iFloor,
          roomNo: (iFloor * 100 + iRoom).toString(),
          status: RoomStatus.available,
        ));
      }
    }

    //Generate keycards
    keyCards =
        List.generate(floor * roomsPerFloor, (index) => index + 1).toList();

    print(
        'Hotel created with $floor floor(s), $roomsPerFloor room(s) per floor.');
  }

  @override
  void book(params) {
    final booking = List.from(params);
    final String roomNo = booking[0].toString();
    final String guestName = booking[1];
    final int guestAge = booking[2];

    final int index = rooms.indexWhere((room) => room.roomNo == roomNo);

    //Check if the room is booked.
    if (rooms[index].status == RoomStatus.booked) {
      print(
          'Cannot book room $roomNo for $guestName, The room is currently booked by ${rooms[index].guest?.name}.');
      return;
    }

    //Sort keycard.
    keyCards.sort();

    //Receptionist picks the first available keycard.
    int selectedKeyCard = keyCards.first;

    //Booking...
    rooms[index]
      ..guest = Guest(name: guestName, age: guestAge)
      ..status = RoomStatus.booked
      ..keyCardNo = selectedKeyCard;

    //Remove keycard from the shelf.
    keyCards.removeAt(0);

    print(
        'Room $roomNo is booked by $guestName with keycard number $selectedKeyCard.');
  }

  @override
  void bookByFloor(params) {
    final booking = List.from(params);
    final int floor = booking.first;
    final String guestName = booking[1];
    final int guestAge = booking[2];

    var bookedRooms = Set<String>();
    var inUsedkeyCards = Set<int>();

    //Check if there is any room is booked.
    for (Room room in rooms) {
      if (room.floor == floor && room.status == RoomStatus.booked) {
        print('Cannot book floor $floor for $guestName.');
        return;
      }
    }

    //Sort keycard.
    keyCards.sort();

    for (Room room in rooms) {
      //Check floor
      if (room.floor != floor) {
        continue;
      }

      //Booking
      room
        ..guest = Guest(name: guestName, age: guestAge)
        ..status = RoomStatus.booked
        ..keyCardNo = keyCards.first;

      //Remove keycard from the shelf.
      keyCards.removeAt(0);

      //Record history
      bookedRooms.add(room.roomNo!);
      inUsedkeyCards.add(room.keyCardNo!);
    }

    final String bookedRoomInfo = bookedRooms.join(', ');
    final String inUsedkeyCardInfo = inUsedkeyCards.join(', ');
    print(
        'Room $bookedRoomInfo are booked with keycard number $inUsedkeyCardInfo');
  }

  @override
  void getAvaliableRooms() {
    var avaialbleRoomNo = Set<String>();

    rooms.forEach((room) {
      if (room.status == RoomStatus.available) {
        avaialbleRoomNo.add(room.roomNo!);
      }
    });

    print(avaialbleRoomNo);
  }

  void checkout(params) {
    final checkoutInfo = List.from(params);
    final int keyCardNo = checkoutInfo.first;
    final String guestName = checkoutInfo[1];

    //Get index of the guest's room.
    final int index = rooms.indexWhere((room) => room.keyCardNo == keyCardNo);

    //Check if the guest is not the room's owner.
    if (guestName != rooms[index].guest?.name) {
      print(
          'Only ${rooms[index].guest?.name} can checkout with keycard number $keyCardNo.');
      return;
    }

    //Checkout
    rooms[index]
      ..guest = null
      ..keyCardNo = null
      ..status = RoomStatus.available;

    //Return keycard.
    keyCards.add(keyCardNo);

    print('Room ${rooms[index].roomNo} is checkout.');
  }

  @override
  void checkoutGuestByFloor(params) {
    final int floor = List.from(params).first;
    var checkedOutRooms = Set<String>();

    for (Room room in rooms) {
      //Check floor
      if (room.floor != floor) {
        continue;
      }
      //Check room's status
      if (room.status == RoomStatus.available) {
        continue;
      }

      //Get keycard from the guest
      final int returnedKeycard = room.keyCardNo!;

      //Check out.
      room
        ..guest = null
        ..keyCardNo = null
        ..status = RoomStatus.available;

      //Record history.
      checkedOutRooms.add(room.roomNo!);

      //Get back the keycards.
      keyCards.add(returnedKeycard);
    }

    final String allCheckedOutRooms = checkedOutRooms.join(', ');

    print('Room ${allCheckedOutRooms} are checkout.');
  }

  @override
  void getUniqueGuests() {
    var uniqueGuests = Set<String>();

    rooms.forEach((room) {
      if (room.guest != null) {
        uniqueGuests.add(room.guest!.name!);
      }
    });

    //Sort DESC.
    print(uniqueGuests.toList().reversed);
  }

  void getGuestByRoomNo(params) {
    final String roomNo = List.from(params).first.toString();

    final roomInfo = rooms.firstWhere((room) => room.roomNo == roomNo);

    print(roomInfo.guest?.name);
  }

  @override
  void getGuestByAge(params) {
    final data = List.from(params);
    final String mathOperator = data[0];
    final int age = data[1];
    var guests = Set<String>();

    switch (mathOperator) {
      case '<':
        rooms.forEach((room) {
          if (room.guest != null) {
            if (room.guest!.age! < age) {
              guests.add(room.guest!.name!);
            }
          }
        });
        break;
      case '<=':
        rooms.forEach((room) {
          if (room.guest != null) {
            if (room.guest!.age! <= age) {
              guests.add(room.guest!.name!);
            }
          }
        });
        break;
      case '=':
        rooms.forEach((room) {
          if (room.guest != null) {
            if (room.guest!.age! == age) {
              guests.add(room.guest!.name!);
            }
          }
        });
        break;
      case '>=':
        rooms.forEach((room) {
          if (room.guest != null) {
            if (room.guest!.age! >= age) {
              guests.add(room.guest!.name!);
            }
          }
        });
        break;
      case '>':
        rooms.forEach((room) {
          if (room.guest != null) {
            if (room.guest!.age! > age) {
              guests.add(room.guest!.name!);
            }
          }
        });
        break;
      default:
    }
    ;

    print(guests);
  }

  @override
  void getGuestByFloor(params) {
    final int floor = List.from(params).first;
    var guests = Set<String>();

    final roomsOfFloor = rooms.where((room) => room.floor == floor);

    roomsOfFloor.forEach((room) {
      if (room.floor == floor && room.guest != null) {
        guests.add(room.guest!.name!);
      }
    });

    print(guests);
  }
}
