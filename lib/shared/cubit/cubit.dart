// ignore_for_file: unnecessary_string_interpolations, avoid_function_literals_in_foreach_calls

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archive_tasks/archive_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_yasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);

  //Button Sheet
  bool isButtonSheet = false;
  isButtonSheetToggleTrue() {
    isButtonSheet = true;
    emit(AppButtonSheetToggle());
  }

  isButtonSheetToggleFalse() {
    isButtonSheet = false;
    emit(AppButtonSheetToggle());
  }

  int currentIndex = 0;
  List<Widget> screen = const [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchiveTasksScreen(),
  ];

  List<String> title = [
    "New Tasks",
    "Done Tasks",
    "Archive Tasks",
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  // Database
  Database? db;
  List<Map> newtasks = [];
  List<Map> donetasks = [];
  List<Map> archivedtasks = [];

  connectDatabase() {
    //connect database
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {})
            .catchError((error) {});
      },
      onOpen: (database) {
        getAllTasks(database);
      },
    ).then((value) {
      db = value;
      emit(AppCreateDatabase());
    });
  }

  Future insertTodos({
    //insert database
    required String title,
    required String date,
    required String time,
  }) async {
    return await db!.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        emit(AppInsertDatabase());
      }).catchError((error) {});
    });
  }

  void getAllTasks(Database db) {
    newtasks = [];
    donetasks = [];
    archivedtasks = [];
    //get all database
    db.rawQuery("SELECT * FROM tasks").then((value) {
      value.forEach((e) {
        if (e['status'] == 'new') {
          newtasks.add(e);
        } else if (e['status'] == 'done') {
          donetasks.add(e);
        } else {
          archivedtasks.add(e);
        }
      });
      emit(AppUpdateDatabase());
    });
  }

  void updateTodos(String status, int id) {
    db!.rawUpdate(
      'UPDATE tasks SET status=? WHERE id=?',
      ["$status", id],
    ).then((value) {
      getAllTasks(db!);
      emit(AppUpdateDatabase());
    });
  }

  void deleteTodos(int id) {
    db!.rawDelete(
      'DELETE FROM tasks WHERE id=?',
      [id],
    ).then((value) {
      getAllTasks(db!);
      emit(AppDeleteDatabase());
    });
  }
}
