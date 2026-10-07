import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_player_web/video_player_web.dart';

void registerWebVideoPlugin() {
  VideoPlayerPlugin.registerWith(webPluginRegistrar);
}
