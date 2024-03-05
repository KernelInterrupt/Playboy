import 'dart:io';

import 'package:flutter/material.dart';
import 'package:playboy/backend/models/playitem.dart';
import 'package:playboy/pages/media/m_player.dart';

class MusicCard extends StatelessWidget {
  const MusicCard({super.key, required this.info});
  final PlayItem info;

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Card(
            // surfaceTintColor: Colors.transparent,
            elevation: 1.6,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: InkWell(
              onTap: () {
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => MPlayer(info: info)));
              },
              borderRadius: BorderRadius.circular(20),
              child: info.cover == null
                  ? Ink(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.tertiaryContainer,
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: colorScheme.onTertiaryContainer,
                        size: 80,
                      ),
                    )
                  : Ink(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.tertiaryContainer,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(
                            File(info.cover!),
                          ),
                        ),
                      ),
                      // child: Icon(
                      //   Icons.playlist_play_rounded,
                      //   color: colorScheme.onTertiaryContainer,
                      //   size: 80,
                      // ),
                    ),
            ),
          ),
        ),
        Expanded(child: Text(info.title))
      ],
    );
  }
}