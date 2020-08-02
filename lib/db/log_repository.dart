import 'package:bubbleapp/models/log.dart';
import 'package:bubbleapp/db/hive_methods.dart';
import 'package:meta/meta.dart';
import 'package:bubbleapp/db/sqlite_methods.dart';

class LogRepository {
  static var dbObject;
  static bool isHive;

  static init({@required bool isHive}) {
    dbObject = isHive ? HiveMethods() : SqliteMethods();
    dbObject.init();
  }

  static addLogs(Log log) => dbObject.addLogs(log);

  static deleteLogs(int logId) => dbObject.deleteLogs(logId);

  static getLogs() => dbObject.getLogs();

  static close() => dbObject.close();
}
