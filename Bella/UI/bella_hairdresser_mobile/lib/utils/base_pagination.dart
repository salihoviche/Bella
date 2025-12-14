import 'package:flutter/material.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class BasePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool showPageSizeSelector;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int?>? onPageSizeChanged;

  const BasePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.showPageSizeSelector = false,
    this.pageSize = 10,
    this.pageSizeOptions = const [5, 7, 10, 20, 50],
    this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Page info and navigation
          Row(
            children: [
              // Page info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _orangePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page ${currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _orangePrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Previous button
              _buildNavigationButton(
                icon: Icons.chevron_left_rounded,
                onPressed: (currentPage == 0) ? null : onPrevious,
                isEnabled: currentPage > 0,
              ),

              const SizedBox(width: 8),

              // Next button
              _buildNavigationButton(
                icon: Icons.chevron_right_rounded,
                onPressed: (currentPage >= totalPages - 1 || totalPages == 0)
                    ? null
                    : onNext,
                isEnabled: currentPage < totalPages - 1 && totalPages > 0,
                isNext: true,
              ),
            ],
          ),

          // Right side: Page size selector
          if (showPageSizeSelector)
            _PageSizeSelector(
              options: pageSizeOptions,
              selected: pageSize,
              onChanged: onPageSizeChanged,
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
    bool isNext = false,
  }) {
    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: _orangePrimary.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? LinearGradient(
                        colors: [_orangePrimary, _orangeDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isEnabled ? null : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isEnabled ? Colors.white : Colors.grey[500],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageSizeSelector extends StatelessWidget {
  const _PageSizeSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<int> options;
  final int selected;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Rows per page:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            final bool isSelected = selected == option;
            return Padding(
              padding: EdgeInsets.only(
                right: option != options.last ? 6 : 0,
              ),
              child: _PageSizeOption(
                value: option,
                isSelected: isSelected,
                onTap: () => onChanged?.call(option),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PageSizeOption extends StatefulWidget {
  const _PageSizeOption({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_PageSizeOption> createState() => _PageSizeOptionState();
}

class _PageSizeOptionState extends State<_PageSizeOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? const LinearGradient(
                          colors: [_orangePrimary, _orangeDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.isSelected ? null : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.transparent
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: _orangePrimary.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  widget.value.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
