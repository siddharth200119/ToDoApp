import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({
    super.key,
    this.firstDay,
    this.focusedDay,
    this.lastDay,
    required this.callback,
  });

  final DateTime? focusedDay;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final Function(DateTime) callback;

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  TimeOfDay? _pickedTime;
  bool isRepeating = false;

  DateTime? result;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay ?? DateTime.now();
    _selectedDay = _focusedDay;
    _firstDay = widget.firstDay ?? DateTime.now();
    _lastDay = widget.lastDay ?? DateTime(3000);
  }

  Future<void> openTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.focusedDay ?? DateTime.now()),
    );

    if (pickedTime != null) {
      setState(() {
        _pickedTime = pickedTime;
      });
    }
  }

  void submit() {
    result = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    if(_pickedTime != null){
      result = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _pickedTime!.hour,
        _pickedTime!.minute,
      );
    }

    widget.callback(result!);
  }

  void togglePicker() {
    setState(() {
      isRepeating = !isRepeating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isRepeating
                  ? const Column(
                      children: [
                        Text("Coming Soon"),
                      ],
                    )
                  : Column(
                      children: [
                        TableCalendar(
                          focusedDay: _focusedDay,
                          firstDay: _firstDay,
                          lastDay: _lastDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal:
                                  BorderSide(width: 1, color: Colors.grey),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: openTimePicker,
                                label: Text(_pickedTime != null
                                    ? _pickedTime!.format(context)
                                    : "Pick Time"),
                                icon: const Icon(Icons.timer),
                              ),
                              TextButton.icon(
                                onPressed: togglePicker,
                                icon: const Icon(Icons.repeat),
                                label: const Text("Repeat"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: submit,
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
