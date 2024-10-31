import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/tasks.dart';
import 'package:todo_app/widgets/category_picker.dart';
import 'package:todo_app/widgets/date_time_picker.dart';
import 'package:intl/intl.dart';

class AddTask extends ConsumerStatefulWidget {
  const AddTask({super.key, required this.formKey, this.task});
  final GlobalKey<FormState> formKey;
  final Task? task;

  @override
  ConsumerState<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends ConsumerState<AddTask> {
  DateTime? selectedDate;
  List<Category>? categories;

  @override
  void initState() {
    super.initState();
    // Prefill values if the task is provided
    if (widget.task != null) {
      selectedDate = widget.task?.dueDate;
      categories = widget.task?.categories;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> result = {
      "title": '',
      "description": '',
      "dueDate": null,
      "categories": null,
    };

    void submit() {
      final isValid = widget.formKey.currentState!.validate();
      if (!isValid) {
        return;
      }
      widget.formKey.currentState!.save();
      result["dueDate"] = selectedDate;
      result["categories"] = categories;
      if(widget.task == null){
        ref.read(tasksProvider.notifier).addTask(result);
      }else{
        ref.read(tasksProvider.notifier).updateTask(widget.task!, result);
      }
      Navigator.of(context).pop();
    }

    void selectDate() async {
      DateTime? newSelectedDate = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DateTimePicker(
            focusedDay: selectedDate ?? DateTime.now(),
            callback: (datetime) {
              Navigator.of(context).pop(datetime);
            },
          );
        },
      );

      if (newSelectedDate != null) {
        setState(() {
          selectedDate = newSelectedDate;
        });
      }
    }

    void selectCategory() async {
      List<Category>? newCategories = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CategoryPicker(
            selectedCategories: categories,
            callback: (categories) {
              Navigator.of(context).pop(categories);
            },
          );
        },
      );
      if (newCategories != null) {
        setState(() {
          categories = newCategories;
        });
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.task == null ? 'Add New Task' : "Update Task",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Form(
            key: widget.formKey,
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Take the dog for a walk",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(0),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a valid title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    result["title"] = value;
                  },
                  initialValue: widget.task?.title,  // Prefill title
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Description",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(0),
                  ),
                  validator: (value) {
                    return null;
                  },
                  onSaved: (value) {
                    result["description"] = value;
                  },
                  initialValue: widget.task?.desc,  // Prefill description
                ),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.start,
                    children: [
                      // Date Chip
                      if (selectedDate != null)
                        Chip(
                          label: Text(
                            "Due: ${DateFormat('dd-MM hh:mm a').format(selectedDate!)}",
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedDate = null;
                            });
                          },
                        ),
                  
                      // Categories Chips
                      if (categories != null && categories!.isNotEmpty)
                        ...categories!.map((category) {
                          return Chip(
                            label: Text(category.name),
                            onDeleted: () {
                              setState(() {
                                categories!.remove(category);
                              });
                            },
                          );
                        }),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: selectDate,
                          icon: const Icon(Icons.timer),
                        ),
                        IconButton(
                          onPressed: selectCategory,
                          icon: const Icon(Icons.category),
                        )
                      ],
                    ),
                    IconButton(
                      onPressed: submit,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
