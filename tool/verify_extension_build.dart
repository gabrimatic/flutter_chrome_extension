import 'dart:convert';
import 'dart:io';

void main() {
  final buildDirectory = Directory('build/web');
  expectDirectory(buildDirectory);

  final manifestFile = File('${buildDirectory.path}/manifest.json');
  final indexFile = File('${buildDirectory.path}/index.html');
  final mainScriptFile = File('${buildDirectory.path}/main.dart.js');

  expectFile(manifestFile);
  expectFile(indexFile);
  expectFile(mainScriptFile);

  final manifest = readJsonObject(manifestFile);
  expectValue(manifest['manifest_version'], 3, 'manifest_version');
  expectValue(manifest['name'], 'Flutter Chrome Extension', 'name');
  expectValue(manifest['version'], '1.1.0', 'version');

  final action = expectObject(manifest['action'], 'action');
  expectValue(action['default_popup'], 'index.html', 'action.default_popup');

  final contentSecurityPolicy = expectObject(
    manifest['content_security_policy'],
    'content_security_policy',
  );
  final extensionPages = expectString(
    contentSecurityPolicy['extension_pages'],
    'content_security_policy.extension_pages',
  );
  expectContains(extensionPages, "script-src 'self'", 'extension CSP');
  expectContains(extensionPages, "object-src 'self'", 'extension CSP');
  expectAbsent(extensionPages, "'unsafe-eval'", 'extension CSP');

  expectEmptyList(manifest['permissions'], 'permissions');
  expectEmptyList(manifest['host_permissions'], 'host_permissions');

  final icons = expectObject(manifest['icons'], 'icons');
  for (final entry in icons.entries) {
    expectFile(File('${buildDirectory.path}/${entry.value}'));
  }

  final defaultIcon = expectObject(
    action['default_icon'],
    'action.default_icon',
  );
  for (final entry in defaultIcon.entries) {
    expectFile(File('${buildDirectory.path}/${entry.value}'));
  }

  final indexHtml = indexFile.readAsStringSync();
  expectContains(indexHtml, 'main.dart.js', 'index.html');
  expectAbsent(indexHtml, 'https://', 'index.html');
  expectAbsent(indexHtml, 'http://', 'index.html');
  expectAbsent(indexHtml, '<script>', 'index.html');

  final sourceMaps = buildDirectory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.map'))
      .toList();
  if (sourceMaps.isNotEmpty) {
    fail('Expected no source maps, found ${sourceMaps.map((f) => f.path)}');
  }

  stdout.writeln('Extension build verified: ${buildDirectory.path}');
}

Map<String, Object?> readJsonObject(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is Map<String, Object?>) {
    return decoded;
  }
  fail('${file.path} must contain a JSON object.');
}

Map<String, Object?> expectObject(Object? value, String label) {
  if (value is Map<String, Object?>) {
    return value;
  }
  fail('$label must be a JSON object.');
}

String expectString(Object? value, String label) {
  if (value is String) {
    return value;
  }
  fail('$label must be a string.');
}

void expectValue(Object? actual, Object? expected, String label) {
  if (actual != expected) {
    fail('$label must be $expected, found $actual.');
  }
}

void expectContains(String actual, String expected, String label) {
  if (!actual.contains(expected)) {
    fail('$label must contain $expected.');
  }
}

void expectAbsent(String actual, String value, String label) {
  if (actual.contains(value)) {
    fail('$label must not contain $value.');
  }
}

void expectEmptyList(Object? value, String label) {
  if (value == null) {
    return;
  }
  if (value is List && value.isEmpty) {
    return;
  }
  fail('$label must be absent or empty.');
}

void expectDirectory(Directory directory) {
  if (!directory.existsSync()) {
    fail('Missing directory: ${directory.path}');
  }
}

void expectFile(File file) {
  if (!file.existsSync()) {
    fail('Missing file: ${file.path}');
  }
}

Never fail(String message) {
  stderr.writeln(message);
  exitCode = 1;
  throw StateError(message);
}
