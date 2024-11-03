import 'package:flutter/material.dart';
import 'package:todo_app/providers/categories.dart';
import 'package:todo_app/screens/settings.dart';
import 'package:todo_app/screens/tasks_list.dart';
import 'package:todo_app/widgets/add_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/tasks.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedOption = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> screens = [
    {
      "title": "Today",
      "home": TasksList(
        maxDateFilter: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 23, 59, 59),
        minDateFilter: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 00, 00, 00),
      ),
      "icon": const Icon(Icons.calendar_today_rounded),
      "label": "Today"
    },
    {
      "title": "All Tasks",
      "home": const TasksList(),
      "icon": const Icon(Icons.checklist_rounded),
      "label": "To Do"
    },
    {
      "title": "Settings",
      "home": const SettingsScreen(),
      "icon": const Icon(Icons.menu),
      "label": "Browse"
    }
  ];
  late Map<String, dynamic> _currentTask;

  Future<void> _fetchTasks() async {
    await ref.read(tasksProvider.notifier).fetchTasks();
  }

  Future<void> _fetchCategories() async {
    await ref.read(categoriesProvider.notifier).fetchCategories();
  }

  @override
  void initState() {
    super.initState();
    _currentTask = screens[0];
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_fetchCategories(), _fetchTasks()]);
    setState(() {
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedOption = index;
      _currentTask = screens[index];
    });
  }

  void _showTaskInputPopup() {
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return AddTask(formKey: formKey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTask["title"]),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentTask["home"],
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: _showTaskInputPopup,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: screens.map((Map<String, dynamic> map) {
          return BottomNavigationBarItem(
              icon: map["icon"], label: map["label"]);
        }).toList(),
        currentIndex: _selectedOption,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
