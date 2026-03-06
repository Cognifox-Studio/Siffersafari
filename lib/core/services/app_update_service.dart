import 'dart:convert';
import 'dart:io';

import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService {
  static const String _latestReleaseApiUrl =
      'https://api.github.com/repos/Cognifox-Studio/Siffersafari/releases/latest';
  static const String _androidProviderAuthority =
      'com.cognifoxstudio.siffersafari.ota_update_provider';

  Future<String> getInstalledVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.buildNumber.isEmpty) {
      return packageInfo.version;
    }
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  Future<AppUpdateInfo> fetchLatestRelease() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(_latestReleaseApiUrl));
      request.headers
        ..set(HttpHeaders.userAgentHeader, 'Siffersafari-App-Update')
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception(
          'GitHub API svarade med ${response.statusCode}: ${body.trim()}',
        );
      }

      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) {
        throw Exception('Ogiltigt svar från GitHub Release API.');
      }

      final tagName = '${json['tag_name'] ?? ''}'.trim();
      final releasePageUrl = '${json['html_url'] ?? ''}'.trim();
      final releaseNotes = '${json['body'] ?? ''}'.trim();
      final publishedAtRaw = '${json['published_at'] ?? ''}'.trim();
      final assets = json['assets'];

      if (tagName.isEmpty || releasePageUrl.isEmpty) {
        throw Exception('GitHub Release saknar tagg eller releasesida.');
      }

      return AppUpdateInfo(
        tagName: tagName,
        releasePageUrl: releasePageUrl,
        apkUrl: _pickApkUrl(assets),
        releaseNotes: releaseNotes,
        publishedAt: DateTime.tryParse(publishedAtRaw),
      );
    } finally {
      client.close(force: true);
    }
  }

  bool isUpdateAvailable(String installedVersion, String latestTag) {
    return _compareSemver(installedVersion, latestTag) < 0;
  }

  Stream<AppUpdateInstallProgress> installUpdate(AppUpdateInfo release) {
    if (!Platform.isAndroid) {
      throw Exception('Automatisk appuppdatering stöds bara på Android.');
    }

    final apkUrl = release.apkUrl;
    if (apkUrl == null || apkUrl.isEmpty) {
      throw Exception('Release saknar APK-fil att installera.');
    }

    final destinationFilename =
        'siffersafari_${_normalizeVersion(release.tagName).replaceAll('+', '_')}.apk';

    return OtaUpdate()
        .execute(
          apkUrl,
          androidProviderAuthority: _androidProviderAuthority,
          destinationFilename: destinationFilename,
        )
        .map(_mapInstallEvent);
  }

  String? _pickApkUrl(dynamic assets) {
    if (assets is! List) return null;

    String? fallback;
    for (final asset in assets) {
      if (asset is! Map) continue;
      final name = '${asset['name'] ?? ''}'.trim().toLowerCase();
      final url = '${asset['browser_download_url'] ?? ''}'.trim();
      if (url.isEmpty || !url.toLowerCase().endsWith('.apk')) {
        continue;
      }
      if (name == 'app-release.apk') {
        return url;
      }
      fallback ??= url;
    }

    return fallback;
  }

  AppUpdateInstallProgress _mapInstallEvent(OtaEvent event) {
    final progress = int.tryParse(event.value ?? '');

    switch (event.status) {
      case OtaStatus.DOWNLOADING:
        return AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.downloading,
          message: progress == null
              ? 'Laddar ned uppdatering...'
              : 'Laddar ned uppdatering... $progress%',
          progress: progress,
        );
      case OtaStatus.INSTALLING:
        return AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.installing,
          message: progress == null
              ? 'Öppnar Android-installationen...'
              : 'Installerar uppdatering... $progress%',
          progress: progress,
        );
      case OtaStatus.INSTALLATION_DONE:
        return const AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.completed,
          message:
              'Uppdateringen är installerad. Appen kan nu fortsätta med samma data.',
        );
      case OtaStatus.CANCELED:
        return const AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.canceled,
          message: 'Uppdateringen avbröts.',
        );
      case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
        return const AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.error,
          message: 'Android nekade installationsbehörighet för uppdateringen.',
        );
      case OtaStatus.ALREADY_RUNNING_ERROR:
        return const AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.error,
          message: 'En uppdatering pågår redan.',
        );
      case OtaStatus.INSTALLATION_ERROR:
        return AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.error,
          message: _formatPluginError(
            event.value,
            fallback: 'Installationen misslyckades.',
          ),
        );
      case OtaStatus.DOWNLOAD_ERROR:
        return AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.error,
          message: _formatPluginError(
            event.value,
            fallback: 'Kunde inte ladda ned uppdateringen.',
          ),
        );
      case OtaStatus.CHECKSUM_ERROR:
        return AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.error,
          message: _formatPluginError(
            event.value,
            fallback: 'APK-filen gick inte att verifiera.',
          ),
        );
      case OtaStatus.INTERNAL_ERROR:
        return AppUpdateInstallProgress(
          stage: AppUpdateInstallStage.error,
          message: _formatPluginError(
            event.value,
            fallback: 'Internt fel i uppdateringsflödet.',
          ),
        );
    }
  }

  String _formatPluginError(String? raw, {required String fallback}) {
    final message = raw?.trim();
    if (message == null || message.isEmpty) {
      return fallback;
    }
    return '$fallback $message';
  }

  String _normalizeVersion(String version) {
    var normalized = version.trim();
    if (normalized.toLowerCase().startsWith('v')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  int _compareSemver(String a, String b) {
    final pa = _parseSemver(a);
    final pb = _parseSemver(b);

    for (var i = 0; i < 3; i++) {
      final diff = pa.core[i].compareTo(pb.core[i]);
      if (diff != 0) return diff;
    }

    final aHasPre = pa.preRelease.isNotEmpty;
    final bHasPre = pb.preRelease.isNotEmpty;
    if (!aHasPre && !bHasPre) return 0;
    if (!aHasPre && bHasPre) return 1;
    if (aHasPre && !bHasPre) return -1;

    final maxLen = pa.preRelease.length > pb.preRelease.length
        ? pa.preRelease.length
        : pb.preRelease.length;
    for (var i = 0; i < maxLen; i++) {
      if (i >= pa.preRelease.length) return -1;
      if (i >= pb.preRelease.length) return 1;

      final ida = pa.preRelease[i];
      final idb = pb.preRelease[i];
      final na = int.tryParse(ida);
      final nb = int.tryParse(idb);

      if (na != null && nb != null) {
        final diff = na.compareTo(nb);
        if (diff != 0) return diff;
      } else if (na != null && nb == null) {
        return -1;
      } else if (na == null && nb != null) {
        return 1;
      } else {
        final diff = ida.compareTo(idb);
        if (diff != 0) return diff;
      }
    }

    return 0;
  }

  ({List<int> core, List<String> preRelease}) _parseSemver(String version) {
    final normalized = _normalizeVersion(version).split('+').first;
    final dashIndex = normalized.indexOf('-');
    final coreStr =
        dashIndex == -1 ? normalized : normalized.substring(0, dashIndex);
    final preStr = dashIndex == -1 ? '' : normalized.substring(dashIndex + 1);

    final coreParts = coreStr.split('.');
    int readCore(int index) {
      if (index >= coreParts.length) return 0;
      return int.tryParse(coreParts[index]) ?? 0;
    }

    final preRelease = preStr.isEmpty ? <String>[] : preStr.split('.');
    return (
      core: [readCore(0), readCore(1), readCore(2)],
      preRelease: preRelease,
    );
  }
}

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.tagName,
    required this.releasePageUrl,
    required this.apkUrl,
    required this.releaseNotes,
    required this.publishedAt,
  });

  final String tagName;
  final String releasePageUrl;
  final String? apkUrl;
  final String releaseNotes;
  final DateTime? publishedAt;
}

enum AppUpdateInstallStage {
  downloading,
  installing,
  completed,
  canceled,
  error,
}

class AppUpdateInstallProgress {
  const AppUpdateInstallProgress({
    required this.stage,
    required this.message,
    this.progress,
  });

  final AppUpdateInstallStage stage;
  final String message;
  final int? progress;

  bool get isTerminal =>
      stage == AppUpdateInstallStage.completed ||
      stage == AppUpdateInstallStage.canceled ||
      stage == AppUpdateInstallStage.error;

  bool get isError => stage == AppUpdateInstallStage.error;
}
