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

  List<Widget> _buildPageNumbers(BuildContext context) {
    if (totalPages == 0) return [];
    List<Widget> children = [];

    Widget buildButton(int page) {
      final isCurrent = page == pageIndex;
      return InkWell(
        onTap: isCurrent ? null : () => onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.black87,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    Widget buildEllipsis() {
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: const Text('...', style: TextStyle(color: Colors.grey)),
      );
    }

    if (totalPages <= 7) {
      for (int i = 1; i <= totalPages; i++) {
        children.add(buildButton(i));
      }
    } else {
      if (pageIndex <= 4) {
        for (int i = 1; i <= 5; i++) {
          children.add(buildButton(i));
        }
        children.add(buildEllipsis());
        children.add(buildButton(totalPages));
      } else if (pageIndex >= totalPages - 3) {
        children.add(buildButton(1));
        children.add(buildEllipsis());
        for (int i = totalPages - 4; i <= totalPages; i++) {
          children.add(buildButton(i));
        }
      } else {
        children.add(buildButton(1));
        children.add(buildEllipsis());
        children.add(buildButton(pageIndex - 1));
        children.add(buildButton(pageIndex));
        children.add(buildButton(pageIndex + 1));
        children.add(buildEllipsis());
        children.add(buildButton(totalPages));
      }
    }
    return children;
  }

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
          IconButton(
            onPressed: hasPrev ? () => onPageChanged(pageIndex - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          ..._buildPageNumbers(context),
          IconButton(
            onPressed: hasNext ? () => onPageChanged(pageIndex + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
