import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../focus/screens/focus_mode_screen.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<StudySession> _sessions = [];
  
  @override
  void initState() {
    super.initState();
    _loadSampleSessions();
  }

  void _loadSampleSessions() {
    final today = DateTime.now();
    _sessions.addAll([
      StudySession(
        id: '1',
        title: 'Machine Learning',
        subject: 'AI',
        date: today,
        time: const TimeOfDay(hour: 9, minute: 0),
        duration: 45,
        color: AppColors.primaryBlue,
        icon: Icons.psychology_rounded,
        isCompleted: false,
      ),
      StudySession(
        id: '2',
        title: 'Calculus II',
        subject: 'MATH',
        date: today,
        time: const TimeOfDay(hour: 11, minute: 0),
        duration: 60,
        color: AppColors.accentPurple,
        icon: Icons.functions_rounded,
        isCompleted: false,
      ),
      StudySession(
        id: '3',
        title: 'Data Structures',
        subject: 'CS',
        date: today,
        time: const TimeOfDay(hour: 14, minute: 30),
        duration: 45,
        color: Colors.orange,
        icon: Icons.account_tree_rounded,
        isCompleted: false,
      ),
      StudySession(
        id: '4',
        title: 'Physics Lab Report',
        subject: 'PHYSICS',
        date: today,
        time: const TimeOfDay(hour: 16, minute: 0),
        duration: 30,
        color: AppColors.info,
        icon: Icons.science_rounded,
        isCompleted: false,
        isExam: true,
      ),
      StudySession(
        id: '5',
        title: 'Spanish Vocabulary',
        subject: 'LANGUAGE',
        date: today.add(const Duration(days: 1)),
        time: const TimeOfDay(hour: 10, minute: 0),
        duration: 30,
        color: AppColors.error,
        icon: Icons.translate_rounded,
        isCompleted: false,
      ),
    ]);
  }

  List<StudySession> get _todaySessions {
    return _sessions.where((s) => 
      s.date.year == _selectedDate.year &&
      s.date.month == _selectedDate.month &&
      s.date.day == _selectedDate.day
    ).toList()
      ..sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));
  }

  int get _totalMinutesToday {
    return _todaySessions.fold(0, (sum, s) => sum + s.duration);
  }

  int get _completedMinutesToday {
    return _todaySessions.where((s) => s.isCompleted).fold(0, (sum, s) => sum + s.duration);
  }

  void _toggleComplete(String id) {
    setState(() {
      final index = _sessions.indexWhere((s) => s.id == id);
      if (index != -1) {
        _sessions[index] = _sessions[index].copyWith(
          isCompleted: !_sessions[index].isCompleted,
        );
      }
    });
  }

  void _deleteSession(String id) {
    setState(() {
      _sessions.removeWhere((s) => s.id == id);
    });
  }

  void _showAddSessionDialog() {
    String title = '';
    String subject = '';
    TimeOfDay time = TimeOfDay.now();
    int duration = 30;
    Color selectedColor = AppColors.primaryBlue;
    IconData selectedIcon = Icons.book_rounded;

    final subjects = [
      {'name': 'Math', 'color': AppColors.accentPurple, 'icon': Icons.functions_rounded},
      {'name': 'Science', 'color': AppColors.info, 'icon': Icons.science_rounded},
      {'name': 'Language', 'color': AppColors.error, 'icon': Icons.translate_rounded},
      {'name': 'CS', 'color': Colors.orange, 'icon': Icons.computer_rounded},
      {'name': 'AI', 'color': AppColors.primaryBlue, 'icon': Icons.psychology_rounded},
      {'name': 'History', 'color': Colors.brown, 'icon': Icons.history_edu_rounded},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Study Session',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Session Title',
                    hintText: 'e.g., Chapter 5 Review',
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => title = v,
                ),
                const SizedBox(height: 16),

                // Subject Selection
                const Text(
                  'Subject',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subjects.map((s) {
                    final isSelected = subject == s['name'];
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          subject = s['name'] as String;
                          selectedColor = s['color'] as Color;
                          selectedIcon = s['icon'] as IconData;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? (s['color'] as Color) : (s['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: s['color'] as Color,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              s['icon'] as IconData,
                              size: 16,
                              color: isSelected ? Colors.white : s['color'] as Color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s['name'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : s['color'] as Color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Time and Duration Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) {
                            setSheetState(() => time = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: AppColors.textSecondary),
                              const SizedBox(width: 12),
                              Text(
                                time.format(context),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<int>(
                                value: duration,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: [15, 30, 45, 60, 90, 120].map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('$d min'),
                                )).toList(),
                                onChanged: (v) => setSheetState(() => duration = v!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: title.isNotEmpty && subject.isNotEmpty ? () {
                      setState(() {
                        _sessions.add(StudySession(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          subject: subject.toUpperCase(),
                          date: _selectedDate,
                          time: time,
                          duration: duration,
                          color: selectedColor,
                          icon: selectedIcon,
                          isCompleted: false,
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Session added!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = _selectedDate.year == today.year && 
                    _selectedDate.month == today.month && 
                    _selectedDate.day == today.day;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isToday ? 'Today\'s Plan 📚' : 'Study Plan',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today_rounded),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Week View
                  _buildWeekView(),
                ],
              ),
            ),

            // Progress Card
            if (_todaySessions.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${_todaySessions.where((s) => s.isCompleted).length}/${_todaySessions.length} Complete',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_completedMinutesToday / $_totalMinutesToday min',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _totalMinutesToday > 0 ? _completedMinutesToday / _totalMinutesToday : 0,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

            // Sessions Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sessions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_todaySessions.length} Total',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sessions List
            Expanded(
              child: _todaySessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sessions planned',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add a study session',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _todaySessions.length,
                      itemBuilder: (context, index) {
                        return _buildSessionCard(_todaySessions[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSessionDialog,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildWeekView() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isSelected = date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;
        final isToday = date.year == today.year &&
                       date.month == today.month &&
                       date.day == today.day;
        final hasEvents = _sessions.any((s) => 
          s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day
        );

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected 
                  ? Border.all(color: AppColors.primaryBlue, width: 2)
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('E').format(date).substring(0, 2),
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white70 : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasEvents)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSessionCard(StudySession session) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _deleteSession(session.id),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FocusModeScreen()),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            border: session.isExam 
                ? Border.all(color: AppColors.error, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Completion checkbox
                GestureDetector(
                  onTap: () => _toggleComplete(session.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: session.isCompleted 
                          ? AppColors.success 
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: session.isCompleted 
                            ? AppColors.success 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: session.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Color bar
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: session.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: session.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    session.icon,
                    color: session.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            session.subject,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: session.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (session.isExam) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'EXAM',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: session.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: session.isCompleted 
                              ? AppColors.textSecondary 
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '${session.duration} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      session.time.format(context),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.play_circle_filled_rounded,
                      color: session.color,
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudySession {
  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final TimeOfDay time;
  final int duration;
  final Color color;
  final IconData icon;
  final bool isCompleted;
  final bool isExam;

  StudySession({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.time,
    required this.duration,
    required this.color,
    required this.icon,
    required this.isCompleted,
    this.isExam = false,
  });

  StudySession copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? date,
    TimeOfDay? time,
    int? duration,
    Color? color,
    IconData? icon,
    bool? isCompleted,
    bool? isExam,
  }) {
    return StudySession(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
      isExam: isExam ?? this.isExam,
    );
  }
}
