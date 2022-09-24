import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/states.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

import '../screens/archived_tasks_screen.dart';
import '../screens/done_tasks_screen.dart';
import '../screens/new_task_screen.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(InitialAppState());
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  List<Map> tasks = [];

  int pageIndex = 0;

  static AppCubit get(BuildContext context) {
    return BlocProvider.of(context);
  }

  bool isBottomSheetOpen = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({required bool isOpen, required IconData icon}) {
    isBottomSheetOpen = isOpen;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  final List<Widget> screens = [
    NewTaskScreen(),
    DoneTaskScreen(),
    ArchivedTaskScreen()
  ];

  final List<String> screensName = ['New Task', 'Done Tasks', 'Archived Tasks'];

  void changePage(int index) {
    pageIndex = index;
    emit(AppBottomNavigationState());
  }

  late sql.Database _database;

  Future<void> createAndOpenDataBase() async {
    //here we get android and ios sql DB, and get the path to it  ...daPath is string
    final dbPath = await sql.getDatabasesPath();
    // here we open our Db if it exists , or create new one
    // sqlDb is the name of our dataBase

    // open the database
    _database = await sql.openDatabase(path.join(dbPath, 'todo.db'), version: 1,
        onCreate: (db, version) async {
      // When creating the db, create the table
      print('database has created');
      try {
        // creating our table  tasks
        await db.execute(
            'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT , status TEXT)');
        print('table created');
      } catch (error) {
        print('an error occurred when opening database${error.toString()}');
      }
      emit(AppCreateDatabaseState());
    }, onOpen: (db) async {
      // getAllData(db).then((value) {
      //   // setState(() {
      //   //   tasks = value;
      //   //   print('tasaks$tasks');
      //   // });
      // });
      // print('database opened');
      await getAllData(db);
    });
  }

  Future<void> insertIntoDatabase(
      {required String? title,
      required String? date,
      required String? time}) async {
    try {
      await _database.transaction((txn) async {
        final id = await txn.rawInsert(
            'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time","new")');
        print('$id inserted successfully');
        emit(
          AppInsertIntoDatabaseState(),
        );
        // txn.rawQuery('SELECT* FROM tasks').then((value) {
        //   tasks = value;
        //   print(value);

        // emit(AppGetDatabaseState());
      });
      await getAllData(_database);
      // getAllData(_database).then((value) {
      //   tasks = value;
      //   print(value);
      //   emit(
      //     AppGetDatabaseState(),
      //   );
      // });
    } catch (error) {
      print('an error occur while inserting');
    }
  }

  Future<void> getAllData(sql.Database database) async {
    emit(AppGetDatabaseStateLoadingIndicator());
    newTasks = [];
    archivedTasks = [];
    doneTasks = [];

    try {
      final data = await database.rawQuery('SELECT* FROM tasks');
      print('data:$data');
      tasks = data;
      data.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    } catch (e) {
      print('an error occurs when getting data from dataBase');
      print(e);
    }
  }

  Future<void> updateStatus(
      {required int taskId, required String status}) async {
    try {
      final updatedTaskId = await _database.rawUpdate(
          'UPDATE tasks SET status = ? WHERE id = ? ', [status, taskId]);
      print('updatedTaskId: $updatedTaskId');
      emit(AppUpdateDatabaseState());
      await getAllData(_database);
    } catch (e) {
      print('an error occurs when update  record on dataBase');
      print(e);
    }
  }

  Future<void> deleteTaskFromDb({required int taskId}) async {
    try {
      final deletedTaskId = await _database
          .rawDelete('DELETE FROM tasks WHERE id = ? ', [taskId]);
      emit(AppDeleteFromDatabaseState());
      print('deletedTaskId:$deletedTaskId');
      await getAllData(_database);
    } catch (err) {
      print('an error occurs when deleting record from database');
      print(err);
    }
  }
}
