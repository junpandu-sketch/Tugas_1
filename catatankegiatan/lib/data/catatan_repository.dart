import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catatan.dart';

class CatatanRepository {
  static const String _key = 'daftar_catatan';
  static SharedPreferences? _prefs;

  // Inisialisasi awal (dipanggil di main.dart)
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _instance => _prefs!;

  Future<List<Catatan>> getAll() async {
    final jsonString = _instance.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> data = jsonDecode(jsonString);
    return data
        .map((item) => Catatan.fromMap(Map<String, Object?>.from(item)))
        .toList();
  }

  Future<int> insert(Catatan catatan) async {
    final data = await getAll();
    final newId = DateTime.now().microsecondsSinceEpoch;

    final newCatatan = Catatan(
      id: newId,
      judul: catatan.judul,
      kategori: catatan.kategori,
      tanggal: catatan.tanggal,
      status: catatan.status,
    );

    data.add(newCatatan);
    await _instance.setString(
      _key,
      jsonEncode(data.map((item) => item.toMap()).toList()),
    );

    return newId;
  }

  Future<int> update(Catatan catatan) async {
    final data = await getAll();
    final index = data.indexWhere((item) => item.id == catatan.id);
    if (index == -1) return 0;

    data[index] = catatan;
    await _instance.setString(
      _key,
      jsonEncode(data.map((item) => item.toMap()).toList()),
    );

    return 1;
  }

  Future<int> delete(int id) async {
    final data = await getAll();
    data.removeWhere((item) => item.id == id);

    await _instance.setString(
      _key,
      jsonEncode(data.map((item) => item.toMap()).toList()),
    );

    return 1;
  }
}
