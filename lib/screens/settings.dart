import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/providers/categories.dart';
import 'package:todo_app/widgets/category_item.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Category> categories = ref.watch(categoriesProvider);

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return CategoryItem(
              category: categories[index],
            );
          },
        )
      ],
    );
  }
}
