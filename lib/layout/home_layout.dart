import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

// ignore: must_be_immutable
class HomeLayout extends StatelessWidget {
  //Controller
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  HomeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit()..connectDatabase(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(AppCubit.get(context)
                  .title[AppCubit.get(context).currentIndex]),
              centerTitle: true,
            ),
            body: AppCubit.get(context)
                .screen[AppCubit.get(context).currentIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (AppCubit.get(context).isButtonSheet) {
                  if (formKey.currentState!.validate()) {
                    AppCubit.get(context)
                        .insertTodos(
                      date: dateController.text,
                      time: timeController.text,
                      title: titleController.text,
                    )
                        .then((value) {
                      Navigator.pop(context);
                      AppCubit.get(context)
                          .getAllTasks(AppCubit.get(context).db!);
                      titleController.text = '';
                      dateController.text = '';
                      timeController.text = '';
                    });
                    AppCubit.get(context).isButtonSheetToggleFalse();
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) =>
                            SingleChildScrollView(child: widgetSheet(context)),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    AppCubit.get(context).isButtonSheetToggleFalse();
                  });
                  AppCubit.get(context).isButtonSheetToggleTrue();
                }
              },
              child: AppCubit.get(context).isButtonSheet
                  ? const Icon(Icons.add)
                  : const Icon(Icons.edit),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: AppCubit.get(context).currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                AppCubit.get(context).changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_outlined),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archive',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// widget

  Widget widgetSheet(context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                label: Text("TITLE"),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                prefixIcon: Icon(Icons.title_outlined),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Tilte Must Be Not Empty";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextFormField(
              controller: timeController,
              keyboardType: TextInputType.none,
              decoration: const InputDecoration(
                label: Text("TIME"),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                prefixIcon: Icon(Icons.watch_later_outlined),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Time Must Be Not Empty";
                }
                return null;
              },
              onTap: () {
                showTimePicker(context: context, initialTime: TimeOfDay.now())
                    .then((value) {
                  timeController.text = value!.format(context).toString();
                });
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextFormField(
              controller: dateController,
              keyboardType: TextInputType.none,
              decoration: const InputDecoration(
                label: Text("Task Date"),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                prefixIcon: Icon(Icons.watch_later_outlined),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Date Must Be Not Empty";
                }
                return null;
              },
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.parse('2021-12-28'),
                ).then((value) {
                  if (value != null) {
                    dateController.text = DateFormat.yMMMd().format(value);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
