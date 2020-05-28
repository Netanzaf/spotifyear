import 'dart:convert';
import 'dart:io';

import 'authorization.dart';
import 'songs_library.dart';
import 'spotify_client.dart';

class SpotifyGate {
  static final _authorization =
      Authorization(clientId: clientId, clientSecret: clientSecret);

  void open() async {
    await _authorization.authorize();
  }

  Future<SongsLibrary> get library async =>
      await _library('https://api.spotify.com/v1/me/tracks?limit=50');

  Future<SongsLibrary> _library(String url) async {
    var songs = [];

    var libraryRequest = await HttpClient().getUrl(Uri.parse(url))
      ..headers.add('Authorization', 'Bearer ${_authorization.accessToken}');

    var libraryResponse = await libraryRequest.close();

    await for (var data
        in libraryResponse.transform(utf8.decoder).transform(json.decoder)) {
      var jsonData = data as Map;
      var next = jsonData['next'];
      songs = [
        ...songs,
        ...jsonData['items'].map((item) => item['track']),
        if (next != null) ...(await _library(next)).songs
      ];
    }

    return SongsLibrary(List<Map<String, dynamic>>.from(songs));
  }
}
