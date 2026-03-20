import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:Rusic/ui/media_ui.dart';

class HTTPServerManager {
  final String serverAddress;

  HTTPServerManager({required this.serverAddress});

  Future<List<OnlineSong>> fetchSongs() async {
    try {
      final uri = Uri.parse(serverAddress);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var document = parse(response.body);
        var anchors = document.getElementsByTagName('a');

        List<OnlineSong> songs = [];
        for (var anchor in anchors) {
          var href = anchor.attributes['href'];
          if (href != null && _isAudioFile(href)) {
            // Reconstruct absolute url
            var absoluteUrl = _buildAbsoluteUrl(serverAddress, href);
            var title = Uri.decodeFull(href)
                .replaceAll(RegExp(r'^/'), '')
                .replaceAll(RegExp(r'\.[^.]+$'), ''); // remove extension

            // Further clean up trailing slashes or parts if needed
            if (title.contains('/')) {
              title = title.split('/').last;
            }

            songs.add(
              OnlineSong(title: title, url: absoluteUrl, artist: 'Server'),
            );
          }
        }
        return songs;
      } else {
        print('HTTP Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching from HTTP server: $e');
      return [];
    }
  }

  bool _isAudioFile(String href) {
    final lowerHref = href.toLowerCase();
    return lowerHref.endsWith('.mp3') ||
        lowerHref.endsWith('.wav') ||
        lowerHref.endsWith('.m4a') ||
        lowerHref.endsWith('.flac') ||
        lowerHref.endsWith('.aac') ||
        lowerHref.endsWith('.ogg');
  }

  String _buildAbsoluteUrl(String base, String relative) {
    if (relative.startsWith('http://') || relative.startsWith('https://')) {
      return relative;
    }

    // Clean up base and relative to merge them properly
    var sanitizedBase = base;
    if (sanitizedBase.endsWith('/')) {
      sanitizedBase = sanitizedBase.substring(0, sanitizedBase.length - 1);
    }

    var sanitizedRelative = relative;
    if (!sanitizedRelative.startsWith('/')) {
      sanitizedRelative = '/$sanitizedRelative';
    }

    return '$sanitizedBase$sanitizedRelative';
  }
}
