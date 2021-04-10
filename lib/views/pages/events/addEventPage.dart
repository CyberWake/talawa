//flutter packages
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/services/Queries.dart';

//pages are called here
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/apiFunctions.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:intl/intl.dart';
import 'package:talawa/views/pages/events/events.dart';

class AddEvent extends StatefulWidget {
  AddEvent({Key key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  bool _validateTitle = false,
      _validateDescription = false,
      _validateLocation = false;
  ApiFunctions apiFunctions = ApiFunctions();

  Map switchValues = {
    "0": true,
    '1': true,
    '2': true,
    '3': false
  };
  var recurrenceList = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
  String recurrence = 'DAILY';
  Preferences preferences = Preferences();
  void initState() {
    super.initState();
  }

  //getting the date for the event
  DateTimeRange dateRange = DateTimeRange(
      start: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 1, 0),
      end: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, 1, 0));

  //storing the start time of an event
  Map<String, DateTime> startEndTimes = {
    'Start Time': DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
    'End Time': DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  };

  //method to be called when the user wants to select the date
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

  //method to be called when the user wants to select time
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

  //method used to create an event
  Future<void> createEvent() async {
    DateTime startTime = DateTime(
        dateRange.start.year,
        dateRange.start.month,
        dateRange.start.day,
        startEndTimes['Start Time'].hour,
        startEndTimes['Start Time'].minute);
    DateTime endTime = DateTime(
        dateRange.end.year,
        dateRange.end.month,
        dateRange.end.day,
        startEndTimes['End Time'].hour,
        startEndTimes['End Time'].minute);

    if (switchValues['All Day']) {
      startEndTimes = {
        'Start Time': DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 12, 0),
        'End Time': DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 23, 59),
      };
    }
    final String currentOrgID = await preferences.getCurrentOrgId();
    String mutation = Queries().addEvent(
      organizationId: currentOrgID,
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      isPublic: switchValues['Make Public'],
      isRegisterable: switchValues['Make Registerable'],
      recurring: switchValues['Recurring'],
      allDay: switchValues['All Day'],
      recurrance: recurrence,
      startTime: startTime.microsecondsSinceEpoch.toString(),
      endTime: endTime.microsecondsSinceEpoch.toString(),
    );
    Map result = await apiFunctions.gqlquery(mutation);
    print('Result is : $result');
  }

  //main build starts from here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).titleNewEvent,
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

  //widget to get the date button
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

  //widget to get the time button
  Widget timeButton(String name, DateTime time) {
    return AbsorbPointer(
        absorbing: switchValues['3'],
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
                color: !switchValues['3']
                    ? UIData.secondaryColor
                    : Colors.grey),
          ),
        ));
  }

  //widget to add the event
  Widget addEventFab() {
    return FloatingActionButton(
      heroTag: 'addEventFab',
        backgroundColor: UIData.secondaryColor,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
        onPressed: () {
          if(titleController.text.isEmpty || descriptionController.text.isEmpty || locationController.text.isEmpty){
            if (titleController.text.isEmpty){
              setState(() {
                _validateTitle = true;
              });
            }
            if(descriptionController.text.isEmpty){
              setState(() {
                _validateDescription = true;
              });
            }
            if(locationController.text.isEmpty){
              setState(() {
                _validateLocation = true;
              });
            }
            Fluttertoast.showToast(msg: 'Fill in the empty fields', backgroundColor: Colors.grey[500]);
          }else {
            createEvent();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Events()), (route) => false);
          }
        });
  }

  Widget inputField(String name, TextEditingController controller) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          maxLines: name == 'Description' ? null : 1,
          controller: controller,
          decoration: InputDecoration(
              errorText: name == 'Title'
                  ? _validateTitle
                      ? 'Field Can\'t Be Empty'
                      : null
                  : name == 'Description'
                      ? _validateDescription
                          ? 'Field Can\'t Be Empty'
                          : null
                      : name == 'Location'
                          ? _validateLocation
                              ? 'Field Can\'t Be Empty'
                              : null
                          : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.teal)),
              hintText: name),
        ));
  }

  Widget switchTile(String name,String index) {
    return SwitchListTile(
        activeColor: UIData.secondaryColor,
        value: switchValues[index],
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          name,
          style: TextStyle(color: Colors.grey[600]),
        ),
        onChanged: (val) {
          setState(() {
            switchValues[index] = val;
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
        absorbing: !switchValues['2'],
        child: DropdownButton<String>(
          style: TextStyle(
              color: switchValues['2']
                  ? UIData.secondaryColor
                  : Colors.grey),
          value: recurrence,
          icon: Icon(Icons.arrow_drop_down),
          onChanged: (String newValue) {
            setState(() {
              recurrence = newValue;
            });
          },
          items: recurrenceList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
