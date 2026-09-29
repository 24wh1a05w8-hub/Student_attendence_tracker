// AttendEase – Student Attendance Tracker (Version 2 – "Impressive" UI)
// Same simple in-memory logic as before, with a much richer look:
// gradient backgrounds, glass-style cards, animated progress and gradient buttons.

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 1. COLORS AND GRADIENTS  (change these to restyle the whole app!)
// ---------------------------------------------------------------------------

// Main background used on every screen: deep navy -> royal purple -> violet.
const LinearGradient kBackgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF141E30), Color(0xFF3A1C71), Color(0xFF6A3DE8)],
);

// Gradients for buttons and avatars.
const LinearGradient kCyanGradient = LinearGradient(
  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
);
const LinearGradient kPinkGradient = LinearGradient(
  colors: [Color(0xFFFF6FD8), Color(0xFF8E54E9)],
);
const LinearGradient kOrangeGradient = LinearGradient(
  colors: [Color(0xFFFFB347), Color(0xFFFF5F6D)],
);
const LinearGradient kGreenGradient = LinearGradient(
  colors: [Color(0xFF11D9A5), Color(0xFF0BAA7C)],
);

// Semi-transparent "glass" look for cards on the dark background.
const Color kGlassColor = Color(0x26FFFFFF);
const Color kGlassBorder = Color(0x40FFFFFF);

// Attendance colors: green when fine, red when below 75%.
Color attendanceColor(double p) =>
    p >= 75 ? const Color(0xFF1E9E5A) : const Color(0xFFD64545);
Color attendanceBackground(double p) =>
    p >= 75 ? const Color(0xFFE3F8EC) : const Color(0xFFFDE7E7);

// ---------------------------------------------------------------------------
// 2. DATA SECTION  (kept in memory – no backend)
// ---------------------------------------------------------------------------

class Student {
  String name;
  String rollNumber;
  int classesPresent;
  int classesAbsent;
  bool? todayStatus; // null = not marked, true = present, false = absent

  Student({
    required this.name,
    required this.rollNumber,
    this.classesPresent = 0,
    this.classesAbsent = 0,
    this.todayStatus,
  });

  int get totalClasses => classesPresent + classesAbsent;

  double get percentage =>
      totalClasses == 0 ? 0 : (classesPresent / totalClasses) * 100;
}

final List<Student> students = [
  Student(name: 'Rahul', rollNumber: '101', classesPresent: 18, classesAbsent: 2),
  Student(name: 'Priya', rollNumber: '102', classesPresent: 19, classesAbsent: 1),
  Student(name: 'Anjali', rollNumber: '103', classesPresent: 14, classesAbsent: 6),
  Student(name: 'Kiran', rollNumber: '104', classesPresent: 16, classesAbsent: 4),
];

int get totalStudents => students.length;
int get presentToday => students.where((s) => s.todayStatus == true).length;
int get absentToday => students.where((s) => s.todayStatus == false).length;

double get overallAttendance {
  int present = 0;
  int total = 0;
  for (final s in students) {
    present += s.classesPresent;
    total += s.totalClasses;
  }
  return total == 0 ? 0 : (present / total) * 100;
}

// ---------------------------------------------------------------------------
// 3. APP ENTRY POINT
// ---------------------------------------------------------------------------

void main() {
  runApp(const AttendEaseApp());
}

class AttendEaseApp extends StatelessWidget {
  const AttendEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttendEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A3DE8)),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. REUSABLE WIDGETS  (small building blocks used by every screen)
// ---------------------------------------------------------------------------

// A Scaffold with the gradient background, an optional transparent app bar,
// and content that is centered and limited to 600px wide (responsive).
class GradientScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;

  const GradientScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kBackgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent, // let the gradient show through
        appBar: title == null
            ? null
            : AppBar(
                title: Text(
                  title!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: Colors.white,
              ),
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}

// Makes a widget fade in and slide up when it first appears.
// Using a different [index] makes each list item appear a bit later.
class FadeSlideIn extends StatelessWidget {
  final int index;
  final Widget child;

  const FadeSlideIn({super.key, this.index = 0, required this.child});

