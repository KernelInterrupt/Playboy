import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:playboy/backend/library_helper.dart';
import 'package:playboy/widgets/file_card.dart';
import 'package:playboy/widgets/folder_card.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key, required this.path});
  final String path;

  @override
  FileExplorerState createState() => FileExplorerState();
}

class FileExplorerState extends State<FileExplorer> {
  bool loaded = false;
  List<FileSystemEntity> contents = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    Directory dir = Directory(widget.path);
    if (!await dir.exists()) {
      return;
    }
    await for (var item in dir.list()) {
      contents.add(item);
    }

    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = max((width / 150).round(), 2);
    String name = basename(widget.path);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(name),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: loaded
          ? GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: 5 / 6,
              ),
              itemBuilder: (context, index) {
                var e = contents[index];
                if (e is File) {
                  if (LibraryHelper.supportFormats
                      .contains(extension(e.path))) {
                    return FileCard(
                      source: e.path,
                      icon: Icons.audio_file_outlined,
                    );
                  } else {
                    return FileCard(source: e.path, icon: null);
                  }
                } else if (e is Directory) {
                  return FolderCard(source: e.path, icon: null);
                }
                return null;
              },
              itemCount: contents.length,
            )
          : const Center(
              heightFactor: 10,
              child: CircularProgressIndicator(),
            ),
    );
  }
}
