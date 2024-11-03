import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/providers/categories.dart';
import 'package:todo_app/providers/tasks.dart';
import 'package:todo_app/screens/add_category.dart';
import 'package:todo_app/widgets/task_item.dart';

class CategoryItem extends ConsumerStatefulWidget {
  const CategoryItem({super.key, required this.category});

  final Category category;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CategoryItemState();
  }
}

class _CategoryItemState extends ConsumerState<CategoryItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final Category category = widget.category;

    final tasks = ref.watch(tasksProvider).where(
      (t) {
        return t.categories.any((cat) => cat.id == category.id);
      },
    ).toList();

    void editCategory(Category category) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return CRUDCategoryScreen(
              category: category,
            );
          },
        ),
      );
    }

    Future<void> deleteCategory(Category category) {
      return ref
          .read(categoriesProvider.notifier)
          .deleteCategory(category.id)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task Deleted Successfully"),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpanded = isExpanded;
        });
      },
      elevation: 1,
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Trigger edit functionality for this category
                          editCategory(category);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Trigger delete functionality for this category
                          deleteCategory(category);
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          },
          body: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              return TaskItem(task: tasks[index]);
            },
          ),
          isExpanded: _isExpanded,
        )
      ],
    );
  }
}
