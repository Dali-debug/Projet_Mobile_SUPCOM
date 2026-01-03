import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class NurseryProgramScreen extends StatefulWidget {
  const NurseryProgramScreen({super.key});

  @override
  State<NurseryProgramScreen> createState() => _NurseryProgramScreenState();
}

class _NurseryProgramScreenState extends State<NurseryProgramScreen> {
  final Map<String, List<Map<String, String>>> _weeklyProgram = {
    'Lundi': [],
    'Mardi': [],
    'Mercredi': [],
    'Jeudi': [],
    'Vendredi': [],
    'Samedi': [],
  };

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  void _loadProgram() {
    // Programme par défaut - à charger depuis la base de données
    setState(() {
      _weeklyProgram['Lundi'] = [
        {'time': '08:00 - 09:00', 'activity': 'Accueil et jeux libres'},
        {'time': '09:00 - 10:00', 'activity': 'Activités créatives'},
        {'time': '10:00 - 11:00', 'activity': 'Récréation'},
        {'time': '11:00 - 12:00', 'activity': 'Apprentissage'},
      ];
      _weeklyProgram['Mardi'] = [
        {'time': '08:00 - 09:00', 'activity': 'Accueil'},
        {'time': '09:00 - 10:30', 'activity': 'Musique et chant'},
        {'time': '10:30 - 11:30', 'activity': 'Jeux en plein air'},
        {'time': '11:30 - 12:00', 'activity': 'Lecture de contes'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Programme Hebdomadaire',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              if (!_isEditing) {
                _saveProgram();
              }
            },
            tooltip: _isEditing ? 'Enregistrer' : 'Modifier',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header avec gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 48,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 12),
                Text(
                  _isEditing
                      ? 'Mode édition activé'
                      : 'Programme de la semaine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Appuyez sur une activité pour la modifier',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Liste des jours
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _weeklyProgram.keys.length,
              itemBuilder: (context, index) {
                final day = _weeklyProgram.keys.elementAt(index);
                final activities = _weeklyProgram[day] ?? [];
                return _buildDayCard(day, activities, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              onPressed: () => _addActivity(context),
              backgroundColor: const Color(0xFF6366F1),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter une activité'),
            )
          : null,
    );
  }

  Widget _buildDayCard(
      String day, List<Map<String, String>> activities, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du jour
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.1),
                    const Color(0xFF8B5CF6).withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activities.length} activité${activities.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Liste des activités
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Aucune activité prévue',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...activities.asMap().entries.map((entry) {
                final idx = entry.key;
                final activity = entry.value;
                return _buildActivityItem(
                  day,
                  activity,
                  idx == activities.length - 1,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String day, Map<String, String> activity, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isEditing ? () => _editActivity(day, activity) : null,
        borderRadius: BorderRadius.only(
          bottomLeft: isLast ? const Radius.circular(20) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['time'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['activity'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isEditing)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () => _deleteActivity(day, activity),
                  iconSize: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addActivity(BuildContext context) {
    // TODO: Implémenter l'ajout d'activité
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonction d\'ajout à implémenter'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _editActivity(String day, Map<String, String> activity) {
    // TODO: Implémenter la modification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modification de "${activity['activity']}"'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteActivity(String day, Map<String, String> activity) {
    setState(() {
      _weeklyProgram[day]?.remove(activity);
    });
  }

  void _saveProgram() {
    // TODO: Sauvegarder dans la base de données
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Programme enregistré avec succès'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
