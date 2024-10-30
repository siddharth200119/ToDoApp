import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/providers/categories.dart';

class CRUDCategoryScreen extends StatefulWidget {
  final Category? category;

  const CRUDCategoryScreen({super.key, this.category});

  @override
  _CRUDCategoryScreenState createState() => _CRUDCategoryScreenState();
}

class _CRUDCategoryScreenState extends State<CRUDCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  Color currentColor = Colors.lightBlueAccent;
  bool isFav = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _titleController.text = widget.category!.name;
      currentColor = widget.category!.color ?? Colors.lightBlueAccent;
      isFav = widget.category!.isFav;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          Future<void> saveCategory() async {
            if (_formKey.currentState?.validate() ?? false) {
              final name = _titleController.text.trim();

              if (widget.category == null) {
                await ref.read(categoriesProvider.notifier).addCategory(
                      name,
                      currentColor,
                      isFav,
                    );
              } else {
                await ref.read(categoriesProvider.notifier).editCategory(
                      widget.category!.id,
                      name,
                      currentColor,
                      isFav,
                    );
              }

              Navigator.of(context).pop();
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Color Picker
                    const Text("Pick a Color"),
                    ColorPicker(
                      pickerColor: currentColor,
                      onColorChanged: (Color color) {
                        setState(() {
                          currentColor = color;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Favorite Toggle
                    CheckboxListTile(
                      title: const Text("Favorite"),
                      value: isFav,
                      onChanged: (value) {
                        setState(() {
                          isFav = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () => saveCategory(),
                        child: Text(widget.category == null
                            ? 'Add Category'
                            : 'Update Category'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
