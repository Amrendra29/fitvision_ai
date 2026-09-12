import 'package:flutter/material.dart';
import '../../camera/screens/camera_screen.dart';

class ExerciseSelectionScreen extends StatelessWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Exercise'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ExerciseCard(
            title: 'Squat',
            subtitle: 'Legs • Beginner',
            icon: Icons.accessibility_new,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          ),

          _ExerciseCard(
            title: 'Bicep Curl',
            subtitle: 'Arms • Beginner',
            icon: Icons.fitness_center,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          ),

          _ExerciseCard(
            title: 'Push-up',
            subtitle: 'Chest • Beginner',
            icon: Icons.sports_gymnastics,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}