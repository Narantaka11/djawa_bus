import 'package:flutter/material.dart';

class SeatPicker extends StatefulWidget {
  final int seatCount;
  final void Function(List<String>)? onSelected;
  const SeatPicker({super.key, required this.seatCount, this.onSelected});

  @override
  State<SeatPicker> createState() => _SeatPickerState();
}

class _SeatPickerState extends State<SeatPicker> {
  final List<String> selected = [];

  List<String> _generateSeats(int n) {
    return List.generate(n, (i) => 'S${i+1}');
  }

  @override
  Widget build(BuildContext context) {
    final seats = _generateSeats(widget.seatCount);
    return GridView.builder(
      shrinkWrap: true,
      itemCount: seats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.8,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6
      ),
      itemBuilder: (context, i) {
        final s = seats[i];
        final isSel = selected.contains(s);
        return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: isSel ? Colors.green : null),
          onPressed: () {
            setState(() {
              if (isSel) selected.remove(s);
              else selected.add(s);
            });
            widget.onSelected?.call(selected);
          },
          child: Text(s),
        );
      },
    );
  }
}
