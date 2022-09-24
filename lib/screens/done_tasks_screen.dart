import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../widgets.dart';

class DoneTaskScreen extends StatelessWidget {
  const DoneTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = AppCubit.get(context);
    return Scaffold(
      body: BlocConsumer<AppCubit, AppState>(
        builder: (context, state) =>
            buildListConditionally(cubit.doneTasks, context),
        listener: (context, state) {},
      ),
    );
  }
}
