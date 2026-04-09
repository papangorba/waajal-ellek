class AppStatusModel {
  final String applicationStatus;
  final String applicationMinVersionAllowed;
  final String currentInstalledVersion;
  final String? message;

  AppStatusModel({
    required this.applicationStatus,
    required this.applicationMinVersionAllowed,
    required this.currentInstalledVersion,
    this.message,
  });


  bool get isActive => applicationStatus == 'ACTIF';

  bool get needsUpdate {
    try {
      final min = _parseVersion(applicationMinVersionAllowed);
      final installed = _parseVersion(currentInstalledVersion);
      return _compareVersions(installed, min) < 0;
    } catch (_) {
      return false;
    }
  }

  List<int> _parseVersion(String v) =>
      v.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  int _compareVersions(List<int> a, List<int> b) {
    for (int i = 0; i < 3; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av < bv) return -1;
      if (av > bv) return 1;
    }
    return 0;
  }

  factory AppStatusModel.fromJson(
      Map<String, dynamic> json, String installedVersion) {
    return AppStatusModel(
      applicationStatus:
      json['applicationStatus']?.toString() ?? 'ACTIF',
      applicationMinVersionAllowed:
      json['applicationMinVersionAllowed']?.toString() ?? '1.0.0',
      currentInstalledVersion: installedVersion,
      message: json['message']?.toString(),
    );
  }
}