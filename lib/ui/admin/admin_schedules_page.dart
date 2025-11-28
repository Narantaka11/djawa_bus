// lib/ui/admin/admin_schedules_page.dart
import 'package:flutter/material.dart';
import '../../service/schedule_service.dart';
import '../../service/bus_service.dart';
import '../../model/schedule.dart';
import '../../model/bus.dart';
import '../app_drawer.dart';

class AdminSchedulesPage extends StatelessWidget {
  const AdminSchedulesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final svc = ScheduleService();
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Jadwal')),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Schedule>>(
        stream: svc.streamAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snap.data ?? [];
          return ListView.builder(
            itemCount: items.length + 1,
            itemBuilder: (c, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Jadwal'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleFormPage())),
                  ),
                );
              }
              final s = items[i - 1];
              return ListTile(
                title: Text('${s.route} — ${s.depart_date} ${s.departTime}'),
                subtitle: Text('Rp ${s.price} • busId: ${s.busId}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleFormPage(schedule: s)));
                    } else if (v == 'delete') {
                      await svc.delete(s.id!);
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

class ScheduleFormPage extends StatefulWidget {
  final Schedule? schedule;
  const ScheduleFormPage({super.key, this.schedule});
  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  final _route = TextEditingController();
  final _date = TextEditingController(); // yyyy-mm-dd
  final _time = TextEditingController(); // HH:mm
  final _price = TextEditingController();
  String? selectedBusId;
  final svc = ScheduleService();
  final busSvc = BusService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _route.text = widget.schedule!.route;
      _date.text = widget.schedule!.depart_date;
      _time.text = widget.schedule!.departTime;
      _price.text = widget.schedule!.price.toString();
      selectedBusId = widget.schedule!.busId;
    }
  }

  @override
  void dispose() {
    _route.dispose();
    _date.dispose();
    _time.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() => loading = true);
    try {
      final price = int.tryParse(_price.text) ?? 0;
      final s = Schedule(
        id: widget.schedule?.id,
        route: _route.text.trim(),
        depart_date: _date.text.trim(),
        departTime: _time.text.trim(),
        price: price,
        busId: selectedBusId ?? '',
      );
      if (widget.schedule == null) {
        await svc.create(s);
      } else {
        await svc.update(s);
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
      appBar: AppBar(title: Text(widget.schedule == null ? 'Tambah Jadwal' : 'Edit Jadwal')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(controller: _route, decoration: const InputDecoration(labelText: 'Rute')),
            const SizedBox(height: 8),
            TextField(controller: _date, decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)')),
            const SizedBox(height: 8),
            TextField(controller: _time, decoration: const InputDecoration(labelText: 'Waktu (HH:mm)')),
            const SizedBox(height: 8),
            FutureBuilder<List<Bus>>(
              future: busSvc.listOnce(),
              builder: (c, s) {
                final buses = s.data ?? [];
                return DropdownButtonFormField<String>(
                  value: selectedBusId,
                  items: buses.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.klass})'))).toList(),
                  onChanged: (v) => setState(() => selectedBusId = v),
                  decoration: const InputDecoration(labelText: 'Pilih Bus'),
                );
              },
            ),
            const SizedBox(height: 8),
            TextField(controller: _price, decoration: const InputDecoration(labelText: 'Harga')),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: loading ? null : save, child: loading ? const CircularProgressIndicator() : const Text('Simpan'))),
          ],
        ),
      ),
    );
  }
}
