import 'package:flutter/material.dart';
import 'package:todo_list/service/category_actions.dart';

Future<String?> showCreateCategoryBox(
  BuildContext context,
  CategoryActions categoryActions,
) async {
  final controller = TextEditingController();

  final categoryName = await showDialog<String>(
    context: context,
    builder: (context) {
      String? errorMessage;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Category'),

            content: TextField(
              controller: controller,

              decoration: InputDecoration(
                hintText: 'Category name',

                errorText: errorMessage,
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text('CANCEL'),
              ),

              TextButton(
                onPressed: () async {
                  final name = controller.text.trim();

                  if (name.isEmpty) {
                    return;
                  }

                  final navigator = Navigator.of(context);

                  final created =
                      await categoryActions.createCategory(name);

                  if (!context.mounted) return;

                  if (!created) {
                    setState(() {
                      errorMessage = 'Category already exists.';
                    });

                    return;
                  }

                  navigator.pop(name);
                },

                child: const Text('CREATE'),
              ),
            ],
          );
        },
      );
    },
  );

  controller.dispose();

  return categoryName;
}