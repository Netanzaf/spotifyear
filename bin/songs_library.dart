class SongsLibrary {
  SongsLibrary(this.songs);

  final List<Map<String, dynamic>> songs;

  void add(Map<String, dynamic> song) => songs.add(song);

  Map<int, SongsLibrary> byYear() =>
      songs.fold(<int, SongsLibrary>{}, (library, song) {
        final year = DateTime.parse(song['album']['release_date']).year;

        if (!library.containsKey(year)) {
          library[year] = SongsLibrary([]);
        }

        library[year].add(song);
        return library;
      });
}
