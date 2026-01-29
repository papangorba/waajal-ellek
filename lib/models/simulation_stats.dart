class SimulationStats {
  // Valeurs principales
  final double capitalFinal;
  final double pensionMensuelle;
  final double cotisationTotale;
  final double interetsTotales;

  //infos simulation
  final String grade;
  final int ageAdhesion;
  final int anneeAdhesion;
  final double tauxRendement;
  final double cotisationBase;
  final double cotisationVolontaire;
  final bool optionDeces;
  final String dureeAdhesion;
  final int ageRetraite;

  //type de pension
  final double renteViagere;
  final double renteViagereAnnuelle;
  final double renteCertaine5;
  final double renteCertaine5Annuelle;
  final double renteCertaine10;
  final double renteCertaine10Annuelle;
  final double renteCertaine15;
  final double renteCertaine15Annuelle;
  final double renteCertaine20;
  final double renteCertaine20Annuelle;



  const SimulationStats({
    required this.capitalFinal,
    required this.pensionMensuelle,
    required this.cotisationTotale,
    required this.interetsTotales,
    //infos simulation
    required this.grade,
    required this.ageAdhesion,
    required this.anneeAdhesion,
    required this.tauxRendement,
    required this.cotisationBase,
    required this.cotisationVolontaire,
    required this.optionDeces,
    required this.dureeAdhesion,
    required this.ageRetraite,
    //type de pension
    required this.renteViagere,
    required this.renteViagereAnnuelle,
    required this.renteCertaine5,
    required this.renteCertaine5Annuelle,
    required this.renteCertaine10,
    required this.renteCertaine10Annuelle,
    required this.renteCertaine15,
    required this.renteCertaine15Annuelle,
    required this.renteCertaine20,
    required this.renteCertaine20Annuelle,
  });
}
