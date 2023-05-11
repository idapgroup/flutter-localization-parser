import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:csv/csv.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('csv', abbr: 'c', help: 'The path to the CSV file')
    ..addOption('locales',
        abbr: 'l', help: 'The comma-separated list of input locales');

  final results = parser.parse(arguments);

  if (results['csv'] == null) {
    print('Error: No CSV file path provided');
    print(parser.usage);
    return;
  }

  if (results['locales'] == null) {
    print('Error: No input locales provided');
    print(parser.usage);
    return;
  }

  final csvPath = results['csv'];
  final inputLocales = (results['locales'] as String).split(',');

  final csvFile = File(csvPath);
  if (!csvFile.existsSync()) {
    print('Error: CSV file not found');
    return;
  }

  final csvContent = csvFile.readAsStringSync();
  final rows = const CsvToListConverter().convert(csvContent);
  final keys = rows.map((row) => row[0]).skip(1).toList();
  final keysCount = keys.length;
  final locales = rows.first.toList();
  print(locales);
  for (var locale in inputLocales) {
    var localeIndex = locales.indexOf(locale);

    if (localeIndex != -1) {
      var values = rows.map((row) => row[localeIndex]).skip(1).toList();
      var map = {};

      for (var j = 0; j < keysCount; j++) {
        map[keys[j]] = values[j];
      }

      File file = File('lib/l10n/app_$locale.arb');
      file.writeAsStringSync(
        json.encode(map),
      );
    } else {
      print("Locale '$locale' not found in the CSV file");
    }
  }
}
