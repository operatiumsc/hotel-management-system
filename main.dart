import 'dart:convert';
import 'dart:io';

class Command {
  String? name;
  dynamic params;

  Command(this.name, this.params);
}

void main() {
  const String fileName = 'input.txt';
  final List<Command> commands = getCommandsFromFileName(fileName);

  commands.forEach((Command command) {
    switch (command.name) {
      case 'create_hotel':
        createHotel(command.params);
        break;
      default:
    }
  });
}

List<Command> getCommandsFromFileName(String fileName) {
  final List<String> textLines = File(fileName).readAsLinesSync(encoding: utf8);

  return textLines
      .map((line) => line.split(" "))
      .map((lineItems) => Command(
            lineItems.first,
            lineItems.skip(0).map((param) {
              final parsedParam = int.parse(param, radix: 10);

              return parsedParam.isNaN ? parsedParam : param;
            }),
          ))
      .toList();
}

void createHotel(dynamic params) {
  final hotel = List.from(params);
  final int floor = hotel[0];
  final int roomsPerFloor = hotel[1];

  print(
      'Hotel created with $floor floor(s), $roomsPerFloor room(s) per floor.');
}

void book(dynamic params) {
  final booking = List.from(params);
  final int roomNo = booking[0];
  final String guestName = booking[1];
  final int guestAge = booking[2];

  print('Room $roomNo is booked by $guestName with keycard number 1.');
}
