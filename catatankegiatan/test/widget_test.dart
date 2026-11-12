import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('Login menampilkan form dan validasi input kosong',
      (WidgetTester tester) async {
    // Menjalankan aplikasi
    await tester.pumpWidget(const CatatanKegiatanApp());

    // Memastikan halaman login muncul
    expect(find.text('Catatan Kegiatan'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Menekan tombol login tanpa mengisi input
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    // Memastikan pesan validasi muncul
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });
}
