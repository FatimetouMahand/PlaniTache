import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final DateTime? selectedDate;

  const AddEditTaskScreen({super.key, this.task, this.selectedDate});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _commentController;

  late TaskCategory _category;
  late TaskPriority _priority;
  late DateTime _date;
  TimeOfDay? _time;
  bool _completed = false;
  double _progressPercentage = 0.0;
  int? _satisfactionIndex;

  // Speech to Text variables
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _commentController = TextEditingController();

    _category = t?.category ?? TaskCategory.WORK;
    _priority = t?.priority ?? TaskPriority.MEDIUM;
    _date = t?.date ?? widget.selectedDate ?? DateTime.now();
    _completed = t?.completed ?? false;
    _progressPercentage = t?.progressPercentage ?? 0.0;
    _satisfactionIndex = t?.satisfactionIndex;

    if (t?.time != null) {
      final parts = t!.time!.split(':');
      _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // Activer l'enregistrement vocal et parser les informations reçues du backend
  Future<void> _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _voiceText = val.recognizedWords;
          }),
          localeId: 'fr_FR',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le dictaphone n\'est pas disponible')),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_voiceText.isNotEmpty) {
        _parseVoiceCommand(_voiceText);
      }
    }
  }

  Future<void> _parseVoiceCommand(String text) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Analyse intelligente du texte...', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final parsedTask = await taskProvider.parseVoiceCommand(text);

    if (context.mounted) Navigator.pop(context); // fermer l'indicateur

    if (parsedTask != null && mounted) {
      setState(() {
        _titleController.text = parsedTask.title;
        _descController.text = parsedTask.description;
        _category = parsedTask.category;
        _priority = parsedTask.priority;
        _date = parsedTask.date;
        if (parsedTask.time != null) {
          final parts = parsedTask.time!.split(':');
          _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche pré-remplie avec succès !'),
          backgroundColor: AppColors.priorityLow,
        ),
      );
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      String? timeStr;
      if (_time != null) {
        timeStr = "${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}";
      }

      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        priority: _priority,
        date: _date,
        time: timeStr,
        completed: _completed,
        progressPercentage: _completed ? 100.0 : _progressPercentage,
        satisfactionIndex: _satisfactionIndex,
      );

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      bool success;
      if (widget.task == null) {
        success = await taskProvider.addTask(task);
      } else {
        success = await taskProvider.updateTask(task);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.task == null ? 'Tâche créée !' : 'Tâche mise à jour !'),
            backgroundColor: AppColors.priorityLow,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  String _getCategoryName(TaskCategory cat) {
    switch (cat) {
      case TaskCategory.STUDY: return 'Études';
      case TaskCategory.WORK: return 'Travail';
      case TaskCategory.PERSONAL: return 'Personnel';
      case TaskCategory.HEALTH: return 'Santé';
      case TaskCategory.SPORT: return 'Sport';
      case TaskCategory.MEETINGS: return 'Réunion';
      case TaskCategory.OTHER: return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final taskProvider = Provider.of<TaskProvider>(context);

    // Si on édite, on récupère l'instance à jour depuis le provider
    final currentTask = isEditing 
        ? taskProvider.tasks.firstWhere((t) => t.id == widget.task!.id, orElse: () => widget.task!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier la tâche' : 'Créer une tâche',
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.priorityHigh),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer'),
                    content: const Text('Voulez-vous supprimer définitivement cette tâche ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Supprimer', style: TextStyle(color: AppColors.priorityHigh)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await taskProvider.deleteTask(widget.task!.id!);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bouton Entrée Vocale (Voice Input Option)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isListening ? AppColors.priorityHigh.withOpacity(0.08) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListening ? AppColors.priorityHigh : AppColors.primary,
                        size: 28,
                      ),
                      onPressed: _toggleListening,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isListening ? 'Écoute active...' : 'Saisie Vocale intelligente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isListening ? AppColors.priorityHigh : AppColors.primary,
                            ),
                          ),
                          Text(
                            _isListening 
                                ? _voiceText.isEmpty ? 'Parlez maintenant...' : _voiceText 
                                : 'Dictez en français (ex: "Demain à 14h réunion")',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: _isListening ? AppColors.priorityHigh.withOpacity(0.8) : AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isListening && _voiceText.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                        onPressed: () => _parseVoiceCommand(_voiceText),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Titre de la tâche
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre de la tâche',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Le titre est obligatoire' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (facultatif)',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Sélecteur de Catégorie (Horizontal list)
              const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskCategory.values.map((cat) {
                    final isSelected = _category == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_getCategoryName(cat)),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        
                        onSelected: (val) {
                          if (val) setState(() => _category = cat);
                        },
                      ),
                    );
                  }).toList().cast<Widget>(),
                ),
              ),
              const SizedBox(height: 20),

              // Priorité
              const Text('Priorité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: TaskPriority.values.map((prio) {
                  final isSelected = _priority == prio;
                  Color color;
                  String label;
                  if (prio == TaskPriority.HIGH) { color = AppColors.priorityHigh; label = 'Haute'; }
                  else if (prio == TaskPriority.MEDIUM) { color = AppColors.priorityMedium; label = 'Moyenne'; }
                  else { color = AppColors.priorityLow; label = 'Basse'; }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _priority = prio),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected ? color : AppColors.white,
                          side: BorderSide(color: isSelected ? color : AppColors.textLight.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? AppColors.white : color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Date et heure
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime.now().minus(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => _date = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(DateFormat('dd/MM/yyyy').format(_date)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Heure', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _time ?? TimeOfDay.now(),
                            );
                            if (picked != null) setState(() => _time = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(_time != null ? _time!.format(context) : 'Choisir'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barre de progression si modification
              if (isEditing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progression', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${_progressPercentage.toInt()}%'),
                  ],
                ),
                Slider(
                  value: _progressPercentage,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primaryLight,
                  onChanged: (val) {
                    setState(() {
                      _progressPercentage = val;
                      _completed = val == 100.0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Statut Terminé
                SwitchListTile(
                  title: const Text('Marquer comme terminée', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _completed,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _completed = val;
                      _progressPercentage = val ? 100.0 : 0.0;
                      if (val) _satisfactionIndex = 4;
                    });
                  },
                ),
                
                if (_completed) ...[
                  const SizedBox(height: 12),
                  const Text('Note de satisfaction de réalisation', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [1, 2, 3, 4, 5].map((index) {
                      final isSel = _satisfactionIndex == index;
                      return ChoiceChip(
                        label: Text('$index ⭐'),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        
                        onSelected: (val) {
                          if (val) setState(() => _satisfactionIndex = index);
                        },
                      );
                    }).toList().cast<Widget>(),
                  ),
                ],
                const SizedBox(height: 28),

                // COMMENTAIRES / NOTES ASSOCIES A LA TÂCHE
                const Text('Commentaires & Observations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit')),
                const SizedBox(height: 12),
                
                if (currentTask != null && currentTask.notes.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentTask.notes.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, idx) {
                      final comment = currentTask.notes[idx];
                      return ListTile(
                        title: Text(comment.content),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt.toLocal()),
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.priorityHigh, size: 18),
                          onPressed: () {
                            taskProvider.deleteTaskNote(currentTask.id!, comment.id);
                          },
                        ),
                      );
                    },
                  ),
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Ajouter une observation...',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primary),
                      onPressed: () async {
                        final content = _commentController.text.trim();
                        if (content.isNotEmpty && currentTask?.id != null) {
                          final ok = await taskProvider.addTaskNote(currentTask!.id!, content);
                          if (ok) {
                            _commentController.clear();
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],

              // Bouton Sauvegarder
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Enregistrer les modifications' : 'Créer la tâche',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension pour manipuler les dates
extension DateTimeExtension on DateTime {
  DateTime minus(Duration duration) {
    return subtract(duration);
  }
}
