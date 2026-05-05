import 'package:app_core/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final ImageProvider? avatarImage;
  final VoidCallback? onAvatarTap;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.avatarImage,
    this.onAvatarTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm trên bản đồ...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _controller.clear();
                          setState(() {});
                          widget.onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: widget.onSearch,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onAvatarTap,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.successDark,
                backgroundImage: widget.avatarImage,
                child: widget.avatarImage == null
                    ? Icon(
                        Icons.person_outline,
                        color: AppColors.white,
                        size: 20,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
