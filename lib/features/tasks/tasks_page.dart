import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/storage/hive_service.dart';
import 'model/task_model.dart';
import 'services/gist_sync_service.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedPriority = 'med';
  String _filter = 'all'; // all, open, done, high
  bool _isSyncing = false;

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch,
      text: text,
      priority: _selectedPriority,
      category: '',
      done: false,
    );

    HiveService.tasksBox().put(newTask.id, newTask);
    _taskController.clear();
    _syncTasks();
  }

  void _toggleTask(TaskModel task) {
    task.done = !task.done;
    task.save();
    _syncTasks();
  }

  void _deleteTask(TaskModel task) {
    task.delete();
    _syncTasks();
  }

  void _editTask(TaskModel task) {
    final editController = TextEditingController(text: task.text);
    final catController = TextEditingController(text: task.category);
    String editPriority = task.priority;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(labelText: 'Task'),
              ),
              TextField(
                controller: catController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              DropdownButtonFormField<String>(
                initialValue: editPriority,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'med', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (val) {
                  if (val != null) editPriority = val;
                },
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                task.text = editController.text.trim();
                task.category = catController.text.trim();
                task.priority = editPriority;
                task.save();
                Navigator.pop(context);
                _syncTasks();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _syncTasks() async {
    setState(() => _isSyncing = true);
    final box = HiveService.tasksBox();
    final localTasks = box.values.toList();
    
    final success = await GistSyncService.pushToGist(localTasks);
    if (!success) {
      // Try fetching instead if push failed or as initial step
      final remoteTasks = await GistSyncService.syncFromGist(localTasks);
      if (remoteTasks != null) {
        await box.clear();
        for (var t in remoteTasks) {
          await box.put(t.id, t);
        }
      }
    }
    setState(() => _isSyncing = false);
  }

  @override
  void initState() {
    super.initState();
    _syncTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _syncTasks,
          )
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(label: 'All', value: 'all', groupValue: _filter, onSelected: (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Open', value: 'open', groupValue: _filter, onSelected: (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Done', value: 'done', groupValue: _filter, onSelected: (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Urgent', value: 'high', groupValue: _filter, onSelected: (v) => setState(() => _filter = v)),
              ],
            ),
          ),
          
          // Input Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Add a task or reminder...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('🟢 Low')),
                    DropdownMenuItem(value: 'med', child: Text('🟡 Med')),
                    DropdownMenuItem(value: 'high', child: Text('🔴 High')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedPriority = v);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 36),
                  onPressed: _addTask,
                )
              ],
            ),
          ),

          // Task List
          Expanded(
            child: ValueListenableBuilder<Box<TaskModel>>(
              valueListenable: HiveService.tasksBox().listenable(),
              builder: (context, box, _) {
                var tasks = box.values.toList();
                
                // Filter
                if (_filter == 'open') {
                  tasks = tasks.where((t) => !t.done).toList();
                } else if (_filter == 'done') {
                  tasks = tasks.where((t) => t.done).toList();
                } else if (_filter == 'high') {
                  tasks = tasks.where((t) => t.priority == 'high' && !t.done).toList();
                }

                // Sort: undone first, then priority, then date
                final pWeight = {'high': 0, 'med': 1, 'low': 2};
                tasks.sort((a, b) {
                  if (a.done != b.done) return a.done ? 1 : -1;
                  int diff = (pWeight[a.priority] ?? 1) - (pWeight[b.priority] ?? 1);
                  if (diff != 0) return diff;
                  return b.id.compareTo(a.id);
                });

                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks found.'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    Color pColor = Colors.grey;
                    if (task.priority == 'high') pColor = Colors.redAccent;
                    if (task.priority == 'med') pColor = Colors.orangeAccent;
                    if (task.priority == 'low') pColor = Colors.lightGreen;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: pColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.done,
                          onChanged: (_) => _toggleTask(task),
                        ),
                        title: Text(
                          task.text,
                          style: TextStyle(
                            decoration: task.done ? TextDecoration.lineThrough : null,
                            color: task.done ? Colors.grey : null,
                          ),
                        ),
                        subtitle: task.category.isNotEmpty
                            ? Text(task.category, style: const TextStyle(fontSize: 12))
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editTask(task),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteTask(task),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
    );
  }
}
