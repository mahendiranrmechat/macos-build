import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/window_controls.dart';
import 'package:window_manager/window_manager.dart';
import 'package:archive/archive.dart';

Future<void> downloadAndInstall(String fileUrl, BuildContext context) async {
  try {
    final String fileName = fileUrl.split('/').last;
    final String processToClose = 'psjackpot.exe';
    final String tempDir = Directory.systemTemp.path;
    final String zipPath = '$tempDir\\$fileName';
    final String extractDirPath = '$tempDir\\unzipped';
    final File zipFile = File(zipPath);
    final Directory extractDir = Directory(extractDirPath);

    // 1. Clear old files
    if (zipFile.existsSync()) zipFile.deleteSync();
    if (extractDir.existsSync()) extractDir.deleteSync(recursive: true);

    // 2. Add cache-busting to avoid old cached file
    final cacheBustingUrl = '$fileUrl?t=${DateTime.now().millisecondsSinceEpoch}';

    double downloadProgress = 0.0;
    late StateSetter dialogSetState;
    int lastReportedProgress = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: StatefulBuilder(
            builder: (context, setState) {
              dialogSetState = setState;
              return ModernDownloadDialog(progress: downloadProgress);
            },
          ),
        );
      },
    );

    final http.Client client = http.Client();
    final request = http.Request('GET', Uri.parse(cacheBustingUrl));
    final response = await client.send(request);

    final List<List<int>> chunks = [];
    int downloaded = 0;
    final contentLength = response.contentLength ?? 0;

    await for (final chunk in response.stream) {
      chunks.add(chunk);
      downloaded += chunk.length;

      double newProgress = downloaded / contentLength;
      int percent = (newProgress * 100).toInt();

      if (percent != lastReportedProgress) {
        lastReportedProgress = percent;
        downloadProgress = newProgress;
        if (context.mounted) dialogSetState(() {});
      }
    }

    final bytes = chunks.expand((x) => x).toList();
    await zipFile.writeAsBytes(bytes);

    if (context.mounted) Navigator.of(context).pop();

    final archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());
    extractDir.createSync(recursive: true);

    for (final file in archive) {
      final path = '$extractDirPath\\${file.name}';
      if (file.isFile) {
        final outFile = File(path);
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(path).createSync(recursive: true);
      }
    }

    final exeFiles = extractDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.exe'))
        .toList();

    if (exeFiles.isEmpty) throw Exception("No installer found in archive.");

    final String exePath = exeFiles.first.path;

    if (Platform.isWindows) {
      await _closeRunningProcess(processToClose);
      await Process.start(exePath, [], mode: ProcessStartMode.detached);
    } else if (Platform.isMacOS) {
      await _closeMacApp('psg_lotto');
      await Process.start('open', [exePath], mode: ProcessStartMode.detached);
    }
  } catch (e) {
    debugPrint("Download/Install error: $e");

    if (context.mounted) {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            content: SizedBox(
              width: 350,
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Update Failed",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "An error occurred while updating. You can retry or download manually.",
                    style: TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          downloadAndInstall(fileUrl, context); // Retry
                        },
                        child: const Text("Retry"),
                      ),
                      TextButton(
                        onPressed: () {
                          windowManager.close();
                          _openInBrowser(fileUrl);
                        },
                        child: const Text("Download Manually"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

Future<void> _closeMacApp(String appName) async {
  try {
    final killAllResult = await Process.run('killall', ['-9', appName]);
    debugPrint("killall stdout: ${killAllResult.stdout}");
    debugPrint("killall stderr: ${killAllResult.stderr}");

    final infoResult = await Process.run('hdiutil', ['info']);
    final infoOutput = infoResult.stdout.toString();

    final volumeRegex = RegExp(r'/Volumes/.*');
    final lines = infoOutput.split('\n');
    final volumes = <String>{};

    for (final line in lines) {
      final match = volumeRegex.firstMatch(line);
      if (match != null) {
        volumes.add(match.group(0)!);
      }
    }

    for (final volume in volumes) {
      debugPrint("Attempting to detach volume: $volume");
      final detachResult = await Process.run('hdiutil', ['detach', volume]);
      if (detachResult.exitCode != 0) {
        debugPrint("Detach failed. Retrying...");
        await Future.delayed(const Duration(seconds: 2));
        await Process.run('hdiutil', ['detach', volume]);
      }
    }
  } catch (e) {
    debugPrint("Error closing Mac app: $e");
  }
}

Future<void> _closeRunningProcess(String processName) async {
  try {
    if (Platform.isWindows) {
      await WindowControls.close();
    }
  } catch (e) {
    debugPrint("Process close error: $e");
  }
}

void _openInBrowser(String url) async {
  try {
    if (Platform.isWindows) {
      await Process.start('cmd', ['/c', 'start', url], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.start('open', [url]);
    } else {
      debugPrint("Manual download unsupported on this platform.");
    }
  } catch (e) {
    debugPrint("Error opening browser: $e");
  }
}

class ModernDownloadDialog extends StatelessWidget {
  final double progress;

  const ModernDownloadDialog({Key? key, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Downloading Update",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      final shouldCancel = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Cancel Download"),
                          content: const Text(
                              "Are you sure you want to cancel the update?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text("No"),
                            ),
                            TextButton(
                              onPressed: () {
                                windowManager.close();
                              },
                              child: const Text("Yes"),
                            ),
                          ],
                        ),
                      );
                      if (shouldCancel == true && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Lottie.asset(
                'assets/animations/download.json',
                height: 100,
                repeat: true,
              ),
              const SizedBox(height: 20),
              const Text(
                "Please wait while we download the latest update.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimarySeedColor!),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
