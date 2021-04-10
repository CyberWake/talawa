
//flutter packages are called here
import 'package:flutter/material.dart';
import 'package:talawa/generated/l10n.dart';

//pages are called here
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class EditEvent extends StatefulWidget {
  Map event;
  EditEvent({Key key, @required this.event}) : super(key: key);

  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  DateTimeRange dateRange = DateTimeRange(
      start: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 1, 0),
      end: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, 1, 0));

  Map<String, DateTime> startEndTimes = {
    'Start Time': DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
    'End Time': DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  };

  Map event;
  Map switchVals = {
    "0": true,
    '1': true,
    '2': true,
    '3': false
  };

  var recurranceList = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
  String recurrance = 'DAILY';
  Preferences preferences = Preferences();
  String currentOrgId;

  void initState() {
    super.initState();
    getCurrentOrgId();
    print(widget.event);
    initevent();
  }

  initevent() {
    setState(() {
      titleController.text = widget.event['title'];
      descriptionController.text = widget.event['description'];
      switchVals = {
        '0': widget.event['isPublic'],
        '1': widget.event['isRegisterable'],
        '2': widget.event['recurring'],
        '3': widget.event['allDay']
      };
      recurrance = widget.event['recurrance'];
    });
  }


  //getting current organization id
  getCurrentOrgId() async {
    final orgId = await preferences.getCurrentOrgId();
    setState(() {
      currentOrgId = orgId;
    });
    print(currentOrgId);
  }


  //method called to select the date
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTimeRange picked = await showDateRangePicker(
        context: context,
        // initialDate: selectedDate,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(2101));
    if (picked != null && picked != dateRange)
      setState(() {
        dateRange = picked;
      });
  }


  //method to select the time
  Future<void> _selectTime(
      BuildContext context, String name, TimeOfDay time) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (picked != null && picked != time)
      setState(() {
        startEndTimes[name] = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            picked.hour,
            picked.minute);
      });
  }


  //method used to create and event
  Future<void> createEvent() async {
    final String currentOrgID = await preferences.getCurrentOrgId();

    DateTime startTime = DateTime(
        dateRange.start.year,
        dateRange.start.month,
        dateRange.start.day,
        startEndTimes['End Time'].hour,
        startEndTimes['End Time'].minute);
    DateTime endTime = DateTime(
        dateRange.start.year,
        dateRange.start.month,
        dateRange.start.day,
        startEndTimes['Start Time'].hour,
        startEndTimes['Start Time'].minute);

    if (switchVals['3']) {
      startEndTimes = {
        'Start Time': DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 12, 0),
        'End Time': DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 23, 59),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).textEditEvent,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 100),
        children: <Widget>[
          inputField(S.of(context).labelTitle, titleController),
          inputField(S.of(context).labelDescription, descriptionController),
          inputField(S.of(context).labelLocation, locationController),
          switchTile(S.of(context).labelMakePublic,"0"),
          switchTile(S.of(context).labelMakeRegistrable,"1"),
          switchTile(S.of(context).labelRecurring,"2"),
          switchTile(S.of(context).labelAllDay,"3"),
          recurrencedropdown(),
          dateButton(),
          timeButton(S.of(context).labelStartTime, startEndTimes['Start Time']),
          timeButton(S.of(context).labelEndTime, startEndTimes['End Time']),
        ],
      ),
      floatingActionButton: addEventFab(),
    );
  }


  //widget for the date buttons
  Widget dateButton() {
    return ListTile(
      onTap: () {
        _selectDate(context);
      },
      leading: Text(
        S.of(context).labelDate,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
      trailing: Text(
        '${DateFormat.yMMMd().format(dateRange.start)} | ${DateFormat.yMMMd().format(dateRange.end)} ',
        style: TextStyle(fontSize: 16, color: UIData.secondaryColor),
      ),
    );
  }


  //widget for time buttons
  Widget timeButton(String name, DateTime time) {
    return AbsorbPointer(
        absorbing: switchVals['3'],
        child: ListTile(
          onTap: () {
            _selectTime(context, name, TimeOfDay.fromDateTime(time));
          },
          leading: Text(
            name,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          trailing: Text(
            TimeOfDay.fromDateTime(time).format(context),
            style: TextStyle(
                color: !switchVals['3']
                    ? UIData.secondaryColor
                    : Colors.grey),
          ),
        ));
  }


  //widget for the input field
  Widget inputField(String name, TextEditingController controller) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          maxLines: name == S.of(context).labelDescription ? null : 1,
          controller: controller,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.teal)),
              hintText: name),
        ));
  }

  Widget switchTile(String name,String index) {
    return SwitchListTile(
        activeColor: UIData.secondaryColor,
        value: switchVals[index],
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          name,
          style: TextStyle(color: Colors.grey[600]),
        ),
        onChanged: (val) {
          setState(() {
            switchVals[index] = val;
          });
        });
  }

  Widget recurrencedropdown() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      leading: Text(
        S.of(context).labelRecurrence,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
      trailing: AbsorbPointer(
        absorbing: !switchVals['2'],
        child: DropdownButton<String>(
          style: TextStyle(
              color: switchVals['2']
                  ? UIData.secondaryColor
                  : Colors.grey),
          value: recurrance,
          icon: Icon(Icons.arrow_drop_down),
          onChanged: (String newValue) {
            setState(() {
              recurrance = newValue;
            });
          },
          items: recurranceList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }


  //widget to add the event
  Widget addEventFab() {
    return FloatingActionButton(
      heroTag: 'addEventFAB',
        backgroundColor: UIData.secondaryColor,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
        onPressed: () {
          createEvent();
          Navigator.of(context).pop();
        });
  }
}
