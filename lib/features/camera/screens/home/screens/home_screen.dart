import 'package:fitvision_ai/features/workout/screens/exercise_selection_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitVision AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back 👋',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Ready to train smarter?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              // Start workout card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 40,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'AI Workout',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Use your camera to analyze your exercise form, count reps and get real-time feedback.',
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ExerciseSelectionScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Workout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _ProgressCard(
                      title: 'Workouts',
                      value: '0',
                      icon: Icons.fitness_center,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _ProgressCard(
                      title: 'Calories',
                      value: '0',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ProgressCard(
                      title: 'Minutes',
                      value: '0',
                      icon: Icons.timer,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _ProgressCard(
                      title: 'Best Score',
                      value: '--',
                      icon: Icons.star,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(title),
          ],
        ),
      ),
    );
  }
}