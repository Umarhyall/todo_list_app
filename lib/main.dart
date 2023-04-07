import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'To-Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  List<String> _taskList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = (prefs.getStringList('taskList') ?? []);
    setState(() {
      _taskList = taskList;
    });
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('taskList', _taskList);
  }

  void _addTask(String task) {
    if (task != '') {
      setState(() {
        _taskList.add(task);
        _saveData();
      });
      _controller.clear();
    }
  }

  void _removeTask(int index) {
    setState(() {
      _taskList.removeAt(index);
      _saveData();
    });
  }

  void _completeTask(int index) {
    setState(() {
      if (_taskList[index].contains('(Completed)')) {
        _taskList[index] = _taskList[index].replaceAll('(Completed)', '');
      } else {
        _taskList[index] = _taskList[index] + ' (Completed)';
      }
      _saveData();
    });
  }

  void _editTask(int index) {
    _controller.text = _taskList[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit task'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Edit task',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _controller.clear();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  _taskList[index] = _controller.text;
                  _saveData();
                  Navigator.of(context).pop();
                  _controller.clear();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _taskList.length,
      itemBuilder: (context, index) {
        final task = _taskList[index];
        return Dismissible(
          key: Key('$task$index'),
          onDismissed: (direction) {
            _removeTask(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$task dismissed'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    _addTask(task);
                  },
                ),
              ),
            );
          },
          child: ListTile(
            title: Text(
              task,
              style: TextStyle(
                decoration: _taskList[index].contains('(Completed)')
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editTask(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _removeTask(index);
                  },
                ),
                Checkbox(
                  value: _taskList[index].contains('(Completed)'),
                  onChanged: (value) {
                    _completeTask(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Add task',
            ),
            onSubmitted: (String value) {
              _addTask(value);
            },
          ),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }
}
