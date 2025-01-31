import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:media_kit/media_kit.dart';
import 'package:playboy/backend/utils/hash.dart';
import 'package:playboy/backend/models/playitem.dart';
import 'package:playboy/backend/models/playlist_item.dart';
import 'package:path/path.dart';
import 'package:playboy/backend/storage.dart';
import 'package:process_run/process_run.dart';

class LibraryHelper {
  static const supportFormats = [
    '.avi',
    '.flv',
    '.mkv',
    '.mov',
    '.mp4',
    '.mpeg',
    '.webm',
    '.wmv',
    '.aac',
    '.midi',
    '.mp3',
    '.ogg',
    '.wav',
  ];
  static const imageFormats = [
    'jpg',
    'png',
    'webp',
    'bmp',
    'wbmp',
  ];

  static Playlist convertToPlaylist(PlaylistItem playlistItem) {
    List<Media> res = [];
    for (var item in playlistItem.items) {
      res.add(Media(item.source));
    }
    return Playlist(res);
  }

  static Future<List<PlayItem>> getMediaFromPaths(List<String> paths) async {
    List<PlayItem> res = [];
    var thumbnailsPath = "${AppStorage().dataPath}\\thumbnails";
    var vis = <String>{};

    Queue q = Queue();
    for (var path in paths) {
      if (vis.contains(path)) continue;
      vis.add(path);
      q.add(path);
    }

    vis.clear();
    while (q.isNotEmpty) {
      int n = q.length;
      for (int i = 0; i < n; i++) {
        var p = q.removeFirst();
        if (vis.contains(p)) continue;
        vis.add(p);
        var dir = Directory(p);
        await for (var item in dir.list()) {
          if (item is Directory) {
            if (vis.contains(item.path)) continue;
            q.add(item.path);
          } else if (supportFormats.contains(extension(item.path))) {
            if (AppStorage().settings.getCoverOnScan) {
              await saveThumbnail(item.path);
            }
            var hashedPath = hashPath(item.path);
            var outputPath = "$thumbnailsPath\\$hashedPath.jpg";
            res.add(
              PlayItem(
                source: item.path,
                cover: outputPath,
                title: basenameWithoutExtension(item.path),
              ),
            );
          }
        }
      }
    }

    return res;
  }

  static Future<void> saveThumbnail(String path) async {
    var thumbnailsPath = "${AppStorage().dataPath}\\thumbnails";
    var fp = Directory(thumbnailsPath);
    if (!await fp.exists()) {
      await fp.create();
    }
    var hashedPath = hashPath(path);
    var outputPath = "$thumbnailsPath\\$hashedPath.jpg";
    if (await File(outputPath).exists()) return;
    var shell = Shell();
    try {
      // call ffmpeg to get the frame at 00:00:05
      await shell.run(
          'ffmpeg -progress - -i "$path" -y -ss 0:00:05.000000 -frames:v 1 -q:v 1 "$outputPath"');
    } catch (e) {
      // print(e.toString());
    }
    // return outputPath;
  }

  static Future<PlayItem?> getItemFromDirectory(Directory dir) async {
    String source = dir.path;
    String title = basenameWithoutExtension(source);
    // source += '/$title.mp4';
    bool found = false;
    String media = '';
    for (var ext in supportFormats) {
      media = '$source/$title.$ext';
      if (await File(media).exists()) {
        found = true;
        break;
      }
    }
    if (!found) {
      return null;
    }
    String cover = '${dir.path}/cover.jpg';
    if (!await File(cover).exists()) {
      return PlayItem(source: media, cover: null, title: title);
    } else {
      return PlayItem(source: media, cover: cover, title: title);
    }
  }

  static Future<PlayItem> getItemFromFile(String src) async {
    var coverPath = '${dirname(src)}/cover.jpg';
    if (await File(coverPath).exists()) {
      return PlayItem(
          source: src, cover: coverPath, title: basenameWithoutExtension(src));
    } else {
      return PlayItem(
          source: src, cover: null, title: basenameWithoutExtension(src));
    }
  }

  static Future<List<PlaylistItem>> loadPlaylists() async {
    var playlists = <PlaylistItem>[];
    var dir = Directory('${AppStorage().dataPath}/playlists/');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await for (var item in dir.list()) {
      if (item is File && extension(item.path) == '.json') {
        var pl = PlaylistItem.fromJson(jsonDecode(await item.readAsString()));
        var cover = '${withoutExtension(item.path)}.cover.jpg';
        if (await File(cover).exists()) {
          pl.cover = cover;
        } else {
          pl.cover = null;
        }
        playlists.add(pl);
      }
    }
    return playlists;
  }

  static void savePlaylist(PlaylistItem pl) {
    var fp = File('${AppStorage().dataPath}/playlists/${pl.uuid}.json');
    if (!fp.existsSync()) {
      fp.createSync(recursive: true);
    }
    var data = pl.toJson();
    fp.writeAsString(jsonEncode(data));
  }

  static void deletePlaylist(PlaylistItem pl) {
    var fp = File('${AppStorage().dataPath}/playlists/${pl.uuid}.json');
    if (fp.existsSync()) {
      fp.deleteSync();
    }

    var cover = File('${AppStorage().dataPath}/playlists/${pl.uuid}.cover.jpg');
    if (cover.existsSync()) {
      cover.deleteSync();
    }
  }

  static void addItemToPlaylist(PlaylistItem pl, PlayItem p) {
    pl.items.add(p);
    savePlaylist(pl);
  }

  static void removeItemFromPlaylist(PlaylistItem pl, PlayItem p) {
    pl.items.remove(p);
    savePlaylist(pl);
  }

  static void renamePlaylist(PlaylistItem pl, String name) {
    pl.title = name;
    savePlaylist(pl);
  }
}
