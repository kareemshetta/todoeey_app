import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../widgets.dart';

class NewTaskScreen extends StatelessWidget {
  const NewTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = AppCubit.get(context);
    return Scaffold(
      body: BlocConsumer<AppCubit, AppState>(
        builder: (context, state) =>
            buildListConditionally(cubit.newTasks, context),
        listener: (context, state) {},
      ),
    );
  }
}

//
// cubit.newTasks.isNotEmpty
// ?
// ListView.separated(
// itemBuilder: (ctx, index) {
// return buildTaskContainer(
// model: cubit.newTasks[index], context: context);
// },
// separatorBuilder: (ctx, index) {
// return Padding(
// padding: const EdgeInsets.only(left: 30),
// child: Container(
// width: double.infinity,
// height: 1,
// color: Colors.grey,
// ),
// );
// },
// itemCount: cubit.newTasks.length)
// : Center(
// child: Text(
// 'opps! no tasks to show please add some',
// style: TextStyle(
// color: Colors.black,
// fontSize: 15,
// ),
// ),
// )
