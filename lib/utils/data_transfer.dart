import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:xeonjia/game/models/character_info.dart';
import 'package:xeonjia/utils/config.dart';
import 'package:xeonjia/utils/local_data_controller.dart';
import 'package:xeonjia/utils/settings.dart';

/// Extension used by the backup files
const String backupFileExtension = 'xjbk';

/// Mime type used when saving a backup file
const String backupMimeType = 'application/octet-stream';

/// Magic number ("XEON") placed at the beginning of every backup file
const List<int> _magic = [0x58, 0x45, 0x4F, 0x4E];

/// Revision of the backup container
const int _formatVersion = 1;

/// Key used to sign the content of a backup file.
/// This does not make backups secure (the key is shipped with the app), it
/// only keeps a hand-edited save file from going unnoticed.
const List<int> _signatureKey = [
  0xB2, 0x19, 0xC2, 0x79, 0x39, 0x57, 0xB3, 0x44, //
  0x58, 0x97, 0xBD, 0xAC, 0x03, 0x0A, 0x08, 0xD8, //
  0x72, 0x3B, 0x01, 0xCF, 0x79, 0x39, 0x35, 0xDF, //
  0x31, 0x61, 0x2E, 0xC9, 0xF8, 0x9B, 0xE2, 0x34, //
];

/// Length of the HMAC-SHA256 signature
const int _signatureLength = 32;

/// Magic number + format version + signature
const int _headerLength = 4 + 1 + _signatureLength;

/// Reason why a backup file could not be imported
enum ImportError {
  /// The file is not a Xeonjia backup at all
  notABackup,

  /// The file was written by a newer (unknown) version of the app
  unsupportedVersion,

  /// The file is truncated, damaged or has been edited
  corrupted,
}

/// Name suggested when exporting a backup file
String backupFileName() {
  final now = DateTime.now();
  final date =
      '${_pad(now.year, 4)}${_pad(now.month, 2)}${_pad(now.day, 2)}'
      '-${_pad(now.hour, 2)}${_pad(now.minute, 2)}';
  return 'xeonjia-$date.$backupFileExtension';
}

/// Number with leading zeros, as used in the name of a backup file
String _pad(int value, int length) => value.toString().padLeft(length, '0');

/// Export game data and app settings as the content of a backup file
Uint8List exportData() {
  final payload = utf8.encode(
    jsonEncode({
      'format': _formatVersion,
      'appVersion': Config.version,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'userData': mainCharacter.toJson(),
      'settings': settings.toJson(),
    }),
  );
  final body = GZipEncoder().encodeBytes(payload);
  return Uint8List.fromList([
    ..._magic,
    _formatVersion,
    ..._sign(body),
    ...body,
  ]);
}

/// Restore game data and app settings from the content of a backup file
ImportError? importData(Uint8List bytes) {
  if (bytes.length <= _headerLength) return ImportError.notABackup;
  for (int i = 0; i < _magic.length; i++) {
    if (bytes[i] != _magic[i]) return ImportError.notABackup;
  }
  if (bytes[_magic.length] != _formatVersion) {
    return ImportError.unsupportedVersion;
  }

  final body = bytes.sublist(_headerLength);
  if (!_isSignatureValid(
    bytes.sublist(_magic.length + 1, _headerLength),
    body,
  )) {
    return ImportError.corrupted;
  }

  final CharacterInfo importedCharacter;
  final Settings importedSettings;
  try {
    final data = jsonDecode(
      utf8.decode(GZipDecoder().decodeBytes(body)),
    ) as Map<String, dynamic>;
    importedCharacter = CharacterInfo(
      (data['userData'] as Map).cast<String, dynamic>(),
    );
    importedSettings = Settings(
      (data['settings'] as Map).cast<String, dynamic>(),
    );
  } catch (_) {
    return ImportError.corrupted;
  }

  // Audio availability depends on the device, not on the imported backup
  importedSettings.audioSupported = settings.audioSupported;
  if (!importedSettings.audioSupported) {
    importedSettings.backgroundMusic = false;
    importedSettings.soundEffects = false;
  } else if (!kIsWeb && Platform.isLinux) {
    importedSettings.soundEffects = false;
  }

  mainCharacter = importedCharacter;
  settings = importedSettings;
  saveUserData();
  saveSettings();
  return null;
}

/// Signature of the payload of a backup file
List<int> _sign(List<int> body) =>
    Hmac(sha256, _signatureKey).convert(body).bytes;

/// True if [signature] matches the payload of a backup file
bool _isSignatureValid(List<int> signature, List<int> body) {
  final expected = _sign(body);
  if (signature.length != expected.length) return false;
  int difference = 0;
  for (int i = 0; i < expected.length; i++) {
    difference |= signature[i] ^ expected[i];
  }
  return difference == 0;
}
