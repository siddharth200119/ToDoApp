import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/providers/categories.dart';
import 'package:todo_app/screens/add_category.dart';

class CategoryPicker extends ConsumerStatefulWidget {
  const CategoryPicker({super.key, this.selectedCategories, required this.callback});

  final List<Category>? selectedCategories;
  final Function(List<Category>?) callback;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CategoryPickerState();
  }
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSuggestions = false;
  List<Category> suggestions = [];
  late List<Category> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.selectedCategories ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = ref.watch(categoriesProvider);

    void updateSuggestions(String keyword) {
      setState(() {
        if (keyword.isEmpty) {
          _showSuggestions = false;
          suggestions = [];
        } else {
          _showSuggestions = true;
          suggestions = categories
              .where((category) =>
                  category.name.toLowerCase().contains(keyword.toLowerCase()))
              .toList();
        }
      });
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //search category
              TextField(
                controller: _searchController,
                onChanged: (keyword) {
                  updateSuggestions(keyword);
                },
                decoration: const InputDecoration(
                  hintText: 'Search categories',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //sugestions
              _showSuggestions
                  ? SizedBox(
                      height: 100,
                      child: ListView(
                        children: suggestions.map((suggestion) {
                          return ListTile(
                            title: Text(suggestion.name),
                            onTap: () {
                              setState(() {
                                if (!selectedCategories.contains(suggestion)) {
                                  selectedCategories = [suggestion, ...selectedCategories];
                                }
                                _searchController.clear();
                                _showSuggestions = false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              //already picked categories
              Wrap(
                spacing: 8,
                children: (selectedCategories).map((category) {
                  return Chip(
                    label: Text(category.name),
                    onDeleted: () {
                      selectedCategories.remove(category);
                      widget.callback(selectedCategories);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const CRUDCategoryScreen();
                            },
                          ),
                        );
                      });
                    },
                    child: const Text('Add Category'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.callback(selectedCategories);
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
