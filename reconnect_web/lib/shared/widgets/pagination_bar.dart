import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.pageIndex,
    required this.totalPages,
    required this.totalElements,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final int pageIndex;
  final int totalPages;
  final int totalElements;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final hasPrev = pageIndex > 1;
    final hasNext = totalPages > 0 && pageIndex < totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Text(
            'Tổng: $totalElements bản ghi',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: pageSize,
            underline: const SizedBox.shrink(),
            items: const [5, 10, 20, 50]
                .map((size) => DropdownMenuItem<int>(
                      value: size,
                      child: Text('$size / trang'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onPageSizeChanged(value);
              }
            },
          ),
          const Spacer(),
          Text(
            'Trang ${totalPages == 0 ? 0 : pageIndex}/$totalPages',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: hasPrev ? () => onPageChanged(pageIndex - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: hasNext ? () => onPageChanged(pageIndex + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
