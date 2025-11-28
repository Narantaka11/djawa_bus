class Schedule {
  String? id;
  String route;
  String depart_date;
  String departTime;
  int price;
  String busId;
  Schedule({this.id, required this.route, required this.depart_date, required this.departTime, required this.price, required this.busId});
  factory Schedule.fromJson(String id, Map<String, dynamic> json) => Schedule(
    id: id,
    route: json['route'] ?? '',
    depart_date: json['depart_date'] ?? '',
    departTime: json['depart_time'] ?? json['departTime'] ?? '',
    price: (json['price'] is int) ? json['price'] : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
    busId: json['bus_id'] ?? json['busId'] ?? '',
  );
  Map<String, dynamic> toJson() => {'route': route, 'depart_date': depart_date, 'depart_time': departTime, 'price': price, 'bus_id': busId};
}
