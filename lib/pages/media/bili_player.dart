import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playboy/backend/biliapi/models/video_info.dart';
import 'package:playboy/backend/biliapi/models/video_stream_response.dart';
import 'package:playboy/backend/storage.dart';
import 'package:playboy/backend/web_helper.dart';
import 'package:playboy/pages/media/video_fullscreen.dart';
import 'package:squiggly_slider/slider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class BiliPlayer extends StatefulWidget {
  const BiliPlayer(
      {super.key, required this.videoInfo, required this.playInfo});
  final VideoInfo videoInfo;
  final Dash playInfo;

  @override
  BiliPlayerState createState() => BiliPlayerState();
}

class BiliPlayerState extends State<BiliPlayer> {
  late final player = AppStorage().playboy;
  late final controller = VideoController(player);

  bool menuExpanded = false;
  bool videoMode = true;
  // bool loop = false;
  // bool shuffle = false;
  // bool fullScreen = false;

  // bool seeking = false;
  // double seekingPos = 0;

  @override
  void initState() {
    super.initState();
    final video = Media(widget.playInfo.video[0].baseUrl!, httpHeaders: {
      'referer': 'https://www.bilibili.com',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'
    });
    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer)
          .setProperty('audio-files', widget.playInfo.audio[0].baseUrl!);
    }
    player.open(video);
    AppStorage().playboy.setVolume(AppStorage().settings.volume);
    AppStorage().position = Duration.zero;
    AppStorage().duration = Duration.zero;
    AppStorage().playingTitle = widget.videoInfo.title;
    // TODO: dynamic color
    // AppStorage().playingCover = widget.info.cover;
  }

  @override
  void dispose() {
    // player.dispose();
    // player.stop();
    // if (player.platform is NativePlayer) {
    //   (player.platform as NativePlayer).setProperty('audio-files', '');
    // }
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   late final colorScheme = Theme.of(context).colorScheme;
  //   late final backgroundColor = Color.alphaBlend(
  //       colorScheme.primary.withOpacity(0.08), colorScheme.surface);
  //   return Scaffold(
  //     backgroundColor: backgroundColor,
  //     appBar: AppBar(
  //       toolbarHeight: 50,
  //       flexibleSpace: GestureDetector(
  //         behavior: HitTestBehavior.translucent,
  //         onPanStart: (details) {
  //           windowManager.startDragging();
  //         },
  //       ),
  //       // toolbarHeight: videoMode ? null : 70,
  //       backgroundColor: backgroundColor,
  //       scrolledUnderElevation: 0,
  //       title: videoMode
  //           ? GestureDetector(
  //               behavior: HitTestBehavior.translucent,
  //               onPanStart: (details) {
  //                 windowManager.startDragging();
  //               },
  //               child: Text(
  //                 widget.videoInfo.title,
  //               ))
  //           : const SizedBox(),
  //       actions: [
  //         IconButton(
  //           isSelected: menuExpanded,
  //           icon: const Icon(Icons.view_sidebar_outlined),
  //           selectedIcon: const Icon(Icons.view_sidebar),
  //           onPressed: () {
  //             setState(() {
  //               menuExpanded = !menuExpanded;
  //             });
  //           },
  //         ),
  //         IconButton(
  //             hoverColor: Colors.transparent,
  //             iconSize: 20,
  //             onPressed: () {
  //               windowManager.minimize();
  //             },
  //             icon: const Icon(Icons.minimize)),
  //         IconButton(
  //             hoverColor: Colors.transparent,
  //             iconSize: 20,
  //             onPressed: () async {
  //               if (await windowManager.isMaximized()) {
  //                 windowManager.unmaximize();
  //               } else {
  //                 windowManager.maximize();
  //               }
  //             },
  //             icon: const Icon(Icons.crop_square)),
  //         IconButton(
  //             hoverColor: Colors.transparent,
  //             iconSize: 20,
  //             onPressed: () {
  //               windowManager.close();
  //             },
  //             icon: const Icon(Icons.close)),
  //         const SizedBox(
  //           width: 10,
  //         )
  //       ],
  //     ),
  //     // Use a FutureBuilder to display a loading spinner while waiting for the
  //     // VideoPlayerController to finish initializing.
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 // flex: 3,
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 10),
  //                   child: ClipRRect(
  //                       borderRadius:
  //                           const BorderRadius.all(Radius.circular(25)),
  //                       child: videoMode
  //                           ? Container(
  //                               color: Colors.black,
  //                               child: Center(
  //                                 child: Video(
  //                                   controller: controller,
  //                                   controls: NoVideoControls,
  //                                 ),
  //                               )
  //                               // const Center(
  //                               //     child: CircularProgressIndicator(),
  //                               //   )
  //                               ,
  //                             )
  //                           : Container(
  //                               padding: const EdgeInsets.only(
  //                                   top: 50, left: 50, right: 50, bottom: 75),
  //                               alignment: Alignment.center,
  //                               child: AspectRatio(
  //                                 aspectRatio: 1,
  //                                 child: DecoratedBox(
  //                                   decoration: BoxDecoration(
  //                                     borderRadius: BorderRadius.circular(16),
  //                                     image: DecorationImage(
  //                                       image: NetworkImage(
  //                                           widget.videoInfo.coverUrl),
  //                                       fit: BoxFit.cover,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             )),
  //                 ),
  //               ),
  //               menuExpanded
  //                   ? Padding(
  //                       // flex: 2,
  //                       padding: const EdgeInsets.only(right: 10),
  //                       child: SizedBox(
  //                         width: videoMode
  //                             ? 300
  //                             : MediaQuery.of(context).size.width * 0.4,
  //                         child: ClipRRect(
  //                             borderRadius:
  //                                 const BorderRadius.all(Radius.circular(25)),
  //                             child: DefaultTabController(
  //                               initialIndex: 0,
  //                               length: 2,
  //                               child: Scaffold(
  //                                 backgroundColor: videoMode
  //                                     ? colorScheme.background
  //                                     : backgroundColor,
  //                                 appBar: const TabBar(
  //                                   tabs: <Widget>[
  //                                     Tab(
  //                                       icon: Icon(Icons.lyrics),
  //                                     ),
  //                                     Tab(
  //                                       icon: Icon(Icons.menu),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 body: const TabBarView(
  //                                   children: <Widget>[
  //                                     Center(
  //                                       child: Text("No lyrics"),
  //                                     ),
  //                                     Center(
  //                                       child: Text("Playlist"),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             )),
  //                       ))
  //                   : const SizedBox(),
  //             ],
  //           ),
  //         ),
  //         SizedBox(
  //           width: videoMode
  //               ? MediaQuery.of(context).size.width - 40
  //               : MediaQuery.of(context).size.width - 80,
  //           height: 25,
  //           child: SliderTheme(
  //               data: SliderThemeData(
  //                 // trackHeight: videoMode ? 8 : null,
  //                 overlayShape: SliderComponentShape.noOverlay,
  //               ),
  //               child: StreamBuilder(
  //                   stream: player.stream.position,
  //                   builder: (context, snapshot) {
  //                     return SquigglySlider(
  //                       squiggleAmplitude: videoMode ? 0 : 2,
  //                       squiggleWavelength: 5,
  //                       squiggleSpeed: 0.05,
  //                       max: player.state.duration.inMilliseconds.toDouble(),
  //                       value: seeking
  //                           ? seekingPos
  //                           : (snapshot.hasData
  //                               ? min(
  //                                   snapshot.data!.inMilliseconds.toDouble(),
  //                                   player.state.duration.inMilliseconds
  //                                       .toDouble())
  //                               : 0),
  //                       onChanged: (value) {
  //                         // player.seek(Duration(milliseconds: value.toInt()));
  //                         setState(() {
  //                           seekingPos = value;
  //                         });
  //                       },
  //                       onChangeStart: (value) {
  //                         setState(() {
  //                           seeking = true;
  //                         });
  //                       },
  //                       onChangeEnd: (value) {
  //                         player
  //                             .seek(Duration(milliseconds: value.toInt()))
  //                             .then((value) => {
  //                                   setState(() {
  //                                     seeking = false;
  //                                   })
  //                                 });
  //                       },
  //                     );
  //                   })),
  //         ),
  //         SizedBox(
  //           height: videoMode ? 60 : 100,
  //           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //             IconButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     shuffle = !shuffle;
  //                   });
  //                 },
  //                 icon: shuffle
  //                     ? const Icon(Icons.shuffle_on)
  //                     : const Icon(Icons.shuffle)),
  //             const SizedBox(
  //               width: 10,
  //             ),
  //             IconButton(
  //                 onPressed: () {
  //                   if (player.state.playlistMode == PlaylistMode.single) {
  //                     player.setPlaylistMode(PlaylistMode.none);
  //                   } else {
  //                     player.setPlaylistMode(PlaylistMode.single);
  //                   }
  //                   setState(() {});
  //                 },
  //                 icon: player.state.playlistMode == PlaylistMode.single
  //                     ? const Icon(Icons.repeat_one_on)
  //                     : const Icon(Icons.repeat_one)),
  //             const SizedBox(
  //               width: 10,
  //             ),
  //             IconButton.filledTonal(
  //                 iconSize: 30,
  //                 onPressed: () {},
  //                 icon: const Icon(Icons.skip_previous_outlined)),
  //             const SizedBox(
  //               width: 10,
  //             ),
  //             IconButton.filled(
  //               style: IconButton.styleFrom(
  //                 // backgroundColor: colorScheme.tertiary,
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(20)),
  //               ),
  //               iconSize: 40,
  //               // color: colorScheme.onTertiary,
  //               onPressed: () {
  //                 setState(() {
  //                   player.playOrPause();
  //                 });
  //               },
  //               icon: StreamBuilder(
  //                 stream: player.stream.playing,
  //                 builder: (context, playing) => Icon(
  //                   playing.data == true
  //                       ? Icons.pause_circle_outline
  //                       : Icons.play_arrow_outlined,
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(
  //               width: 10,
  //             ),
  //             IconButton.filledTonal(
  //                 iconSize: 30,
  //                 onPressed: () {},
  //                 icon: const Icon(Icons.skip_next_outlined)),
  //             const SizedBox(
  //               width: 10,
  //             ),
  //             IconButton(
  //               icon: videoMode
  //                   ? const Icon(Icons.music_note_outlined)
  //                   : const Icon(Icons.music_video_outlined),
  //               onPressed: () {
  //                 setState(() {
  //                   videoMode = !videoMode;
  //                 });
  //               },
  //             ),
  //             const SizedBox(
  //               width: 10,
  //             ),
  //             IconButton(
  //                 onPressed: () async {
  //                   windowManager.setFullScreen(true);

  //                   if (!mounted) return;
  //                   Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (context) => FullscreenPlayPage(
  //                                 controller: controller,
  //                               )));
  //                 },
  //                 icon: const Icon(Icons.fullscreen)),
  //           ]),
  //         ),
  //         const SizedBox(
  //           height: 10,
  //         )
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    late final backgroundColor = Color.alphaBlend(
        colorScheme.primary.withOpacity(0.08), colorScheme.surface);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildTitlebar(backgroundColor),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  // flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildPlayer(colorScheme),
                  ),
                ),
                menuExpanded
                    ? Padding(
                        // flex: 2,
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: videoMode
                              ? 300
                              : MediaQuery.of(context).size.width * 0.4,
                          child: _buildSidePanel(colorScheme, backgroundColor),
                        ))
                    : const SizedBox(),
              ],
            ),
          ),
          SizedBox(
            width: videoMode
                ? MediaQuery.of(context).size.width - 40
                : MediaQuery.of(context).size.width - 80,
            height: 25,
            child: Row(
              children: [
                StreamBuilder(
                    stream: AppStorage().playboy.stream.position,
                    builder: (context, snapshot) {
                      return Text(snapshot.hasData
                          ? '${snapshot.data!.inSeconds ~/ 3600}:${(snapshot.data!.inSeconds % 3600 ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data!.inSeconds % 60).toString().padLeft(2, '0')}'
                          : '0:00:00');
                    }),
                Expanded(child: _buildSeekbar()),
                StreamBuilder(
                    stream: AppStorage().playboy.stream.duration,
                    builder: (context, snapshot) {
                      return Text(snapshot.hasData
                          ? '${snapshot.data!.inSeconds ~/ 3600}:${(snapshot.data!.inSeconds % 3600 ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data!.inSeconds % 60).toString().padLeft(2, '0')}'
                          : '0:00:00');
                    }),
              ],
            ),
          ),
          SizedBox(
            height: videoMode ? 60 : 100,
            child: _buildControlbar(colorScheme),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTitlebar(Color backgroundColor) {
    return AppBar(
      toolbarHeight: 50,
      flexibleSpace: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
      ),
      // toolbarHeight: videoMode ? null : 70,
      backgroundColor: backgroundColor,
      scrolledUnderElevation: 0,
      title: videoMode
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: Text(
                widget.videoInfo.title,
              ))
          : const SizedBox(),
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            setState(() {
              WebHelper().download(widget.playInfo.audio[0].baseUrl!,
                  './build/downloads/${widget.videoInfo.title}.audio.m4s');
              WebHelper().download(widget.playInfo.video[0].baseUrl!,
                  './build/downloads/${widget.videoInfo.title}.video.m4s');
            });
          },
        ),
        IconButton(
          isSelected: menuExpanded,
          icon: const Icon(Icons.view_sidebar_outlined),
          selectedIcon: const Icon(Icons.view_sidebar),
          onPressed: () {
            setState(() {
              menuExpanded = !menuExpanded;
            });
          },
        ),
        IconButton(
            hoverColor: Colors.transparent,
            iconSize: 20,
            onPressed: () {
              windowManager.minimize();
            },
            icon: const Icon(Icons.minimize)),
        IconButton(
            hoverColor: Colors.transparent,
            iconSize: 20,
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
            icon: const Icon(Icons.crop_square)),
        IconButton(
            hoverColor: Colors.transparent,
            iconSize: 20,
            onPressed: () {
              windowManager.close();
            },
            icon: const Icon(Icons.close)),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }

  Widget _buildPlayer(ColorScheme colorScheme) {
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        child: videoMode
            ? Container(
                color: Colors.black,
                child: Center(
                  child: Video(
                    controller: controller,
                    controls: NoVideoControls,
                    subtitleViewConfiguration:
                        const SubtitleViewConfiguration(visible: false),
                  ),
                )
                // const Center(
                //     child: CircularProgressIndicator(),
                //   )
                ,
              )
            : Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 50, right: 50, bottom: 75),
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(widget.videoInfo.coverUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ));
  }

  Widget _buildSeekbar() {
    return SliderTheme(
      data: SliderThemeData(
        // trackHeight: videoMode ? 8 : null,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: SquigglySlider(
        squiggleAmplitude: videoMode ? 0 : 2,
        squiggleWavelength: 5,
        squiggleSpeed: 0.05,
        max: AppStorage().duration.inMilliseconds.toDouble(),
        value: AppStorage().seeking
            ? AppStorage().seekingPos
            : min(AppStorage().position.inMilliseconds.toDouble(),
                AppStorage().duration.inMilliseconds.toDouble()),
        onChanged: (value) {
          // player.seek(Duration(milliseconds: value.toInt()));
          setState(() {
            AppStorage().seekingPos = value;
          });
        },
        onChangeStart: (value) {
          setState(() {
            AppStorage().seeking = true;
          });
        },
        onChangeEnd: (value) {
          AppStorage()
              .playboy
              .seek(Duration(milliseconds: value.toInt()))
              .then((value) => {
                    setState(() {
                      AppStorage().seeking = false;
                    })
                  });
        },
      ),
    );
  }

  Widget _buildSidePanel(ColorScheme colorScheme, Color backgroundColor) {
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        child: DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Scaffold(
            backgroundColor:
                videoMode ? colorScheme.background : backgroundColor,
            appBar: const TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.calendar_view_month),
                ),
                Tab(
                  icon: Icon(Icons.menu),
                ),
              ],
            ),
            body: const TabBarView(
              children: <Widget>[
                Center(
                  child: Text("所有分集"),
                ),
                Center(
                  child: Text("当前列表"),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildControlbar(ColorScheme colorScheme) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
        child: Row(
          children: [
            SizedBox(
              width: videoMode ? 16 : 32,
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    if (AppStorage().settings.silent) {
                      AppStorage().settings.silent = false;
                      AppStorage()
                          .playboy
                          .setVolume(AppStorage().settings.volume);
                    } else {
                      AppStorage().settings.silent = true;
                      AppStorage().playboy.setVolume(0);
                    }
                  });
                },
                icon: Icon(AppStorage().settings.silent
                    ? Icons.volume_off
                    : Icons.volume_up)),
            SizedBox(
              width: 100,
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: colorScheme.secondaryContainer,
                  thumbColor: colorScheme.onSecondaryContainer,
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  max: 100,
                  value: AppStorage().settings.volume,
                  onChanged: (value) {
                    // player.seek(Duration(milliseconds: value.toInt()));
                    setState(() {
                      AppStorage().settings.volume = value;
                      AppStorage().saveSettings();
                      if (!AppStorage().settings.silent) {
                        AppStorage().playboy.setVolume(value);
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      IconButton(
          onPressed: () {
            setState(() {
              AppStorage().shuffle = !AppStorage().shuffle;
            });
          },
          icon: AppStorage().shuffle
              ? const Icon(Icons.shuffle_on)
              : const Icon(Icons.shuffle)),
      const SizedBox(
        width: 10,
      ),
      IconButton(
          onPressed: () {
            if (AppStorage().playboy.state.playlistMode ==
                PlaylistMode.single) {
              AppStorage().playboy.setPlaylistMode(PlaylistMode.none);
            } else {
              AppStorage().playboy.setPlaylistMode(PlaylistMode.single);
            }
            setState(() {});
          },
          icon: AppStorage().playboy.state.playlistMode == PlaylistMode.single
              ? const Icon(Icons.repeat_one_on)
              : const Icon(Icons.repeat_one)),
      const SizedBox(
        width: 10,
      ),
      IconButton.filledTonal(
          iconSize: 30,
          onPressed: () {},
          icon: const Icon(Icons.skip_previous_outlined)),
      const SizedBox(
        width: 10,
      ),
      IconButton.filled(
        style: IconButton.styleFrom(
          // backgroundColor: colorScheme.tertiary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        iconSize: 40,
        // color: colorScheme.onTertiary,
        // onPressed: () {
        //   setState(() {
        //     // AppStorage().playboy.playOrPause();
        //     if (AppStorage().playing) {
        //       AppStorage().playboy.pause();
        //       AppStorage().playing = false;
        //     } else {
        //       AppStorage().playboy.play();
        //       AppStorage().playing = true;
        //     }
        //   });
        // },
        // icon: Icon(
        //   AppStorage().playing
        //       ? Icons.pause_circle_outline
        //       : Icons.play_arrow_outlined,
        // ),
        onPressed: () {
          setState(() {
            AppStorage().playboy.playOrPause();
            // AppStorage().playing = AppStorage().playboy.state.playing;
          });
        },
        icon: StreamBuilder(
          stream: AppStorage().playboy.stream.playing,
          builder: (context, playing) => Icon(
            playing.data == true
                ? Icons.pause_circle_outline
                : Icons.play_arrow_outlined,
          ),
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      IconButton.filledTonal(
          iconSize: 30,
          onPressed: () {},
          icon: const Icon(Icons.skip_next_outlined)),
      const SizedBox(
        width: 10,
      ),
      IconButton(
        icon: videoMode
            ? const Icon(Icons.music_note_outlined)
            : const Icon(Icons.music_video_outlined),
        onPressed: () {
          setState(() {
            videoMode = !videoMode;
          });
        },
      ),
      const SizedBox(
        width: 10,
      ),
      IconButton(
          onPressed: () async {
            windowManager.setFullScreen(true);

            if (!mounted) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FullscreenPlayPage(
                          controller: controller,
                        )));
          },
          icon: const Icon(Icons.fullscreen)),
      Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 100,
            child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: colorScheme.secondaryContainer,
                  thumbColor: colorScheme.onSecondaryContainer,
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  max: 4,
                  value: AppStorage().playboy.state.rate,
                  onChanged: (value) {
                    // player.seek(Duration(milliseconds: value.toInt()));
                    setState(() {
                      AppStorage().playboy.setRate(value);
                    });
                  },
                )),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  AppStorage().playboy.setRate(1);
                });
              },
              icon: Icon(AppStorage().playboy.state.rate == 1
                  ? Icons.flash_off
                  : Icons.flash_on)),
          SizedBox(
            width: videoMode ? 16 : 32,
          ),
        ],
      )),
    ]);
  }
}
