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

Future<void> showManageCategoriesBox(
  BuildContext context,
  CategoryActions categoryActions,
) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Manage Categories'),

        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<String>>(
            stream: categoryActions.readCategories(),

            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return const Text('No categories available.');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,

                children: categories.map((category) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,

                    title: Text(category),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        // EDIT
                        IconButton(
                          onPressed: () async {
                            await showEditCategoryBox(
                              context,
                              categoryActions,
                              category,
                            );
                          },

                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                          ),
                        ),

                        // DELETE
                        IconButton(
                          onPressed: () async {
                            await showDeleteCategoryBox(
                              context,
                              categoryActions,
                              category,
                            );
                          },

                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text('CLOSE'),
          ),
        ],
      );
    },
  );
}

// EDIT CATEGORY
Future<void> showEditCategoryBox(
  BuildContext context,
  CategoryActions categoryActions,
  String currentName,
) async {
  final controller = TextEditingController(
    text: currentName,
  );

  await showDialog(
    context: context,
    builder: (context) {
      String? errorMessage;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Category'),

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
                  final newName = controller.text.trim();

                  if (newName.isEmpty) {
                    return;
                  }

                  final updated =
                      await categoryActions.updateCategory(
                    currentName,
                    newName,
                  );

                  if (!context.mounted) return;

                  if (!updated) {
                    setState(() {
                      errorMessage = 'Category already exists.';
                    });

                    return;
                  }

                  Navigator.pop(context);
                },

                child: const Text('SAVE'),
              ),
            ],
          );
        },
      );
    },
  );

  controller.dispose();
}

Future<void> showDeleteCategoryBox(
  BuildContext context,
  CategoryActions categoryActions,
  String categoryName,
) async {
  final shouldDelete = await showDialog<bool>(
    context: context,

    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Category'),

        content: Text(
          'Are you sure you want to delete "$categoryName"?',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },

            child: const Text('CANCEL'),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },

            child: const Text(
              'DELETE',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    await categoryActions.deleteCategory(categoryName);
  }
}