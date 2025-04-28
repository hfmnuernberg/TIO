import 'package:logger/logger.dart';

const level = Level.warning;

final logger = Logger(level: level, printer: SimplePrinter(colors: false));

createPrefixLogger(String prefix) => Logger(level: level, printer: PrefixPrinter(prefix: prefix));

class PrefixPrinter extends LogPrinter {
  final String prefix;
  final LogPrinter _printer;

  PrefixPrinter({required this.prefix}) : _printer = SimplePrinter(colors: false);

  @override
  List<String> log(LogEvent event) => _printer.log(event).map((line) => '[$prefix]  $line').toList();
}
