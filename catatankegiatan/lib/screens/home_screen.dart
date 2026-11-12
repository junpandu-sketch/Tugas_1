import 'package:flutter/material.dart';
import '../data/catatan_repository.dart';
import '../models/catatan.dart';
import 'catatan_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CatatanRepository _repository = CatatanRepository();
  int _selectedIndex = 0;
  late Future<List<Catatan>> _catatanFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _catatanFuture = _repository.getAll();
  }

  Future<void> _openForm({Catatan? catatan}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CatatanFormScreen(catatan: catatan),
      ),
    );
    if (changed == true && mounted) {
      setState(_refresh);
    }
  }

  Future<void> _delete(Catatan catatan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('Catatan "${catatan.judul}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.delete(catatan.id!);
      if (mounted) {
        setState(_refresh);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDataPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Daftar Kegiatan' : 'Profil'),
        centerTitle: false,
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Data',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildDataPage() {
    return FutureBuilder<List<Catatan>>(
      future: _catatanFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat data.'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_add_outlined,
                      size: 68, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada kegiatan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                      'Tekan tombol Tambah untuk membuat catatan pertama.'),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => setState(_refresh),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final completed = item.status == 'Selesai';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  leading: CircleAvatar(
                    child: Icon(completed ? Icons.check : Icons.event_note),
                  ),
                  title: Text(
                    item.judul,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${item.kategori} • ${item.tanggal}\nStatus: ${item.status}',
                    ),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _openForm(catatan: item);
                      if (value == 'delete') _delete(item);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Ubah')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),
        const CircleAvatar(
          radius: 42,
          child: Icon(Icons.person, size: 44),
        ),
        const SizedBox(height: 16),
        Text(
          'Pengguna Demo',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        const Text('demo@gmail.com', textAlign: TextAlign.center),
        const SizedBox(height: 28),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Tentang aplikasi'),
                subtitle: Text('Aplikasi sederhana untuk mencatat kegiatan.'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.storage_outlined),
                title: Text('Penyimpanan'),
                subtitle: Text('Penyimpanan lokal pada perangkat'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.code),
                title: Text('Versi'),
                subtitle: Text('1.0.0'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
