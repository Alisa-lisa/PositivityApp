import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:positivityapp/controllers/fetcher.dart';

class LoginForm extends StatefulWidget {
  final http.Client client;
  final String deviceId;
  final Future<void> Function() onDone;

  const LoginForm({
    super.key,
    required this.client,
    required this.deviceId,
    required this.onDone,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String _ageGroup = "one";
  String _gender = "f";
  int _availableTime = 0;
  bool _therapy = false;

  final _expectationsController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _expectationsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await login(
        widget.client,
        widget.deviceId,
        _ageGroup,
        _gender,
        _availableTime,
        _therapy,
        _expectationsController.text.trim(),
      );

      if (!mounted) return;
      await widget.onDone();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Login failed: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _ageGroup,
                decoration: const InputDecoration(
                  labelText: "Age group",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "one", child: Text("25-29")),
                  DropdownMenuItem(value: "two", child: Text("30-35")),
                  DropdownMenuItem(value: "three", child: Text("36-40")),
                  DropdownMenuItem(value: "four", child: Text("41-47")),
                  DropdownMenuItem(value: "five", child: Text("48+")),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _ageGroup = v);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "f", child: Text("Female")),
                  DropdownMenuItem(value: "m", child: Text("Male")),
                  DropdownMenuItem(value: "o", child: Text("Other")),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _gender = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: "0",
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Available time",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? "");
                  if (parsed == null) return "Enter a number";
                  if (parsed < 0) return "Must be 0 or more";
                  return null;
                },
                onChanged: (value) {
                  _availableTime = int.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Therapy"),
                value: _therapy,
                onChanged: (v) => setState(() => _therapy = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expectationsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Expectations",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your expectations";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Start app"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

