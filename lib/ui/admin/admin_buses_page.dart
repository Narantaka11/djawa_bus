import 'package:flutter/material.dart';
import '../../service/bus_service.dart';
import '../../model/bus.dart';
import '../app_drawer.dart';

class AdminBusesPage extends StatelessWidget {
  const AdminBusesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final svc = BusService();
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Bus')),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Bus>>(
        stream: svc.streamAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final buses = snap.data ?? [];
          return ListView.builder(
            itemCount: buses.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Bus'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const BusFormPage(),
                    )),
                  ),
                );
              }
              final b = buses[i - 1];
              return ListTile(
                title: Text('${b.name} — ${b.plate}'),
                subtitle: Text('${b.klass} • ${b.seats} kursi'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => BusFormPage(bus: b)));
                    } else if (v == 'delete') {
                      await svc.delete(b.id!);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BusFormPage extends StatefulWidget {
  final Bus? bus;
  const BusFormPage({super.key, this.bus});
  @override
  State<BusFormPage> createState() => _BusFormPageState();
}

class _BusFormPageState extends State<BusFormPage> {
  final _name = TextEditingController();
  final _plate = TextEditingController();
  final _seats = TextEditingController();
  String klass = 'Executive';
  bool loading = false;
  final svc = BusService();

  @override
  void initState() {
    super.initState();
    if (widget.bus != null) {
      _name.text = widget.bus!.name;
      _plate.text = widget.bus!.plate;
      klass = widget.bus!.klass;
      _seats.text = widget.bus!.seats.toString();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _plate.dispose();
    _seats.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() => loading = true);
    try {
      final seats = int.tryParse(_seats.text) ?? (klass == 'Executive' ? 36 : klass == 'Business' ? 48 : 52);
      final b = Bus(
        id: widget.bus?.id,
        name: _name.text.trim(),
        plate: _plate.text.trim(),
        klass: klass,
        seats: seats,
      );
      if (widget.bus == null) {
        await svc.create(b);
      } else {
        await svc.update(b);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bus == null ? 'Tambah Bus' : 'Edit Bus')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama Bus')),
            const SizedBox(height: 8),
            TextField(controller: _plate, decoration: const InputDecoration(labelText: 'Plat Nomor')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: klass,
              items: const [
                DropdownMenuItem(value: 'Executive', child: Text('Executive')),
                DropdownMenuItem(value: 'Business', child: Text('Business')),
                DropdownMenuItem(value: 'Economy', child: Text('Economy')),
              ],
              onChanged: (v) => setState(() => klass = v ?? 'Executive'),
              decoration: const InputDecoration(labelText: 'Kelas'),
            ),
            const SizedBox(height: 8),
            TextField(controller: _seats, decoration: const InputDecoration(labelText: 'Jumlah Kursi (override)')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: loading ? null : save, child: loading ? const CircularProgressIndicator() : const Text('Simpan')),
            ),
          ],
        ),
      ),
    );
  }
}
