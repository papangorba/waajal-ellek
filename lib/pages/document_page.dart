import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DocumentCard(
            title: 'Attestation de cotisation',
            description: 'Document attestant vos cotisations',
            icon: Icons.receipt_long,
            date: DateTime.now().subtract(const Duration(days: 15)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléchargement du document...'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _DocumentCard(
            title: 'Relevé de points',
            description: 'Détail de vos points accumulés',
            icon: Icons.stars,
            date: DateTime.now().subtract(const Duration(days: 30)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléchargement du document...'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _DocumentCard(
            title: 'Certificat de pension',
            description: 'Certificat officiel de pension',
            icon: Icons.card_membership,
            date: DateTime.now().subtract(const Duration(days: 90)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléchargement du document...'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _DocumentCard(
            title: 'Historique des versements',
            description: 'Liste complète de vos versements',
            icon: Icons.history,
            date: DateTime.now().subtract(const Duration(days: 120)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléchargement du document...'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final DateTime date;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Généré le ${DateFormatter.format(date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
