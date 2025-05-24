class Song {
  final int id;
  final String title;
  final String artist;
  final String topGenre;
  final int year;
  final int bpm;
  final int nrgy;
  final int dnce;
  final int dB;
  final int live;
  final int val;
  final int dur;
  final int acous;
  final int spch;
  final int pop;
  final String vidId;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.topGenre,
    required this.year,
    required this.bpm,
    required this.nrgy,
    required this.dnce,
    required this.dB,
    required this.live,
    required this.val,
    required this.dur,
    required this.acous,
    required this.spch,
    required this.pop,
    required this.vidId
  });

  factory Song.fromCsv(List<dynamic> row) {
    return Song(
      id: int.tryParse(row[0].toString()) ?? 0,
      title: row[1].toString(),
      artist: row[2].toString(),
      topGenre: row[3].toString(),
      year: int.tryParse(row[4].toString()) ?? 0,
      bpm: int.tryParse(row[5].toString()) ?? 0,
      nrgy: int.tryParse(row[6].toString()) ?? 0,
      dnce: int.tryParse(row[7].toString()) ?? 0,
      dB: int.tryParse(row[8].toString()) ?? 0,
      live: int.tryParse(row[9].toString()) ?? 0,
      val: int.tryParse(row[10].toString()) ?? 0,
      dur: int.tryParse(row[11].toString()) ?? 0,
      acous: int.tryParse(row[12].toString()) ?? 0,
      spch: int.tryParse(row[13].toString()) ?? 0,
      pop: int.tryParse(row[14].toString()) ?? 0,
      vidId: row[15].toString(),
    );
  }
}
