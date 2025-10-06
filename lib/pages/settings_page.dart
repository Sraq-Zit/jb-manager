import 'package:flutter/material.dart';
import 'package:jbmanager/services/api_service.dart';
import 'package:jbmanager/services/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  final TextEditingController apiUrlController = TextEditingController();

  SettingsPage({super.key});

  Future<bool> _loadSettings() async {
    apiUrlController.text =
        (await SharedPreferences.getInstance()).getString('api_base_url') ??
        defaultBaseUrl;

    return ['to@jbmanager.com', 'dev@jbmanager.com'].contains(
      (await SharedPreferences.getInstance()).getString('last_username'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadSettings(),
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(title: Text('Paramètres')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snapshot.hasData && snapshot.data == true)
                Text('URL de l\'API'),
              if (snapshot.hasData && snapshot.data == true)
                SizedBox(height: 5),
              if (snapshot.hasData && snapshot.data == true)
                TextField(
                  controller: apiUrlController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              SizedBox(height: 20),
              Text('Exercice'),
              SizedBox(height: 5),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '2025',
                ),
                items: [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                  DropdownMenuItem(value: 'Option 3', child: Text('Option 3')),
                ],
                onChanged: null,
              ),
              SizedBox(height: 50),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    SharedPreferences.getInstance().then(
                      (prefs) => prefs.setString(
                        'api_base_url',
                        apiUrlController.text,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Paramètres enregistrés'),
                        backgroundColor: Colors.green.shade400,
                      ),
                    );
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