  @override
  Widget build(BuildContext context) {
    final int delay = index > 6 ? 6 : index; // cap so long lists stay quick
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay * 120),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// A wide rounded button filled with a gradient.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final LinearGradient gradient;

  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.gradient = kCyanGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A white card with rounded corners and a soft shadow (used for list items).
class WhiteCard extends StatelessWidget {
  final Widget child;
  const WhiteCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// A circular avatar with a gradient background and the student's initial.
class GradientAvatar extends StatelessWidget {
  final String name;
  final double size;
  const GradientAvatar({super.key, required this.name, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: kPinkGradient,
      ),
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. HOME SCREEN
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Open a screen, and refresh the statistics when we come back.
  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Header ----
            FadeSlideIn(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kGlassColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kGlassBorder),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AttendEase',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Student Attendance Tracker',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Big overview card with animated ring ----
            FadeSlideIn(index: 1, child: _buildOverviewCard()),
            const SizedBox(height: 16),

            // ---- Three small statistic tiles ----
            FadeSlideIn(
              index: 2,
              child: Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Total Students',
                      value: '$totalStudents',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF6DD5FA),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'Present Today',
                      value: '$presentToday',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF5CFFB0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'Absent Today',
                      value: '$absentToday',
                      icon: Icons.cancel_rounded,
                      color: const Color(0xFFFF8A8A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ---- Action buttons ----
            FadeSlideIn(
              index: 3,
              child: ActionTile(
                title: 'Mark Attendance',
                subtitle: "Record today's presence",
                icon: Icons.edit_calendar_rounded,
                gradient: kCyanGradient,
                onTap: () => _openScreen(const MarkAttendanceScreen()),
              ),
            ),
            FadeSlideIn(
              index: 4,
              child: ActionTile(
                title: 'View Students',
                subtitle: 'See and add students',
                icon: Icons.people_alt_rounded,
                gradient: kPinkGradient,
                onTap: () => _openScreen(const StudentListScreen()),
              ),
            ),
            FadeSlideIn(
              index: 5,
              child: ActionTile(
                title: 'Attendance Report',
                subtitle: 'Progress and warnings',
                icon: Icons.bar_chart_rounded,
                gradient: kOrangeGradient,
                onTap: () => _openScreen(const AttendanceReportScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The glass card with the circular percentage ring.
  Widget _buildOverviewCard() {
    final double percent = overallAttendance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kGlassColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: kGlassBorder),
      ),
      child: Row(
        children: [
          // TweenAnimationBuilder animates the ring from its old value to the new one.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: const Color(0x33FFFFFF),
                        color: const Color(0xFF5CFFB0),
                      ),
                    ),
                    Text(
                      '${(value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${percent.toStringAsFixed(1)}% across all classes',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    percent >= 75 ? 'On track' : 'Needs attention',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A small glass tile showing one statistic.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: kGlassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGlassBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// A big gradient button with an icon, a title and a subtitle.
class ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0x33FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. STUDENT LIST SCREEN
// ---------------------------------------------------------------------------

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  Future<void> _goToAddStudent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentScreen()),
    );
    setState(() {}); // refresh list after returning
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Students',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddStudent,
        backgroundColor: const Color(0xFF00E5FF),
        foregroundColor: const Color(0xFF141E30),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Add Student',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        // Extra bottom padding so the last card is not hidden by the button.
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          final color = attendanceColor(student.percentage);
          return FadeSlideIn(
            index: index,
            child: WhiteCard(
              child: Row(
                children: [
                  GradientAvatar(name: student.name),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1F3D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Roll No: ${student.rollNumber}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  // Percentage "chip"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: attendanceBackground(student.percentage),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${student.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. ADD STUDENT SCREEN
// ---------------------------------------------------------------------------

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  void _addStudent() {
    if (_formKey.currentState!.validate()) {
      students.add(
        Student(
          name: _nameController.text.trim(),
          rollNumber: _rollController.text.trim(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
      Navigator.pop(context);
    }
  }

  // Shared style for both text fields.
  InputDecoration _fieldStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF3F0FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Add Student',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeSlideIn(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: kPinkGradient,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'New Student',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F3D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldStyle('Student Name', Icons.person),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rollController,
                    decoration: _fieldStyle('Roll Number', Icons.badge),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a roll number';
                      }
                      final exists =
                          students.any((s) => s.rollNumber == value.trim());
                      if (exists) return 'This roll number already exists';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  GradientButton(
                    label: 'Add Student',
                    icon: Icons.check_rounded,
                    gradient: kPinkGradient,
                    onPressed: _addStudent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. MARK ATTENDANCE SCREEN
// ---------------------------------------------------------------------------

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  late List<bool> _isPresent; // true = Present (default)

  @override
  void initState() {
    super.initState();
    _isPresent = students.map((s) => s.todayStatus ?? true).toList();
  }

  // Set every student to present (true) or absent (false).
  void _setAll(bool value) {
    setState(() {
      _isPresent = List<bool>.filled(students.length, value);
    });
  }

  void _saveAttendance() {
    for (int i = 0; i < students.length; i++) {
      final student = students[i];

      // Undo an earlier save from today so a day is not counted twice.
      if (student.todayStatus == true) {
        student.classesPresent--;
      } else if (student.todayStatus == false) {
        student.classesAbsent--;
      }

      // Record the new status.
      if (_isPresent[i]) {
        student.classesPresent++;
      } else {
        student.classesAbsent++;
      }
      student.todayStatus = _isPresent[i];
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final int presentCount = _isPresent.where((p) => p).length;
    final int absentCount = _isPresent.length - presentCount;

    return GradientScaffold(
      title: 'Mark Attendance',
      body: Column(
        children: [
          // ---- Live summary bar ----
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kGlassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGlassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Present: $presentCount',
                  style: const TextStyle(
                    color: Color(0xFF5CFFB0),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Absent: $absentCount',
                  style: const TextStyle(
                    color: Color(0xFFFF8A8A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () => _setAll(true),
                  child: const Text(
                    'All Present',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => _setAll(false),
                  child: const Text(
                    'All Absent',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ---- Student list ----
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final bool present = _isPresent[index];
                return FadeSlideIn(
                  index: index,
                  child: WhiteCard(
                    child: Row(
                      children: [
                        GradientAvatar(name: student.name),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F1F3D),
                                ),
                              ),
                              Text(
                                'Roll No: ${student.rollNumber}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Switch(
                              value: present,
                              activeTrackColor: const Color(0xFF11D9A5),
                              onChanged: (value) {
                                setState(() {
                                  _isPresent[index] = value;
                                });
                              },
                            ),
                            Text(
                              present ? 'Present' : 'Absent',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: present
                                    ? const Color(0xFF1E9E5A)
                                    : const Color(0xFFD64545),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ---- Save button ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GradientButton(
              label: 'Save Attendance',
              icon: Icons.save_rounded,
              gradient: kGreenGradient,
              onPressed: students.isEmpty ? null : _saveAttendance,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 9. ATTENDANCE REPORT SCREEN
// ---------------------------------------------------------------------------

class AttendanceReportScreen extends StatelessWidget {
  const AttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int lowCount = students.where((s) => s.percentage < 75).length;

    return GradientScaffold(
      title: 'Attendance Report',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          // ---- Summary banner ----
          FadeSlideIn(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kGlassColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGlassBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    lowCount == 0
                        ? Icons.emoji_events_rounded
                        : Icons.warning_amber_rounded,
                    color: lowCount == 0
                        ? const Color(0xFFFFD54F)
                        : const Color(0xFFFF8A8A),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lowCount == 0
                          ? 'Great! Everyone is at 75% or above.'
                          : '$lowCount student(s) below 75% attendance',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- One card per student ----
          for (int i = 0; i < students.length; i++)
            FadeSlideIn(
              index: i + 1,
              child: _buildStudentCard(students[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    final double percent = student.percentage;
    final Color color = attendanceColor(percent);

    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name, roll number and percentage
          Row(
            children: [
              GradientAvatar(name: student.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F3D),
                      ),
                    ),
                    Text(
                      'Roll No: ${student.rollNumber}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Animated progress bar (fills up when the screen opens)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 12,
                color: color,
                backgroundColor: const Color(0xFFE8E8F0),
                borderRadius: BorderRadius.circular(10),
              );
            },
          ),
          const SizedBox(height: 12),

          // Present / absent counts
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF1E9E5A), size: 18),
              const SizedBox(width: 4),
              Text('Present: ${student.classesPresent}'),
              const SizedBox(width: 20),
              const Icon(Icons.cancel, color: Color(0xFFD64545), size: 18),
              const SizedBox(width: 4),
              Text('Absent: ${student.classesAbsent}'),
            ],
          ),

          // Warning only when below 75%
          if (percent < 75) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE7E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFD64545)),
                  SizedBox(width: 8),
                  Text(
                    'Attendance Below 75%',
                    style: TextStyle(
                      color: Color(0xFFD64545),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
