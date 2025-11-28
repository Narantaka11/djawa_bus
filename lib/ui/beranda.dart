// lib/ui/beranda.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_drawer.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> with SingleTickerProviderStateMixin {
  // animations
  late final AnimationController _anim;
  late final Animation<double> _fadeHeader;
  late final Animation<Offset> _slideCard;
  late final Animation<double> _fadeList;

  // Firestore refs (optional dynamic data)
  final _promosRef = FirebaseFirestore.instance.collection('promos');
  final _routesRef = FirebaseFirestore.instance.collection('popular_routes');

  // search ticket inputs
  final List<String> _cities = [
    'Jakarta',
    'Bandung',
    'Yogyakarta',
    'Solo',
    'Surabaya',
    'Malang',
    'Semarang',
    'Kudus'
  ];
  String? _fromCity;
  String? _toCity;

  // brand colors
  static const Color brandRed = Color(0xFFE53935);
  static final Color brandAccent = Colors.blue.shade700;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _fadeHeader = CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.45, curve: Curves.easeOut));
    _slideCard = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic)));
    _fadeList = CurvedAnimation(parent: _anim, curve: const Interval(0.6, 1.0, curve: Curves.easeIn));
    _anim.forward();

    // defaults
    _fromCity = _cities.first;
    _toCity = _cities.length > 1 ? _cities[1] : _cities.first;
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  String _userDisplay() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return 'Tamu';
    final name = u.displayName;
    if (name != null && name.trim().isNotEmpty) return name;
    final email = u.email ?? '';
    if (email.contains('@')) return email.split('@')[0];
    return email.isNotEmpty ? email : 'Pengguna';
  }

  // NAV: go to tickets page and pass from/to as args
  void _goToTicketBooking() {
    final from = _fromCity;
    final to = _toCity;
    if (from == null || to == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kota asal dan tujuan terlebih dahulu')));
      return;
    }
    if (from == to) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kota asal dan tujuan tidak boleh sama')));
      return;
    }

    Navigator.of(context).pushNamed('/tickets', arguments: {'from': from, 'to': to});
  }

  // UI helpers
  Widget _quickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 6))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 26, color: brandAccent),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  Widget _promoFallbackCard({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [brandRed.withOpacity(0.95), brandRed.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ])),
        const SizedBox(width: 10),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.local_offer, size: 36, color: Colors.white70),
        )
      ]),
    );
  }

  Widget _routeListPlaceholder() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(4, (i) {
        return Container(
          width: 170,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Expanded(child: Container(color: Colors.grey.shade200)),
            const SizedBox(height: 8),
            Container(height: 10, width: 80, color: Colors.grey.shade200),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userLabel = _userDisplay();
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 900 ? 900.0 : (width > 600 ? 700.0 : width);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(children: [
          const SizedBox(width: 2),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Halo,', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            Text(userLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifikasi belum tersedia'))),
          )
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // header
              FadeTransition(
                opacity: _fadeHeader,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [brandAccent.withOpacity(0.98), brandAccent.withOpacity(0.68)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      child: Text(userLabel.isNotEmpty ? userLabel[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Selamat datang,', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 6),
                      Text(userLabel, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: [
                        _chipInfo('Saldo', 'Rp 0', icon: Icons.account_balance_wallet),
                        _chipInfo('Tiket', '0', icon: Icons.confirmation_number),
                        _chipInfo('Promo', '1 aktif', icon: Icons.local_offer),
                      ])
                    ]))
                  ]),
                ),
              ),

              const SizedBox(height: 18),

              // quick actions row
              SlideTransition(position: _slideCard, child: Row(children: [
                _quickAction(icon: Icons.search, label: 'Cari Tiket', onTap: () {}),
                _quickAction(icon: Icons.confirmation_number, label: 'Tiket Saya', onTap: () => Navigator.pushNamed(context, '/tickets')),
                _quickAction(icon: Icons.schedule, label: 'Jadwal', onTap: () => Navigator.pushReplacementNamed(context, '/admin/schedule')),
              ])),

              const SizedBox(height: 18),

              // SEARCH TICKET panel (NEW) ----------------------------
              Text('Cari Tiket', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    // from & to column
                    Expanded(
                      child: Column(children: [
                        // From
                        _cityDropdown(
                          label: 'Kota Asal',
                          value: _fromCity,
                          items: _cities,
                          onChanged: (v) => setState(() => _fromCity = v),
                        ),
                        const SizedBox(height: 8),
                        // To
                        _cityDropdown(
                          label: 'Kota Tujuan',
                          value: _toCity,
                          items: _cities.where((c) => c != _fromCity).toList(),
                          onChanged: (v) => setState(() => _toCity = v),
                        ),
                      ]),
                    ),

                    const SizedBox(width: 10),

                    // Book button
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _goToTicketBooking,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Pesan\nTiket', textAlign: TextAlign.center),
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 20),

              // Promo banner (stream)
              StreamBuilder<QuerySnapshot>(
                stream: _promosRef.where('active', isEqualTo: true).orderBy('priority', descending: true).limit(1).snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) return _promoFallbackCard(title: 'Info', subtitle: 'Tidak dapat memuat promo saat ini');
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return _promoFallbackCard(title: 'Diskon 20% untuk rute tertentu', subtitle: 'Gunakan kode DJAWA20');
                  }
                  final d = snap.data!.docs.first.data() as Map<String, dynamic>;
                  return _promoCard(
                    title: (d['title'] as String?) ?? 'Promo menarik',
                    subtitle: (d['subtitle'] as String?) ?? '',
                    imageUrl: (d['imageUrl'] as String?) ?? '',
                  );
                },
              ),

              const SizedBox(height: 18),

              // Popular routes list (stream)
              Text('Rute Populer', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _routesRef.orderBy('priority', descending: true).snapshots(),
                  builder: (context, snap) {
                    if (snap.hasError) return _routesErrorCard('Gagal memuat rute.');
                    if (!snap.hasData) return _routeListPlaceholder();
                    final docs = snap.data!.docs;
                    if (docs.isEmpty) return _routeListPlaceholder();
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 12),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        final title = (d['title'] as String?) ?? 'Rute ${i + 1}';
                        final subtitle = (d['subtitle'] as String?) ?? '';
                        final imageUrl = (d['imageUrl'] as String?) ?? '';
                        return _routeCard(title: title, subtitle: subtitle, imageUrl: imageUrl);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Recent / activity placeholder
              Text('Aktivitas Terakhir', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: const [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.receipt_long),
                      title: Text('Tidak ada aktivitas terakhir'),
                      subtitle: Text('Beli tiket pertama kamu sekarang'),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }

  // small helper widgets -------------------------
  Widget _chipInfo(String label, String value, {IconData? icon}) {
    return Chip(
      backgroundColor: Colors.white.withOpacity(0.12),
      label: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) Icon(icon, size: 14, color: Colors.white70),
        if (icon != null) const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _cityDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onChanged,
        ),
      ),
    ]);
  }

  Widget _promoCard({required String title, required String subtitle, String? imageUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => _onPromoTap(title),
        child: Container(
          width: double.infinity,
          height: 110,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [brandRed.withOpacity(0.95), brandRed.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ])),
            const SizedBox(width: 10),
            _promoImage(imageUrl),
          ]),
        ),
      ),
    );
  }

  Widget _promoImage(String? imageUrl) {
    final placeholder = Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.local_offer, color: Colors.white70, size: 36),
    );
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(imageUrl, width: 84, height: 84, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder),
      );
    }
    return placeholder;
  }

  Widget _routeCard({required String title, String subtitle = '', String imageUrl = ''}) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: imageUrl.isNotEmpty
              ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const SizedBox()))
              : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100),
                  child: const Icon(Icons.directions_bus_filled, size: 36, color: Colors.black26),
                ),
        ),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (subtitle.isNotEmpty) ...[const SizedBox(height: 6), Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))],
      ]),
    );
  }

  Widget _routesErrorCard(String msg) {
    return Center(child: Text(msg, style: TextStyle(color: Colors.red.shade700)));
  }

  void _onPromoTap(String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Promo: $title')));
  }
}
