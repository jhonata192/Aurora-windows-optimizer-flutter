import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(AuroraApp());
}

class AuroraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora, Windows Optimizer™',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Aurora, Windows Optimizer™'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _commands = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _cmdController = TextEditingController();
  String _selectedType = 'CMD';

  @override
  void initState() {
    super.initState();
    _loadCommands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _checkUpdates,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _commands.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_commands[index]['name']),
            subtitle: Text(_commands[index]['desc']),
            onTap: () {
              _runCommand(_commands[index]['cmd'], _commands[index]['type']);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommandDialog,
        tooltip: 'Add Command',
        child: Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Aurora Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Open GitHub Repository'),
              onTap: _openGitHubRepo,
            ),
            ListTile(
              title: Text('Download Latest Version from GitHub'),
              onTap: _downloadLatestVersion,
            ),
            ListTile(
              title: Text('Create Restore Point'),
              onTap: _createRestorePoint,
            ),
            ListTile(
              title: Text('Restore Changes'),
              onTap: _restoreChanges,
            ),
          ],
        ),
      ),
    );
  }

  void _loadCommands() {
    // Load commands from a file or any other data source
    // For this example, we'll initialize with some dummy data
    _commands = [
      {"name": "Command 1", "desc": "Description 1", "cmd": "echo Command 1 executed", "type": "CMD"},
      {"name": "Command 2", "desc": "Description 2", "cmd": "echo Command 2 executed", "type": "CMD"},
    ];
  }

  void _showAddCommandDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Command'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _cmdController,
                  decoration: InputDecoration(labelText: 'Command'),
                ),
                DropdownButton<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                  items: <String>['CMD', 'Powershell']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addCommand();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addCommand() {
    setState(() {
      _commands.add({
        "name": _nameController.text,
        "desc": _descController.text,
        "cmd": _cmdController.text,
        "type": _selectedType,
      });
      _nameController.clear();
      _descController.clear();
      _cmdController.clear();
      _selectedType = 'CMD';
    });
  }

  void _runCommand(String command, String type) async {
    ProcessResult result;
    try {
      if (type.toUpperCase() == 'CMD') {
        result = await Process.run('cmd', ['/c', command]);
      } else if (type.toUpperCase() == 'POWERSHELL') {
        result = await Process.run('powershell', ['-Command', command]);
      } else {
        print('Unsupported command type: $type');
        return;
      }

      if (result.exitCode == 0) {
        _showOutputDialog(result.stdout.toString());
      } else {
        _showOutputDialog(result.stderr.toString());
      }
    } catch (e) {
      print('Error executing command: $e');
      _showOutputDialog('An unexpected error occurred');
    }
  }

  void _showOutputDialog(String output) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Command Result'),
          content: SingleChildScrollView(
            child: Text(output),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openGitHubRepo() async {
    const url = 'https://github.com/azurejoga/Aurora-Windows-Optimizer';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _downloadLatestVersion() async {
    const url = 'https://github.com/azurejoga/Aurora-Windows-Optimizer/releases';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _createRestorePoint() async {
    String description = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Restore Point'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Description'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Create restore point using description
  }

  void _restoreChanges() {
    // Restore system changes
  }

  void _checkUpdates() async {
    // Check for updates on GitHub repository
    // Display dialog with update information if available
  }
}
