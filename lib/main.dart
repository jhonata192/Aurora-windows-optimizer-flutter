import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart'; // Certifique-se de que o path para o theme_provider.dart está correto
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: AuroraApp(),
    ),
  );
}

class AuroraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Aurora, Windows Optimizer™',
          theme: themeProvider.themeData,
          home: MyHomePage(title: 'Aurora, Windows Optimizer™'),
        );
      },
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
          Semantics(
            label: 'Abrir menu de navegação',
            child: IconButton(
              icon: Icon(Icons.menu),
              tooltip: 'abrir menu de navegação',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _commands.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildCommandTile(index);
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Hero(
              tag: 'drawerHeader',
              child: DrawerHeader(
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
            ),
            ListTile(
              title: Text('Comandos'),
              leading: Icon(Icons.code),
              onTap: () {
                Navigator.pop(context);
                _showCommandsMenu();
              },
              trailing: Semantics(
                label: 'Ir para o menu de comandos',
                child: Icon(Icons.arrow_forward),
              ),
            ),
            ListTile(
              title: Text('Ferramentas'),
              leading: Icon(Icons.build),
              onTap: () {
                Navigator.pop(context);
                _showToolsMenu();
              },
              trailing: Semantics(
                label: 'Ir para o menu de ferramentas',
                child: Icon(Icons.arrow_forward),
              ),
            ),
            ListTile(
              title: Text('Configurações'),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                _showSettingsDialog();
              },
              trailing: Semantics(
                label: 'Ir para o menu de configurações',
                child: Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandTile(int index) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    return GestureDetector(
      onLongPress: () {
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            Rect.fromCenter(center: TapDownDetails().globalPosition, width: 40, height: 40),
            Offset.zero & overlay.size,
          ),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar Comando'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCommandDialog(index);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remover Comando'),
                onTap: () {
                  Navigator.pop(context);
                  _removeCommand(index);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.arrow_upward),
                title: Text('Mover para o topo'),
                onTap: () {
                  Navigator.pop(context);
                  _moveToTop(index);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.arrow_downward),
                title: Text('Mover para o final'),
                onTap: () {
                  Navigator.pop(context);
                  _moveToBottom(index);
                },
              ),
            ),
          ],
        );
      },
      child: ListTile(
        title: Semantics(
          label: 'Nome do Comando',
          child: Text(_commands[index]['name']),
        ),
        subtitle: Semantics(
          label: 'Descrição do Comando',
          child: Text(_commands[index]['desc']),
        ),
        onTap: () {
          _runCommand(_commands[index]['cmd'], _commands[index]['type']);
        },
      ),
    );
  }

  void _loadCommands() {
    _commands = [
      {"name": "Command 1", "desc": "Description 1", "cmd": "echo Command 1 executed", "type": "CMD"},
      {"name": "Command 2", "desc": "Description 2", "cmd": "echo Command 2 executed", "type": "CMD"},
    ];
  }

  void _showCommandsMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Commands Menu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Add Command'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCommandDialog();
                },
              ),
              ListTile(
                title: Text('Exit'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showToolsMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tools Menu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Open GitHub Repository'),
                onTap: () {
                  Navigator.pop(context);
                  _openGitHubRepo();
                },
              ),
              ListTile(
                title: Text('Download Latest Version from GitHub'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadLatestVersion();
                },
              ),
              ListTile(
                title: Text('Create Restore Point'),
                onTap: () {
                  Navigator.pop(context);
                  _createRestorePoint();
                },
              ),
              ListTile(
                title: Text('Restore Changes'),
                onTap: () {
                  Navigator.pop(context);
                  _restoreChanges();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Tema do Aplicativo'),
                onTap: () {
                  Navigator.pop(context);
                  _showThemeDialog();
                },
              ),
              ListTile(
                title: Text('Option 1'),
                onTap: () {
                  Navigator.pop(context);
                  // Action for Option 1
                },
              ),
              ListTile(
                title: Text('Option 2'),
                onTap: () {
                  Navigator.pop(context);
                  // Action for Option 2
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione o Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Tema Claro'),
                onTap: () {
                  _changeTheme(ThemeData.light());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Tema Escuro'),
                onTap: () {
                  _changeTheme(ThemeData.dark());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeTheme(ThemeData theme) {
    Provider.of<ThemeProvider>(context, listen: false).setTheme(theme);
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
        result = await Process.run('powershell', ['-Command', command], runInShell: true);
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

void _createRestorePoint() {
  // Code to create a restore point
}

void _restoreChanges() {
  // Code to restore changes
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
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter command name',
                ),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter command description',
                ),
              ),
              TextField(
                controller: _cmdController,
                decoration: InputDecoration(
                  labelText: 'Command',
                  hintText: 'Enter the command to be executed',
                ),
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
                hint: Text('Select command type'),
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

void _showEditCommandDialog(int index) {
  _nameController.text = _commands[index]['name'];
  _descController.text = _commands[index]['desc'];
  _cmdController.text = _commands[index]['cmd'];
  _selectedType = _commands[index]['type'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Command'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter command name',
                ),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter command description',
                ),
              ),
              TextField(
                controller: _cmdController,
                decoration: InputDecoration(
                  labelText: 'Command',
                  hintText: 'Enter the command to be executed',
                ),
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
                hint: Text('Select command type'),
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
            child: Text('Save'),
            onPressed: () {
              _editCommand(index);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _editCommand(int index) {
  setState(() {
    _commands[index] = {
      "name": _nameController.text,
      "desc": _descController.text,
      "cmd": _cmdController.text,
      "type": _selectedType,
    };
    _nameController.clear();
    _descController.clear();
    _cmdController.clear();
    _selectedType = 'CMD';
  });
}

void _removeCommand(int index) {
  setState(() {
    _commands.removeAt(index);
  });
}

void _moveToTop(int index) {
  setState(() {
    if (index > 0) {
      var item = _commands.removeAt(index);
      _commands.insert(0, item);
    }
  });
}

void _moveToBottom(int index) {
  setState(() {
    if (index < _commands.length - 1) {
      var item = _commands.removeAt(index);
      _commands.add(item);
    }
  });
}
}

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();

  ThemeData get themeData => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
