import 'package:flutter/material.dart';
import './cubit/cubit.dart';

Widget buildDefaultTextFormField(
    {required TextEditingController controller,
    required String? Function(String? value)? validator,
    bool isPassword = false,
    bool isEnable = true,
    void Function()? onTap,
    required String labelText,
    TextInputType keyBoardType = TextInputType.text,
    Widget? suffixIcon,
    Widget? prefixIcon}) {
  return TextFormField(
    enabled: isEnable,
    onTap: onTap,
    controller: controller,
    validator: validator,
    obscureText: isPassword,
    keyboardType: keyBoardType,
    decoration: InputDecoration(
      label: Text(labelText),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(),
    ),
  );
}

Widget defaultButton(
    {required void Function()? onPressed,
    required String buttonTitle,
    Color buttonTextColor = Colors.white,
    Color color = Colors.lightBlue,
    double width = double.infinity}) {
  return Container(
    color: color,
    width: width,
    child: MaterialButton(
      onPressed: onPressed,
      child: Text(
        buttonTitle,
        style: TextStyle(color: buttonTextColor),
      ),
    ),
  );
}

Widget buildTaskContainer({required Map model, required BuildContext context}) {
  return Dismissible(
    background: Container(
      color: Colors.red,
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.delete, color: Colors.white),
          Icon(Icons.delete, color: Colors.white),
        ],
      ),
    ),
    onDismissed: (direction) async {
      if (direction == DismissDirection.endToStart ||
          direction == DismissDirection.startToEnd) {
        await AppCubit.get(context).deleteTaskFromDb(taskId: model['id']);
      }
    },
    key: ValueKey(model['id']),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            child: Text(
              model['time'],
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model['title'],
                  maxLines: 2,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  model['date'],
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                )
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {
              AppCubit.get(context)
                  .updateStatus(taskId: model['id'], status: 'done');
            },
            icon: Icon(Icons.check_circle, color: Colors.green),
          ),
          SizedBox(
            width: 5,
          ),
          IconButton(
            onPressed: () {
              AppCubit.get(context)
                  .updateStatus(taskId: model['id'], status: 'archived');
            },
            icon: Icon(Icons.archive, color: Colors.grey),
          )
        ],
      ),
    ),
  );
}

Widget buildListConditionally(List<Map> tasks, BuildContext context) {
  return tasks.isNotEmpty
      ? ListView.separated(
          itemBuilder: (ctx, index) {
            return buildTaskContainer(model: tasks[index], context: context);
          },
          separatorBuilder: (ctx, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey,
              ),
            );
          },
          itemCount: tasks.length)
      : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'opps!.... no tasks to show please add some',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Icon(
                Icons.add_task,
                color: Colors.grey,
                size: 40,
              )
            ],
          ),
        );
}
