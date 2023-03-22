import 'dart:io';

import 'models/command.dart';
import 'models/guest.dart';
import 'models/room.dart';

List<Room> rooms = [];

List<int> keyCards = [];

void main() {
  const String fileName = 'input.txt';
  final List<Command> commands = getCommandsFromFileName(fileName);

  commands.forEach((Command command) {
    switch (command.name) {
      case 'book':
        book(command.params);
        break;
      case 'book_by_floor':
        bookByFloor(command.params);
        break;
      case 'checkout':
        checkout(command.params);
        break;
      case 'checkout_guest_by_floor':
        checkoutGuestByFloor(command.params);
        break;
      case 'create_hotel':
        createHotel(command.params);
        break;
      case 'get_guest_in_room':
        getGuestByRoomNo(command.params);
        break;
      case 'list_available_rooms':
        getAvaliableRooms();
        break;
      case 'list_guest':
        getUniqueGuests();
        break;
      case 'list_guest_by_age':
        getGuestByAge(command.params);
        break;
      case 'list_guest_by_floor':
        getGuestByFloor(command.params);
        break;
      default:
    }
  });
}

List<Command> getCommandsFromFileName(String fileName) {
  final List<String> textLines = File(fileName).readAsLinesSync();

  return textLines
      .map((line) => line.split(" "))
      .map((lineItems) => Command(
            name: lineItems.first,
            params: lineItems
                .skip(1)
                .map((param) => int.tryParse(param) ?? param)
                .toList(),
          ))
      .toList();
}

void createHotel(params) {
  final hotel = List.from(params);
  final int floor = hotel[0];
  final int roomsPerFloor = hotel[1];

  //Generate rooms
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

void book(params) {
  final booking = List.from(params);
  final int roomNo = booking[0];
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

  rooms[index]
    ..guest = Guest(name: guestName, age: guestAge)
    ..status = RoomStatus.booked
    ..keyCardNo = selectedKeyCard;

  //Remove keycard from the shelf.
  keyCards.remove(selectedKeyCard);

  print(
      'Room $roomNo is booked by $guestName with keycard number $selectedKeyCard.');
}

void bookByFloor(params) {
  final booking = List.from(params);
  final int floor = booking[0];
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

  //Receptionist picks the first available keycard.
  int selectedKeyCard = keyCards.first;

  for (Room room in rooms) {
    room
      ..guest = Guest(name: guestName, age: guestAge)
      ..status = RoomStatus.booked
      ..keyCardNo = selectedKeyCard;

    //Remove keycard from the shelf.
    keyCards.remove(selectedKeyCard);

    bookedRooms.add(room.roomNo!);
    inUsedkeyCards.add(room.keyCardNo!);
  }

  final String bookedRoomInfo = bookedRooms.join(', ');
  final String inUsedkeyCardInfo = inUsedkeyCards.join(', ');
  print(
      'Room $bookedRoomInfo are booked with keycard number $inUsedkeyCardInfo');
}

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
  final int keyCardNo = checkoutInfo[0];
  final String guestName = checkoutInfo[1];

  //Get index of the guest's room.
  final int index = rooms.indexWhere((room) => room.keyCardNo == keyCardNo);

  //Check if the guest is not the room's owner.
  if (guestName != rooms[index].guest?.name) {
    print(
        'Only ${rooms[index].guest?.name} can checkout with keycard number $keyCardNo.');
    return;
  }

  rooms[index]
    ..guest = null
    ..keyCardNo = null
    ..status = RoomStatus.available;

  //Return keycard.
  keyCards.add(keyCardNo);

  print('Room ${rooms[index].roomNo} is checkout.');
}

void checkoutGuestByFloor(params) {
  final int floor = List.from(params).first;
  var checkedOutRooms = Set<String>();

  rooms.forEach((room) {
    if (room.floor == floor && room.status == RoomStatus.booked) {
      //Check out.
      room
        ..guest = null
        ..keyCardNo = null
        ..status = RoomStatus.available;

      checkedOutRooms.add(room.roomNo!);

      //Return all keycards.
      keyCards.add(room.keyCardNo!);
    }
  });

  final String allCheckedOutRooms = checkedOutRooms.join(', ');

  print('Room ${allCheckedOutRooms} are checkout.');
}

void getUniqueGuests() {
  var uniqueGuests = Set<String?>();

  rooms.forEach((room) {
    uniqueGuests.add(room.guest?.name);
  });

  print(uniqueGuests);
}

void getGuestByRoomNo(params) {
  final roomNo = List.from(params).first;

  final roomInfo = rooms.firstWhere((room) => room.roomNo == roomNo);

  print(roomInfo.guest?.name);
}

void getGuestByAge(params) {
  final data = List.from(params);
  final String mathOperator = data[0];
  final int age = data[1];
  var guests = Set<String?>();

  switch (mathOperator) {
    case '<':
      rooms.forEach((room) {
        if (room.guest != null) {
          if (room.guest!.age! < age) {
            guests.add(room.guest?.name);
          }
        }
      });
      break;
    case '<=':
      rooms.forEach((room) {
        if (room.guest != null) {
          if (room.guest!.age! <= age) {
            guests.add(room.guest?.name);
          }
        }
      });
      break;
    case '=':
      rooms.forEach((room) {
        if (room.guest != null) {
          if (room.guest!.age! == age) {
            guests.add(room.guest?.name);
          }
        }
      });
      break;
    case '>=':
      rooms.forEach((room) {
        if (room.guest != null) {
          if (room.guest!.age! >= age) {
            guests.add(room.guest?.name);
          }
        }
      });
      break;
    case '>':
      rooms.forEach((room) {
        if (room.guest != null) {
          if (room.guest!.age! > age) {
            guests.add(room.guest?.name);
          }
        }
      });
      break;
    default:
  }
  ;

  print(guests);
}

void getGuestByFloor(params) {
  final int age = List.from(params).first;
  var guests = Set<String?>();

  rooms.forEach((room) {
    if (room.guest != null) {
      if (room.guest!.age! < age) {
        guests.add(room.guest?.name);
      }
    }
  });

  print(guests);
}

void getGuestsByFloor(params) {
  final int floor = List.from(params).first;
  var guests = Set<String?>();

  rooms.forEach((room) {
    if (room.floor == floor && room.guest != null) {
      guests.add(room.guest?.name);
    }
  });

  print(guests);
}
