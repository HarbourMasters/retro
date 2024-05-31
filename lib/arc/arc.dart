// ignore_for_file: sort_constructors_first, cascade_invocations

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_defines.dart';
import 'package:retro/utils/log.dart';

enum ArcMode {
  otr, o2r
}

class Arc {
  static ZipDecoder zdec = ZipDecoder();
  static ZipEncoder zenc = ZipEncoder();

  dynamic handle;
  String path;

  Arc(this.path) {
    final mode = path.endsWith('.otr') ? ArcMode.otr : ArcMode.o2r;
    final file = File(path);

    switch (mode) {
      case ArcMode.otr:
        if(file.existsSync()) {
          handle = MPQArchive.open(path, 0, 0);
        } else {
          handle = MPQArchive.create(path, MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V2, 65535);
        }
        break;
      case ArcMode.o2r:
        if(file.existsSync()) {
          handle = zdec.decodeBytes(file.readAsBytesSync());
        } else {
          handle = Archive();
        }
        break;
    }
  }

  Future<List<String>?> _listMPQFiles({ FutureOr<void> Function(String, Uint8List)? onFile }) async {
    final files = <String>[];
    try {
      var fileFound = false;

      final mpqArchive = handle as MPQArchive;
      final hFind = FileFindResource();
      mpqArchive.findFirstFile('*', hFind, null);

      final fileName = hFind.fileName();
      if (fileName != null && fileName != '(signature)' && fileName != '(listfile)' && fileName != '(attributes)') {
        files.add(fileName);
      }

      do {
        try {
          mpqArchive.findNextFile(hFind);
          fileFound = true;
          final fileName = hFind.fileName();
          log('File name: $fileName');
          if (fileName != null && fileName != '(signature)' && fileName != '(listfile)' && fileName != '(attributes)') {
            files.add(fileName);
            if(onFile != null) {
              final file = mpqArchive.openFileEx(fileName, 0);
              await onFile(fileName, file.read(file.size()));
            }
          }
        } on StormLibException catch (e) {
          log('Failed to find next file: ${e.message}');
          fileFound = false;
        }
      } while (fileFound);

      hFind.close();
      mpqArchive.close();
      return files;
    } on StormLibException catch (e) {
      log('Failed to set locale: ${e.message}');
      return null;
    }
  }

  Future<List<String>?> _listZipFiles({ FutureOr<void> Function(String, Uint8List)? onFile }) async {
    final files = <String>[];
    final archive = handle as Archive;
    for (final file in archive) {
      files.add(file.name);
      if(onFile != null) {
        await onFile(file.name, file.content as Uint8List);
      }
    }
    return files;
  }

  void _addMPQFile(String path, Uint8List data) {
    final mpqArchive = handle as MPQArchive;
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    mpqArchive.createFile(path, timestamp, data.length, 0, 0)
      ..write(data, data.length, MPQ_COMPRESSION_ZLIB)
      ..finish();
  }

  void _addZipFile(String path, Uint8List data) {
    final archive = handle as Archive;
    archive.addFile(ArchiveFile(path, data.length, data));
  }

  void _closeMPQ() {
    final mpqArchive = handle as MPQArchive;
    mpqArchive.close();
  }

  void _closeZip() {
    final archive = handle as Archive;
    final file = File(path);
    final fileBytes = zenc.encode(archive);
    if(fileBytes == null) {
      throw Exception('Failed to encode archive');
    }
    file.writeAsBytesSync(fileBytes);
  }

  Future<List<String>?> listItems({ FutureOr<void> Function(String, Uint8List)? onFile }) {
    if(handle is MPQArchive) {
      return _listMPQFiles(onFile: onFile);
    } else {
      return _listZipFiles(onFile: onFile);
    }
  }

  void addFile(String path, Uint8List data) {
    if(handle is MPQArchive) {
      return _addMPQFile(path, data);
    } else {
      return _addZipFile(path, data);
    }
  }

  void close() {
    if(handle is MPQArchive) {
      return _closeMPQ();
    } else {
      return _closeZip();
    }
  }
}
