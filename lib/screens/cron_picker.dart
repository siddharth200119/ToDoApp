import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum EndType { never, on, after }

enum EveryType { day, week, month, year }

enum DayofWeek { sun, mon, tue, wed, thu, fri, sat }

class CronPicker extends StatefulWidget {
  const CronPicker({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CronPickerState();
  }
}

class _CronPickerState extends State<CronPicker> {
  @override
  void initState() {
    super.initState();
    _occurenceCon = TextEditingController(text: "10");
    _everyNumCon = TextEditingController(text: "1");
  }

  @override
  void dispose() {
    _occurenceCon.dispose();
    _everyNumCon.dispose();
    super.dispose();
  }

  EndType? _endAt = EndType.never;
  DateTime _endDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  late TextEditingController _occurenceCon;
  late TextEditingController _everyNumCon;
  EveryType _selectedType = EveryType.day;
  TimeOfDay? _everySelectedTime;
  final List<DayofWeek> _selectedDaysOfWeek = [];
  final Map<String, DayofWeek> _daysOfWeek = {
    "Sun": DayofWeek.sun,
    "Mon": DayofWeek.mon,
    "Tue": DayofWeek.tue,
    "Wed": DayofWeek.wed,
    "Thu": DayofWeek.thu,
    "Fri": DayofWeek.fri,
    "Sat": DayofWeek.sat
  };

  // Function to create cron expression based on user inputs
  String _generateCronExpression() {
    String minute = '0';
    String hour = '0';
    String day = '*';
    String month = '*';
    String weekday = '*';

    if (_everySelectedTime != null) {
      minute = _everySelectedTime!.minute.toString();
      hour = _everySelectedTime!.hour.toString();
    }

    switch (_selectedType) {
      case EveryType.day:
        day = '*/${_everyNumCon.text}';
        break;
      case EveryType.week:
        day = '*';
        weekday = _selectedDaysOfWeek.map((d) => d.index.toString()).join(',');
        break;
      case EveryType.month:
        day = '1';
        month = '*/${_everyNumCon.text}';
        break;
      case EveryType.year:
        day = '1';
        month = '1';
        break;
    }

    return '$minute $hour $day $month $weekday';
  }

  void _onDonePressed() {
    // Generating cron string
    String cronString = _generateCronExpression();

    // Creating a map of start time, end time, and cron string
    final result = {
      'start_time': _startDate,
      'end_time': _endAt == EndType.on
          ? _endDate
          : (_endAt == EndType.after
              ? _occurenceCon.text
              : null),
      'cron_string': cronString,
    };
    print("sidd $result");
    // Pop the result back to the previous screen
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    int? everyNum;
    try {
      everyNum = int.parse(_everyNumCon.text);
    } catch (e) {
      everyNum = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Repeat Picker"),
        actions: [
          TextButton(
            onPressed: _onDonePressed,
            child: const Text(
              "Done",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 10, 28, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Text(
                          "Every",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: Center(
                              child: TextField(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 0,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                controller: _everyNumCon,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton(
                                value: _selectedType,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                underline: Container(),
                                onChanged: (EveryType? newValue) {
                                  setState(() {
                                    _selectedType = newValue!;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<EveryType>(
                                    value: EveryType.day,
                                    child: Text(everyNum > 1 ? "Days" : "Day"),
                                  ),
                                  DropdownMenuItem<EveryType>(
                                    value: EveryType.week,
                                    child:
                                        Text(everyNum > 1 ? "Weeks" : "Week"),
                                  ),
                                  DropdownMenuItem<EveryType>(
                                    value: EveryType.month,
                                    child:
                                        Text(everyNum > 1 ? "Months" : "Month"),
                                  ),
                                  DropdownMenuItem<EveryType>(
                                    value: EveryType.year,
                                    child:
                                        Text(everyNum > 1 ? "Years" : "Year"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      _selectedType == EveryType.week
                          ? Container(
                              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: _daysOfWeek.entries.map((entry) {
                                  final day = entry.key;
                                  final value = entry.value;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedDaysOfWeek
                                            .contains(value)) {
                                          _selectedDaysOfWeek.remove(value);
                                        } else {
                                          _selectedDaysOfWeek.add(value);
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          color: _selectedDaysOfWeek
                                                  .contains(value)
                                              ? Colors.grey
                                              : Colors.transparent),
                                      child: Center(
                                        child: Text(day),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : Container(),
                      InkWell(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              DateTime.now(),
                            ),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              _everySelectedTime = pickedTime;
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _everySelectedTime != null
                                  ? _everySelectedTime!.format(context)
                                  : "Select Time",
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.onSecondary,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        "Start At",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    ListTile(
                      title: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                DateTime? startDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(7000),
                                  initialDate: _startDate,
                                );
                                if (startDate != null) {
                                  setState(() {
                                    _startDate = startDate;
                                  });
                                }
                              },
                              child: Container(
                                height: 40,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(6),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('dd MM yyyy').format(_startDate),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.onSecondary,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        "End At",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    ListTile(
                      title: const Text("Never"),
                      leading: Radio(
                        value: EndType.never,
                        groupValue: _endAt,
                        onChanged: (EndType? endAt) {
                          setState(() {
                            _endAt = endAt;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          const Text("On"),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                DateTime? endDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(7000),
                                  initialDate: DateTime.now(),
                                );
                                if (endDate != null) {
                                  setState(() {
                                    _endDate = endDate;
                                  });
                                }
                              },
                              child: Container(
                                height: 40,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(6),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('dd MM yyyy').format(_endDate),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      leading: Radio(
                        value: EndType.on,
                        groupValue: _endAt,
                        onChanged: (EndType? endAt) {
                          setState(() {
                            _endAt = endAt;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          const Text("After"),
                          Container(
                            height: 40,
                            width: 40,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Center(
                              child: TextField(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                controller: _occurenceCon,
                              ),
                            ),
                          ),
                          const Text("occurences")
                        ],
                      ),
                      leading: Radio(
                        value: EndType.after,
                        groupValue: _endAt,
                        onChanged: (EndType? endAt) {
                          setState(() {
                            _endAt = endAt;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
