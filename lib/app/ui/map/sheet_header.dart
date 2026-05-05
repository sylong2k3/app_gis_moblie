import 'package:flutter/material.dart';

class SheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const SheetHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cấu hình bản đồ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2),
            Text(
              'MOBILE GIS ENGINE',
              style: TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onClose,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.close, size: 20),
          ),
        ),
      ],
    );
  }
}
