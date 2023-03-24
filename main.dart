import 'services/command_service.dart';
import 'services/room_service.dart';

//Welcome to PEAK Hotel
//Dart Sounds Null Safety

///Run APP HERE!!
Future<void> main() async {
  const String fileName = 'input.txt';
  final commandService = CommandServiceImpl();
  final commands = await commandService.getCommandsFromFileName(fileName);

  final roomService = RoomServiceImpl();

  commands.forEach((command) {
    switch (command.name) {
      case 'book':
        roomService.book(command.params);
        break;
      case 'book_by_floor':
        roomService.bookByFloor(command.params);
        break;
      case 'checkout':
        roomService.checkout(command.params);
        break;
      case 'checkout_guest_by_floor':
        roomService.checkoutGuestByFloor(command.params);
        break;
      case 'create_hotel':
        roomService.createHotel(command.params);
        break;
      case 'get_guest_in_room':
        roomService.getGuestByRoomNo(command.params);
        break;
      case 'list_available_rooms':
        roomService.getAvaliableRooms();
        break;
      case 'list_guest':
        roomService.getUniqueGuests();
        break;
      case 'list_guest_by_age':
        roomService.getGuestByAge(command.params);
        break;
      case 'list_guest_by_floor':
        roomService.getGuestByFloor(command.params);
        break;
      default:
    }
  });
}
