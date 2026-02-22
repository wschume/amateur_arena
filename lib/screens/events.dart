import "package:amateur_arena/models/event.dart";
import "package:amateur_arena/models/user.dart";
import "package:amateur_arena/services/database.dart";
import "package:data_table_2/data_table_2.dart";
import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import "package:intl/intl.dart";
import "package:provider/provider.dart";

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AmateurArenaUser?>(context);

    return Column(
      children: [
        _buildHeader(context, user),
        const SizedBox(height: 12.0),
        Expanded(child: _buildEventsStream(user, theme)),
      ],
    );
  }

  Widget _buildEventsStream(AmateurArenaUser? user, ThemeData theme) {
    return StreamBuilder<List<Event>>(
      stream: DatabaseService().events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];
        return _buildEventsTable(context, events, user, theme);
      },
    );
  }

  Widget _buildEventsTable(
    BuildContext context,
    List<Event> events,
    AmateurArenaUser? user,
    ThemeData theme,
  ) {
    final showActions = user != null;
    return DataTable2(
      headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary),
      headingTextStyle: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      ),
      dividerThickness: 1,
      checkboxHorizontalMargin: 4,
      horizontalMargin: 4,
      columnSpacing: 4,
      columns: [
        if (showActions)
          const DataColumn2(label: Text("Actions"), fixedWidth: 100),
        const DataColumn2(label: Text("Date")),
        const DataColumn2(label: Text("Location")),
        const DataColumn2(label: Text("Deadline")),
        const DataColumn2(label: Text("Club")),
        const DataColumn2(label: Text("Contact"), size: ColumnSize.L),
        const DataColumn2(label: Text("Looking for\nPlayers")),
      ],
      rows: events
          .map((event) => _buildDataRow(context, event, user, theme))
          .toList(),
    );
  }

  Widget _buildHeader(BuildContext context, AmateurArenaUser? user) {
    return Row(
      children: [
        ElevatedButton(
          child: const Text("Add event"),
          onPressed: () {
            if (user == null) {
              context.go("/login");
            } else {
              _showAddEventDialog(context, user);
            }
          },
        ),
      ],
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    Event event,
    AmateurArenaUser? user,
    ThemeData theme,
  ) {
    final isOwner = user?.uid == event.ownerId;
    final showActions = user != null;
    return DataRow(
      color: WidgetStateProperty.resolveWith(
        (states) =>
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      cells: [
        if (showActions) DataCell(_buildActions(context, event, isOwner)),
        DataCell(
          Text(
            "${DateFormat('yyyy-MM-dd HH:mm').format(event.startDate)} - ${DateFormat('HH:mm').format(event.endDate)}",
          ),
        ),
        DataCell(Text(event.location)),
        DataCell(Text(DateFormat('yyyy-MM-dd').format(event.deadline))),
        DataCell(Text(event.club)),
        DataCell(Text(event.contact)),
        DataCell(Text(event.lookingForPlayers ? "YES" : "NO")),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Event event, bool isOwner) {
    if (!isOwner) return const SizedBox.shrink();

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _showEditEventDialog(context, event),
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: () => _confirmDelete(context, event),
        ),
      ],
    );
  }

  Future<void> _showAddEventDialog(
    BuildContext context,
    AmateurArenaUser user,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create Event"),
        content: EventForm(
          ownerId: user.uid,
          onSave: (event) async {
            await DatabaseService().addEvent(event);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _showEditEventDialog(BuildContext context, Event event) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Event"),
        content: EventForm(
          ownerId: event.ownerId,
          initialEvent: event,
          onSave: (updatedEvent) async {
            await DatabaseService().updateEvent(updatedEvent);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && event.id != null) {
      await DatabaseService().deleteEvent(event.id!);
    }
  }
}

class EventForm extends StatefulWidget {
  final String ownerId;
  final Function(Event) onSave;
  final Event? initialEvent;

  const EventForm({
    super.key,
    required this.ownerId,
    required this.onSave,
    this.initialEvent,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Date fields
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _deadlineController;

  // Storage for field values
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _deadline;
  String _location = '';
  String _club = '';
  String _contact = '';
  bool _lookingForPlayers = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialEvent?.startDate ?? DateTime.now();
    _endDate =
        widget.initialEvent?.endDate ??
        DateTime.now().add(const Duration(hours: 2));
    _deadline = widget.initialEvent?.deadline ?? DateTime.now();
    _lookingForPlayers = widget.initialEvent?.lookingForPlayers ?? false;

    _startDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm').format(_startDate),
    );
    _endDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm').format(_endDate),
    );
    _deadlineController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_deadline),
    );
  }

  Future<void> _selectDateTime(BuildContext context, String type) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: switch (type) {
        'start' => _startDate,
        'end' => _endDate,
        _ => _deadline,
      },
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (type == 'deadline') {
        setState(() {
          _deadline = pickedDate;
          _deadlineController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(pickedDate);
        });
        return;
      }

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          type == 'start' ? _startDate : _endDate,
        ),
      );

      if (pickedTime != null) {
        final fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (type == 'start') {
            _startDate = fullDateTime;
            _startDateController.text = DateFormat(
              'yyyy-MM-dd HH:mm',
            ).format(fullDateTime);
          } else if (type == 'end') {
            _endDate = fullDateTime;
            _endDateController.text = DateFormat(
              'yyyy-MM-dd HH:mm',
            ).format(fullDateTime);
          }
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newEvent = Event(
        id: widget.initialEvent?.id,
        ownerId: widget.ownerId,
        startDate: _startDate,
        endDate: _endDate,
        location: _location,
        deadline: _deadline,
        club: _club,
        contact: _contact,
        lookingForPlayers: _lookingForPlayers,
      );

      widget.onSave(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(labelText: 'Start Date & Time'),
              readOnly: true,
              onTap: () => _selectDateTime(context, 'start'),
            ),
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(labelText: 'End Date & Time'),
              readOnly: true,
              onTap: () => _selectDateTime(context, 'end'),
            ),
            TextFormField(
              controller: _deadlineController,
              decoration: const InputDecoration(
                labelText: 'Registration Deadline (Date Only)',
              ),
              readOnly: true,
              onTap: () => _selectDateTime(context, 'deadline'),
            ),
            const Divider(),
            TextFormField(
              initialValue: widget.initialEvent?.location,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a location' : null,
              onSaved: (value) => _location = value!,
            ),
            TextFormField(
              initialValue: widget.initialEvent?.club,
              decoration: const InputDecoration(labelText: 'Club Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter club name' : null,
              onSaved: (value) => _club = value!,
            ),
            TextFormField(
              initialValue: widget.initialEvent?.contact,
              decoration: const InputDecoration(labelText: 'Contact Info'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter contact info' : null,
              onSaved: (value) => _contact = value!,
            ),
            SwitchListTile(
              title: const Text('Looking for players'),
              value: _lookingForPlayers,
              onChanged: (bool value) =>
                  setState(() => _lookingForPlayers = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
