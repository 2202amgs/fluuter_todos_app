import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';

import 'cubit/cubit.dart';

ConditionalBuilder taskBuilder({
  required List<Map> tasks,
  required BuildContext context,
}) =>
    ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) =>
            listItem(tasks.reversed.toList()[index], context),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
          child: Container(
            width: double.infinity,
            height: 1.0,
            color: Colors.grey[200],
          ),
        ),
        itemCount: tasks.length,
      ),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const Text('No Tasks Yet, Please Add Some Tasks'),
          ],
        ),
      ),
    );

Widget listItem(Map model, BuildContext context) {
  return Dismissible(
    key: Key('$model["id"]'),
    onDismissed: (dir) {
      AppCubit.get(context).deleteTodos(model['id']);
    },
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 35,
            child: Text(model['time']),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model['title'],
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  model['date'],
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {
              AppCubit.get(context).updateTodos('done', model['id']);
            },
            icon: Icon(Icons.check_box),
          ),
          IconButton(
            onPressed: () {
              AppCubit.get(context).updateTodos('archive', model['id']);
            },
            icon: Icon(Icons.archive),
          ),
        ],
      ),
    ),
  );
}
