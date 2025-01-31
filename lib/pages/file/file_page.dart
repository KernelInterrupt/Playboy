import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:playboy/backend/biliapi/bilibili_helper.dart';
import 'package:playboy/backend/models/playitem.dart';
import 'package:playboy/backend/storage.dart';
import 'package:playboy/backend/utils/route.dart';
// import 'package:playboy/pages/file/download_page.dart';
// import 'package:playboy/pages/media/bili_player.dart';
import 'package:playboy/pages/media/m_player.dart';
import 'package:playboy/widgets/folder_card.dart';
import 'package:provider/provider.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  final TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppStorage().updateFilePage = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    // int n = AppStorage().settings.musicPaths.length;
    int n = context.read<AppStorage>().settings.musicPaths.length;
    final width = MediaQuery.of(context).size.width;
    final cols = max((width / 150).round(), 2);
    // late final colorScheme = Theme.of(context).colorScheme;
    // late final backgroundColor = Color.alphaBlend(
    //     colorScheme.primary.withOpacity(0.08), colorScheme.surface);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 16, bottom: 16),
              title: Text(
                '文件',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 25,
                    fontWeight: FontWeight.w500),
              ),
              // background:
            ),
            pinned: true,
            expandedHeight: 80,
            collapsedHeight: 60,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildOption(Icons.folder_open, '播放文件夹', () async {
                var res = await FilePicker.platform
                    .getDirectoryPath(lockParentWindow: true);
                if (res != null) {
                  String link = res;
                  _openLink(link);
                }
              }),
              _buildOption(Icons.insert_drive_file_outlined, '播放本地文件',
                  () async {
                var res =
                    await FilePicker.platform.pickFiles(lockParentWindow: true);
                if (res != null) {
                  String link = res.files.single.path!;
                  _openLink(link);
                }
              }),
              _buildOption(Icons.link, '打开网络串流', () {
                editingController.clear();
                showDialog(
                  useRootNavigator: false,
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    surfaceTintColor: Colors.transparent,
                    title: const Text('打开网络串流'),
                    content: TextField(
                      autofocus: true,
                      maxLines: 1,
                      controller: editingController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                        labelText: 'URL',
                      ),
                      onSubmitted: (value) async {
                        // if (value.startsWith('BV')) {
                        //   _openLink(value, true);
                        // } else {
                        //   _openLink(value, false);
                        // }
                        _openLink(value);
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // if (editingController.text.startsWith('BV')) {
                          //   _openLink(editingController.text, true);
                          // } else {
                          //   _openLink(editingController.text, false);
                          // }
                          _openLink(editingController.text);
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              }),
              _buildOption(Icons.file_download_outlined, '下载管理', null
                  // () {
                  //   Navigator.push(
                  //     context,
                  //     PageRouteBuilder(
                  //       pageBuilder: (context, animation1, animation2) =>
                  //           const DownloadPage(),
                  //       transitionDuration: Duration.zero,
                  //       reverseTransitionDuration: Duration.zero,
                  //     ),
                  //   );
                  // }
                  ),
              _buildOption(Icons.live_tv, 'BV Tools', null),
            ]),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Text(
                '媒体库',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                // childAspectRatio: 10 / 9,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index >= n) {
                    return FolderCard(
                      source: AppStorage().settings.videoPaths[index - n],
                      icon: Icons.movie_filter,
                    );
                  } else {
                    return FolderCard(
                      source: AppStorage().settings.musicPaths[index],
                      icon: Icons.music_note,
                    );
                  }
                },
                childCount: n + AppStorage().settings.videoPaths.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Text(
                '收藏夹',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                // childAspectRatio: 10 / 9,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == 0) {
                    return FolderCard(
                      source: AppStorage().settings.downloadPath,
                      icon: Icons.file_download,
                    );
                  } else if (index == 1) {
                    return FolderCard(
                      source: AppStorage().settings.screenshotPath,
                      icon: Icons.photo,
                    );
                  } else {
                    return FolderCard(
                      source: AppStorage().settings.favouritePaths[index - 2],
                      icon: Icons.folder_special_rounded,
                    );
                  }
                },
                childCount: AppStorage().settings.favouritePaths.length + 2,
              ),
            ),
          ),
          // const SliverToBoxAdapter(
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //     child: Text(
          //       '最近播放',
          //       style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     child: Card(
          //       elevation: 0,
          //       shape: RoundedRectangleBorder(
          //         side: BorderSide(
          //           color: Theme.of(context).colorScheme.outline,
          //         ),
          //         borderRadius: const BorderRadius.all(Radius.circular(20)),
          //       ),
          //       child: const SizedBox(
          //         height: 150,
          //         child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Icon(
          //                 Icons.upcoming_rounded,
          //                 size: 40,
          //               ),
          //               SizedBox(
          //                 width: 10,
          //               ),
          //               Text(
          //                 '没有最近播放',
          //                 style: TextStyle(fontSize: 20),
          //               ),
          //             ]),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData? icon, String text, Function()? tap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: tap,
    );
  }

  void _openLink(String source) async {
    // AppStorage().closeMedia();
    // if (isBv) {
    //   final info = await BilibiliHelper.getVideoInfo(source);
    //   final playInfo = await BilibiliHelper.getVideoStream(source, info.cid);
    //   if (!mounted) return;
    //   Navigator.of(context, rootNavigator: true)
    //       .push(MaterialPageRoute(
    //           builder: (context) => BiliPlayer(
    //                 videoInfo: info,
    //                 playInfo: playInfo,
    //               )))
    //       .then((value) {
    //     AppStorage().updateStatus();
    //   });
    // } else {
    //   if (!context.mounted) return;
    //   AppStorage()
    //       .openMedia(PlayItem(source: source, cover: null, title: source));
    //   Navigator.of(context, rootNavigator: true)
    //       .push(
    //     MaterialPageRoute(
    //       builder: (context) => const MPlayer(),
    //     ),
    //   )
    //       .then((value) {
    //     AppStorage().updateStatus();
    //   });
    // }
    if (!context.mounted) return;
    AppStorage().closeMedia();
    AppStorage().openMedia(
      PlayItem(source: source, cover: null, title: source),
    );

    pushRootPage(
      context,
      const MPlayer(),
    ).then((value) {
      AppStorage().updateStatus();
    });
  }
}
