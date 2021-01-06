import 'dart:math';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

//データベースに格納するクラス作成
class Expense {
  final int id;
  final int year;
  final int month;
  final int day;
  final String payment; //収支判別
  final String name;
  final int money;

  Expense(
      {this.id,
      this.payment,
      this.year,
      this.month,
      this.day,
      this.name,
      this.money});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // 'payment': payment,
      'year': year,
      'month': month,
      'day': day,
      'name': name,
      'money': money,
    };
  }

  @override
  String toString() {
    //return 'Expense{id: $id, /*payment: $payment, year: $year, month: $month, day: $day, name: $name, money: $money}';
    return 'Expense{id: $id, year: $year, month: $month, day: $day, name: $name, money: $money}';
  }
}

//データベースインタフェース
class dbInterface {
  Database _database;

  //データベース作成（初期化）
  Future<Database> get databace async {
    print("initinit");
    if (_database != null) return _database;
    return _database = await _initDatabase();
  }

  _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, "expenses_database.db");
    print("dbinit");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          //"CREATE TABLE expenses(id INTEGER PRIMARY KEY, payment TEXT,  year Integer, month Integer, day Integer, name Text, money Integer)",
          "CREATE TABLE expenses(id INTEGER PRIMARY KEY, year Integer, month Integer, day Integer, name Text, money Integer)",
        );
      },
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  //データ挿入
  Future<void> insertExpense(Expense expense) async {
    print("add");
    final Database db = await databace;

    await db.insert(
      'expenses',
      expense.toMap(),
      //conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //データ表示
  Future<List<Expense>> expenses() async {
    final Database db = _database;
    final List<Map<String, dynamic>> maps = await db.query("expenses");
    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        year: maps[i]['year'],
        month: maps[i]['month'],
        day: maps[i]['day'],
        name: maps[i]['name'],
        money: maps[i]['money'],
      );
    });
  }

  //データ更新
  Future<void> updateExpense(Expense expense) async {
    final db = _database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = _database;
    await db.delete(
      'expenses',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
