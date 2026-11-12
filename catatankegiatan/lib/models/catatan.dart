class Catatan {
  const Catatan({
    this.id,
    required this.judul,
    required this.kategori,
    required this.tanggal,
    required this.status,
  });

  final int? id;
  final String judul;
  final String kategori;
  final String tanggal;
  final String status;

  Map<String, Object?> toMap() => {
        'id': id,
        'judul': judul,
        'kategori': kategori,
        'tanggal': tanggal,
        'status': status,
      };

  factory Catatan.fromMap(Map<String, Object?> map) => Catatan(
        id: map['id'] as int,
        judul: map['judul'] as String,
        kategori: map['kategori'] as String,
        tanggal: map['tanggal'] as String,
        status: map['status'] as String,
      );
}
