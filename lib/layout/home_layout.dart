import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/states.dart';
import '../cubit/cubit.dart';
import '../widgets.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({Key? key}) : super(key: key);

  // int _selectedPageIndex = 0;
  // void _selectPage(int pageIndex) {
  //   setState(() {
  //     _selectedPageIndex = pageIndex;
  //   });
  // }

  final taskController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createAndOpenDataBase(),
      child: BlocConsumer<AppCubit, AppState>(listener: (context, state) {
        if (state is AppInsertIntoDatabaseState) Navigator.of(context).pop();
      }, builder: (context, state) {
        final appCubit = AppCubit.get(context);

        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(appCubit.screensName[appCubit.pageIndex]),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.done),
                label: 'Done',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.archive), label: 'archived'),
            ],
            currentIndex: appCubit.pageIndex,
            onTap: appCubit.changePage,
          ),
          body: state is! AppGetDatabaseStateLoadingIndicator
              ? Center(child: appCubit.screens[appCubit.pageIndex])
              : Center(
                  child: CircularProgressIndicator(),
                ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                // here we check if the bottom sheet is open when clicking on fab
                // we validate form and start inserting into database
                if (appCubit.isBottomSheetOpen) {
                  if (formKey.currentState?.validate() ?? false) {
                    appCubit.insertIntoDatabase(
                        title: taskController.text,
                        date: dateController.text,
                        time: timeController.text);
                    // here we clear controller so the next time when we open we get it empty
                    taskController.text = '';
                    dateController.text = '';
                    timeController.text = '';
                    // then change state change ab icon to edit and change isBottomSheet to false
                    appCubit.changeBottomSheetState(
                        isOpen: false, icon: Icons.edit);
                  }
                } else {
                  // here isBottomSheetOpen is false so we open bottomSheet
                  scaffoldKey.currentState!
                      .showBottomSheet(
                          (context) => Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(8.0),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildDefaultTextFormField(
                                          controller: taskController,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'please input task title';
                                            }
                                            return null;
                                          },
                                          labelText: 'Task Title'),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      buildDefaultTextFormField(
                                          onTap: () {
                                            showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay(
                                                        hour: 9, minute: 30))
                                                .then((value) {
                                              // setState(() {
                                              timeController.text =
                                                  value!.format(context);
                                              // });
                                            });
                                          },
                                          controller: timeController,
                                          prefixIcon: Icon(Icons.watch_later),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'please input task time';
                                            }
                                            return null;
                                          },
                                          labelText: 'Task Time'),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      buildDefaultTextFormField(
                                          onTap: () {
                                            showDatePicker(
                                              context: context,
                                              lastDate: DateTime.now()
                                                  .add(Duration(days: 30)),
                                              firstDate: DateTime.now(),
                                              initialDate: DateTime.now(),
                                            ).then((value) {
                                              // setState(() {
                                              dateController.text =
                                                  DateFormat.yMMMd()
                                                      .format(value!);
                                              // });
                                            });
                                          },
                                          controller: dateController,
                                          prefixIcon: Icon(Icons.date_range),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'please input task date';
                                            }
                                            return null;
                                          },
                                          labelText: 'Task Date')
                                    ],
                                  ),
                                ),
                              ),
                          elevation: 20.0)
                      .closed
                      .then((value) {
                    print(value);
                    if (appCubit.isBottomSheetOpen) {
                      appCubit.changeBottomSheetState(
                          isOpen: false, icon: Icons.edit);
                      taskController.text = '';
                      dateController.text = '';
                      timeController.text = '';
                    }

                    // if (isBottomSheetOpen) {
                    //   isBottomSheetOpen = false;
                    //   // setState(() {
                    //   //   fabIcon = Icons.edit;
                    //   //   taskController.text = '';
                    //   //   dateController.text = '';
                    //   //   timeController.text = '';
                    //   // });
                    // }
                  });
                  // after we open we change isBottomSheet to true and change icon
                  appCubit.changeBottomSheetState(
                      isOpen: true, icon: Icons.add);
                  // setState(() {
                  //   fabIcon = Icons.add;
                  // });
                }
              },
              child: Icon(appCubit.fabIcon)),
        );
      }),
    );
  }
}
