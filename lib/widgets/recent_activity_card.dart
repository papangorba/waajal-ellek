import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import '../utils/currency_formatter.dart';

class RecentActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;

  const RecentActivityCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(activity['date_cotisation'] as String);
    final montant = (activity['montant'] as num).toDouble();
    final type = activity['type_cotisation'] as String;

    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          CurrencyFormatter.format(montant),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${type.toUpperCase()} • ${DateFormatter.format(date)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
