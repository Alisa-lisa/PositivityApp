import 'package:flutter/material.dart';
import 'package:positivityapp/controllers/fetcher.dart';
import 'package:http/http.dart' as http;

class WellbeingDialog extends StatefulWidget {
  final http.Client client;
  final String deviceId;
  const WellbeingDialog(
      {super.key, required this.client, required this.deviceId});

  @override
  State<WellbeingDialog> createState() => WellbeingDialogState();
}

class WellbeingDialogState extends State<WellbeingDialog> {
  http.Client get client => widget.client;
  String get deviceId => widget.deviceId;
  // Sliders (store as ints; Slider uses double but we convert).
  int _mood = 5;
  int _stress = 5;
  int _resilience = 5;
  int _lifeSatisfaction = 5;
  int _socialLife = 5;
  int _career = 5;

  // Checkboxes
  bool _negativeEvents = false;
  bool _positiveEvents = false;

  // Feedback text
  late final TextEditingController _feedbackCtrl = TextEditingController();

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily Check-in'),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SliderRow(
              label: 'Mood',
              value: _mood,
              onChanged: (v) => setState(() => _mood = v),
            ),
            _SliderRow(
              label: 'Stress',
              value: _stress,
              onChanged: (v) => setState(() => _stress = v),
            ),
            _SliderRow(
              label: 'Resilience',
              value: _resilience,
              onChanged: (v) => setState(() => _resilience = v),
            ),
            _SliderRow(
              label: 'Life satisfaction',
              value: _lifeSatisfaction,
              onChanged: (v) => setState(() => _lifeSatisfaction = v),
            ),
            _SliderRow(
              label: 'Social life',
              value: _socialLife,
              onChanged: (v) => setState(() => _socialLife = v),
            ),
            _SliderRow(
              label: 'Career',
              value: _career,
              onChanged: (v) => setState(() => _career = v),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Negative events'),
              value: _negativeEvents,
              onChanged: (v) => setState(() => _negativeEvents = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Positive events'),
              value: _positiveEvents,
              onChanged: (v) => setState(() => _positiveEvents = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Feedback',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _feedbackCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your feedback…',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await saveProgress(
                client,
                deviceId,
                _mood,
                _stress,
                _resilience,
                _lifeSatisfaction,
                _socialLife,
                _career,
                _negativeEvents,
                _positiveEvents,
                _feedbackCtrl.text);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// One row = label + discrete 1..10 Slider + numeric value.
class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label),
          ),
          Expanded(
            child: Slider.adaptive(
              value: value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9, // 1..10 inclusive
              label: '$value',
              onChanged: (d) => onChanged(d.round().clamp(1, 10)),
              semanticFormatterCallback: (d) => d.round().toString(),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
