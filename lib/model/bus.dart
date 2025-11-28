// lib/model/bus.dart
class Bus {
  String? id;
  String name;
  String plate;
  String klass;
  int seats;
  Bus({this.id, required this.name, required this.plate, required this.klass, required this.seats});
  factory Bus.fromJson(String id, Map<String, dynamic> json) => Bus(
    id: id,
    name: json['name'] ?? '',
    plate: json['plate'] ?? '',
    klass: json['klass'] ?? '',
    seats: (json['seats'] is int) ? json['seats'] : int.tryParse(json['seats']?.toString() ?? '0') ?? 0,
  );
  Map<String, dynamic> toJson() => {'name': name, 'plate': plate, 'klass': klass, 'seats': seats};
}
