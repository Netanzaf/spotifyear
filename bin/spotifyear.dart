import 'dart:collection';

import 'spotify_gate.dart';

void main(List<String> arguments) async {
  var spotify = SpotifyGate();
  await spotify.open();

  print(SplayTreeMap.from(
      (await spotify.library).byYear().map(
          (year, songsLibrary) => MapEntry(year, songsLibrary.songs.length)),
      (year, comparedYear) => year - comparedYear));
}
