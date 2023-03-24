import 'dart:io';

import '../models/command.dart';

abstract class CommandService {
  Future<List<Command>> getCommandsFromFileName(String fileName);
}

class CommandServiceImpl implements CommandService {
  @override
  Future<List<Command>> getCommandsFromFileName(String fileName) async {
    final textLines = await File(fileName).readAsLines();

    return textLines
        .map((line) => line.split(' '))
        .map((lineItems) => Command(
              name: lineItems.first,
              params: lineItems
                  .skip(1)
                  .map((param) => int.tryParse(param) ?? param)
                  .toList(),
            ))
        .toList();
  }
}
