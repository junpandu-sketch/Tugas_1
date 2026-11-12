import 'package:flutter/material.dart';
import '../data/catatan_repository.dart';
import '../models/catatan.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key, this.catatan});

  final Catatan? catatan;

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final CatatanRepository _repository = CatatanRepository();

  final List<String> _kategoriOptions = [
    'Kuliah',
    'Pekerjaan',
    'Pribadi',
    'Olahraga',
    'Lainnya',
  ];
  final List<String> _statusOptions = ['Belum Selesai', 'Selesai'];

  String? _kategori;
  String _status = 'Belum Selesai';
  DateTime _tanggal = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.catatan != null;

  @override
  void initState() {
    super.initState();
    final item = widget.catatan;
    if (item != null) {
      _judulController.text = item.judul;
      _kategori = item.kategori;
      _status = item.status;
      _tanggal = DateTime.parse(item.tanggal);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  String _dateString(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = Catatan(
      id: widget.catatan?.id,
      judul: _judulController.text.trim(),
      kategori: _kategori!,
      tanggal: _dateString(_tanggal),
      status: _status,
    );

    try {
      if (_isEditing) {
        await _repository.update(data);
      } else {
        await _repository.insert(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data gagal disimpan. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Ubah Kegiatan' : 'Tambah Kegiatan'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _judulController,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Judul kegiatan',
                  hintText: 'Contoh: Mengerjakan tugas Flutter',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul kegiatan wajib diisi';
                  }
                  if (value.trim().length < 3) {
                    return 'Judul minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _kategoriOptions
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _kategori = value),
                validator: (value) =>
                    value == null ? 'Pilih kategori kegiatan' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(_dateString(_tanggal)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: _statusOptions
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
