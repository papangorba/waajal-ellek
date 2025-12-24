import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _anneesCotisationController = TextEditingController();

  double? _montantEstime;
  int? _pointsEstimes;
  bool _isCalculated = false;

  final double _valeurPoint = 1500.0;
  final double _pointsParMois = 10.0;

  @override
  void dispose() {
    _montantController.dispose();
    _anneesCotisationController.dispose();
    super.dispose();
  }

  void _calculerSimulation() {
    if (!_formKey.currentState!.validate()) return;

    final anneeCotisation = int.tryParse(_anneesCotisationController.text) ?? 0;
    final moisCotisation = anneeCotisation * 12;
    final pointsTotal = (moisCotisation * _pointsParMois).toInt();
    final montantPension = pointsTotal * _valeurPoint;

    setState(() {
      _pointsEstimes = pointsTotal;
      _montantEstime = montantPension;
      _isCalculated = true;
    });
  }

  void _resetSimulation() {
    setState(() {
      _montantController.clear();
      _anneesCotisationController.clear();
      _montantEstime = null;
      _pointsEstimes = null;
      _isCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation de Pension'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paramètres de simulation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _montantController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Montant cotisation mensuelle (FCFA)',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un montant';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _anneesCotisationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nombre d\'années de cotisation',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nombre d\'années';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _calculerSimulation,
                              icon: const Icon(Icons.calculate),
                              label: const Text('Calculer'),
                            ),
                          ),
                          if (_isCalculated) ...[
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: _resetSimulation,
                              child: const Text('Réinitialiser'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_isCalculated) ...[
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Résultat de la simulation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        _ResultRow(
                          label: 'Points estimés',
                          value: '$_pointsEstimes',
                          icon: Icons.stars,
                        ),
                        const Divider(height: 32),
                        _ResultRow(
                          label: 'Pension mensuelle estimée',
                          value: CurrencyFormatter.format(_montantEstime ?? 0),
                          icon: Icons.payments,
                          isHighlighted: true,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Cette simulation est basée sur les paramètres actuels et peut varier.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: isHighlighted
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isHighlighted ? 16 : 14,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary
                : Colors.black87,
          ),
        ),
      ],
    );
  }
}
