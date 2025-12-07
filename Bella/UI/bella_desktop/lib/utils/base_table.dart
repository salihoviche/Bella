import 'package:flutter/material.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class BaseTable extends StatelessWidget {
  final double width;
  final double height;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? emptyState;
  final IconData? emptyIcon;
  final String? emptyText;
  final String? emptySubtext;
  final bool showCheckboxColumn;
  final double columnSpacing;
  final Color? headingRowColor;
  final Color? hoverRowColor;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final IconData? icon;
  final List<double>? columnWidths;
  final Set<int>? imageColumnIndices;
  final EdgeInsetsGeometry? imageColumnPadding;

  const BaseTable({
    super.key,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    this.emptyState,
    this.emptyIcon,
    this.emptyText,
    this.emptySubtext,
    this.showCheckboxColumn = false,
    this.columnSpacing = 24,
    this.headingRowColor,
    this.hoverRowColor,
    this.padding,
    this.title,
    this.icon,
    this.columnWidths,
    this.imageColumnIndices,
    this.imageColumnPadding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = rows.isEmpty;
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: height * 0.8, maxHeight: height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: isEmpty
          ? (emptyState ?? _defaultEmptyState())
          : Column(
              children: [
                // Modern header with orange gradient
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _orangePrimary,
                        _orangeDark,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (icon != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon!,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      if (icon != null) const SizedBox(width: 12),
                      Text(
                        title ?? 'Data Table',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${rows.length} items',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table content
                Expanded(
                  child: Container(
                    padding: padding ?? EdgeInsets.zero,
                    child: SingleChildScrollView(
                      child: _buildModernDataTable(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModernDataTable(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text('No data available'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate table width based on column widths or use constraints
        double tableWidth;
        if (columnWidths != null && columnWidths!.isNotEmpty) {
          // Sum of all column widths plus spacing between columns
          tableWidth = columnWidths!.fold(0.0, (sum, width) => sum + width) +
              (columnWidths!.length - 1) * columnSpacing;
        } else {
          tableWidth = constraints.maxWidth;
        }

        return Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: DataTable(
                showCheckboxColumn: showCheckboxColumn,
                columnSpacing: columnSpacing,
                headingRowColor: WidgetStateProperty.all(
                  headingRowColor ?? Colors.grey[50],
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return hoverRowColor ?? _orangePrimary.withOpacity(0.08);
                  }
                  return null;
                }),
                columns: _buildModernColumns(context, tableWidth),
                rows: _buildModernRows(context, tableWidth),
                dataTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                ),
                headingTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _orangePrimary,
                  letterSpacing: 0.3,
                ),
                dividerThickness: 0.5,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey.withOpacity(0.08),
                    width: 0.5,
                  ),
                  verticalInside: BorderSide(
                    color: Colors.grey.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildModernColumns(
    BuildContext context,
    double tableWidth,
  ) {
    // Use custom column widths if provided, otherwise distribute evenly
    List<double> widths;
    if (columnWidths != null && columnWidths!.length == columns.length) {
      widths = columnWidths!;
    } else {
      double columnWidth = tableWidth / columns.length;
      widths = List.filled(columns.length, columnWidth);
    }

    // Default padding for regular columns
    final defaultPadding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16);
    // Reduced padding for image columns
    final imagePadding = imageColumnPadding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 8);

    return columns.asMap().entries.map((entry) {
      int index = entry.key;
      DataColumn column = entry.value;
      final isImageColumn = imageColumnIndices != null && imageColumnIndices!.contains(index);
      return DataColumn(
        label: Container(
          width: widths[index],
          padding: isImageColumn ? imagePadding : defaultPadding,
          child: column.label,
        ),
      );
    }).toList();
  }

  List<DataRow> _buildModernRows(BuildContext context, double tableWidth) {
    // Use custom column widths if provided, otherwise distribute evenly
    List<double> widths;
    if (columnWidths != null && columnWidths!.length == columns.length) {
      widths = columnWidths!;
    } else {
      double columnWidth = tableWidth / columns.length;
      widths = List.filled(columns.length, columnWidth);
    }

    // Default padding for regular columns
    final defaultPadding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16);
    // Reduced padding for image columns
    final imagePadding = imageColumnPadding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 8);

    return rows.map((row) {
      return DataRow(
        onSelectChanged: row.onSelectChanged,
        cells: row.cells.asMap().entries.map((entry) {
          int index = entry.key;
          DataCell cell = entry.value;
          final isImageColumn = imageColumnIndices != null && imageColumnIndices!.contains(index);
          return DataCell(
            Container(
              width: widths[index],
              padding: isImageColumn ? imagePadding : defaultPadding,
              alignment: Alignment.centerLeft,
              child: cell.child,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _defaultEmptyState() {
    if (emptyIcon == null && emptyText == null && emptySubtext == null) {
      return Center(child: Text('No data'));
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emptyIcon != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _orangePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  emptyIcon,
                  size: 48,
                  color: _orangePrimary,
                ),
              ),
            if (emptyText != null) ...[
              const SizedBox(height: 24),
              Text(
                emptyText!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (emptySubtext != null) ...[
              const SizedBox(height: 8),
              Text(
                emptySubtext!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
