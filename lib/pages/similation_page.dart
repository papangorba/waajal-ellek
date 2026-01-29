import 'package:flutter/material.dart';
import 'package:waajal_elek/config/theme.dart';
import 'dart:math';
import '../models/simulation_stats.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stat_card.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  late final SimulationStats stats;

  @override
  void initState() {
    super.initState();
    stats = const SimulationStats(
      capitalFinal: 82071041,
      pensionMensuelle: 417807,
      cotisationTotale: 42180000,
      interetsTotales: 41437641,
      //infos simulation
      grade: "Général d'armée",
      ageAdhesion: 25,
      anneeAdhesion: 2026,
      tauxRendement: 3.5,
      cotisationBase: 45000,
      cotisationVolontaire: 50000,
      optionDeces: true,
      dureeAdhesion: "36 ans et 11 mois",
      ageRetraite: 62,
      //type de pension
      renteViagere: 417807,
      renteViagereAnnuelle: 5013684,
      renteCertaine5: 1486729,
      renteCertaine5Annuelle: 17840748,
      renteCertaine10: 807140,
      renteCertaine10Annuelle: 9685680,
      renteCertaine15: 582827,
      renteCertaine15Annuelle: 6993924,
      renteCertaine20: 472310,
      renteCertaine20Annuelle: 5667720,


    );

  }


  @override
  void dispose() {
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation de Retraite'),
        backgroundColor: AppTheme.primaryColor
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              //EN-TÊTE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Simulation de Retraite',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Projection de votre retraite selon le simulateur Waajal Élèk',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
               GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.99999,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            InfoStatCard(
              title: "Capital Finale",
              mainValue: stats.capitalFinal,
              isCurrency: true,
              icon: Icons.trending_up,
              color: Colors.blue,
              comment: "Dans 37 ans",
            ),
            InfoStatCard(
              title: "Pension Mensuelle",
              mainValue: stats.pensionMensuelle,
              isCurrency: true,
              icon: Icons.money,
              color: Colors.green,
              comment: "Rente viagère",
            ),
            InfoStatCard(
              title: "Cotisation Totale",
              mainValue: stats.cotisationTotale,
              isCurrency: true,
              icon: Icons.calendar_today,
              color: Colors.purple,
              comment: "Sur 36 ans et 11 mois",
            ),
            InfoStatCard(
              title: "Intérêts Totaux",
              mainValue: stats.interetsTotales,
              isCurrency: true,
              icon: Icons.account_balance,
              color: Colors.orange,
              comment: "Rendement accumulé",
            ),
          ],
        ),
              const SizedBox(height: 24),
               Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                   color: const Color(0xFFE8F4FD),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(
                   color: const Color(0xFFB3D9F2),
                   width: 1,
                    )   ,
                ),
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Paramètres de simulation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Grille des paramètres
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 16,
                childAspectRatio: 3,
                children: [
                  _buildParameter('Grade', stats.grade),
                  _buildParameter('Âge adhésion', '${stats.ageAdhesion} ans'),
                  _buildParameter('Année adhésion', stats.anneeAdhesion.toString()),
                  _buildParameter('Taux rendement', '${stats.tauxRendement.toStringAsFixed(1)} %',),
                  _buildParameter('Cotisation de base', CurrencyFormatter.format(stats.cotisationBase),),
                  _buildParameter('Cotisation volontaire', CurrencyFormatter.format(stats.cotisationVolontaire),),
                  _buildParameter('Option décès', stats.optionDeces ? 'Oui' : 'Non',),
                  _buildParameter('Durée adhésion', stats.dureeAdhesion,),
                  _buildParameter('Âge retraite', '${stats.ageRetraite} ans',),
                ],
              ),

            ],
          ),
        ),
              const SizedBox(height: 24,),
              Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pensions Mensuelles selon Type de Rente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 900 ? 3 :
                constraints.maxWidth > 600 ? 2 : 1;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                  children: [
                    _buildPensionCard(
                      'Rente Viagère',
                      stats.renteViagere,
                      stats.renteViagereAnnuelle,
                    ),
                    _buildPensionCard(
                      'Rente Certaine 5 ans',
                      stats.renteCertaine5,
                      stats.renteCertaine5Annuelle,
                    ),
                    _buildPensionCard(
                      'Rente Certaine 10 ans',
                      stats.renteCertaine10,
                      stats.renteCertaine10Annuelle,
                    ),
                    _buildPensionCard(
                      'Rente Certaine 15 ans',
                      stats.renteCertaine15,
                      stats.renteCertaine15Annuelle,
                    ),
                    _buildPensionCard(
                      'Rente Certaine 20 ans',
                      stats.renteCertaine20,
                      stats.renteCertaine20Annuelle,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),

            ],
          ),

      ),
    );
  }

  Widget _buildParameter(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4A6FA5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A5F),
          ),
        ),
      ],
    );
  }

  Widget _buildPensionCard(String title, double montantMensuel, double montantAnnuel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F9F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB8E6D0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(montantMensuel),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'par mois',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${CurrencyFormatter.format(montantAnnuel)} / an',
            style: TextStyle(
              fontSize: 13,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



}

class InfoStatCard extends StatelessWidget {
  final String title;
  final dynamic mainValue;
  final String? suffix;
  final bool isCurrency;
  final IconData icon;
  final Color color;
  final String? comment;

  const InfoStatCard({
    super.key,
    required this.title,
    required this.mainValue,
    this.suffix,
    this.isCurrency = false,
    required this.icon,
    required this.color,
    this.comment,
  });

  String _formatValue(dynamic value, String? suffix, bool isCurrency) {
    if (isCurrency && (value is int || value is double)) {
      return CurrencyFormatter.format(value.toDouble());
    }
    if (value is int || value is double) {
      return suffix != null ? '$value $suffix' : value.toString();
    }
    if (value is String) return suffix != null ? '$value $suffix' : value;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Titre + icone
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          //Valeur principale
          Text(
            _formatValue(mainValue, suffix, isCurrency),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          //Commentaire
          if (comment != null) ...[
            const SizedBox(height: 6),
            Text(
              comment!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}






