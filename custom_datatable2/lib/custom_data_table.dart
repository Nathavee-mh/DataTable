// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:custom_datatable/custom_adjust_headerIndex.dart';
import 'package:custom_datatable/custom_adjust_row_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// import 'checkbox.dart';
// import 'constants.dart';
// import 'data_table_theme.dart';
// import 'debug.dart';
// import 'divider.dart';
// import 'dropdown.dart';
// import 'icons.dart';
// import 'ink_well.dart';
// import 'material.dart';
// import 'material_state.dart';
// import 'theme.dart';
// import 'tooltip.dart';
import "package:flutter/material.dart";
// import 'package:reorderables/reorderables.dart';

/// Signature for [DataColumn.onSort] callback.
typedef DataColumnSortCallback = void Function(int columnIndex, bool ascending);

/// Column configuration for a [DataTable].
///
/// One column configuration must be provided for each column to
/// display in the table. The list of [DataColumn] objects is passed
/// as the `columns` argument to the [new DataTable] constructor.
@immutable
class CustomDataColumn {
  /// Creates the configuration for a column of a [DataTable].
  ///
  /// The [label] argument must not be null.
  const CustomDataColumn({
    required this.label,
    this.tooltip,
    this.numeric = false,
    this.onSort,
  }) : assert(label != null);

  /// The column heading.
  ///
  /// Typically, this will be a [Text] widget. It could also be an
  /// [Icon] (typically using size 18), or a [Row] with an icon and
  /// some text.
  ///
  /// By default, this widget will only occupy the minimal space. If you want
  /// it to take the entire remaining space, e.g. when you want to use [Center],
  /// you can wrap it with an [Expanded].
  ///
  /// The label should not include the sort indicator.
  final Widget label;

  /// The column heading's tooltip.
  ///
  /// This is a longer description of the column heading, for cases
  /// where the heading might have been abbreviated to keep the column
  /// width to a reasonable size.
  final String? tooltip;

  /// Whether this column represents numeric data or not.
  ///
  /// The contents of cells of columns containing numeric data are
  /// right-aligned.
  final bool numeric;

  /// Called when the user asks to sort the table using this column.
  ///
  /// If null, the column will not be considered sortable.
  ///
  /// See [DataTable.sortColumnIndex] and [DataTable.sortAscending].
  final DataColumnSortCallback? onSort;

  bool get _debugInteractive => onSort != null;
}

/// Row configuration and cell data for a [DataTable].
///
/// One row configuration must be provided for each row to
/// display in the table. The list of [DataRow] objects is passed
/// as the `rows` argument to the [new DataTable] constructor.
///
/// The data for this row of the table is provided in the [cells]
/// property of the [DataRow] object.
@immutable
class CustomDataRow {
  /// Creates the configuration for a row of a [DataTable].
  ///
  /// The [cells] argument must not be null.
  const CustomDataRow({
    this.key,
    required this.selected,
    this.onSelectChanged,
    this.color,
    required this.cells,
  }) : assert(cells != null);

  /// Creates the configuration for a row of a [DataTable], deriving
  /// the key from a row index.
  ///
  /// The [cells] argument must not be null.
  CustomDataRow.byIndex({
    int? index,
    required this.selected,
    this.onSelectChanged,
    this.color,
    required this.cells,
  })  : assert(cells != null),
        key = ValueKey<int?>(index);

  /// A [Key] that uniquely identifies this row. This is used to
  /// ensure that if a row is added or removed, any stateful widgets
  /// related to this row (e.g. an in-progress checkbox animation)
  /// remain on the right row visually.
  ///
  /// If the table never changes once created, no key is necessary.
  final LocalKey? key;

  /// Called when the user selects or unselects a selectable row.
  ///
  /// If this is not null, then the row is selectable. The current
  /// selection state of the row is given by [selected].
  ///
  /// If any row is selectable, then the table's heading row will have
  /// a checkbox that can be checked to select all selectable rows
  /// (and which is checked if all the rows are selected), and each
  /// subsequent row will have a checkbox to toggle just that row.
  ///
  /// A row whose [onSelectChanged] callback is null is ignored for
  /// the purposes of determining the state of the "all" checkbox,
  /// and its checkbox is disabled.
  ///
  /// If a [DataCell] in the row has its [DataCell.onTap] callback defined,
  /// that callback behavior overrides the gesture behavior of the row for
  /// that particular cell.
  final ValueChanged<bool?>? onSelectChanged;

  /// Whether the row is selected.
  ///
  /// If [onSelectChanged] is non-null for any row in the table, then
  /// a checkbox is shown at the start of each row. If the row is
  /// selected (true), the checkbox will be checked and the row will
  /// be highlighted.
  ///
  /// Otherwise, the checkbox, if present, will not be checked.
  final ValueNotifier<bool> selected;

  /// The data for this row.
  ///
  /// There must be exactly as many cells as there are columns in the
  /// table.
  final List<CustomDataCell> cells;

  /// The color for the row.
  ///
  /// By default, the color is transparent unless selected. Selected rows has
  /// a grey translucent color.
  ///
  /// The effective color can depend on the [MaterialState] state, if the
  /// row is selected, pressed, hovered, focused, disabled or enabled. The
  /// color is painted as an overlay to the row. To make sure that the row's
  /// [InkWell] is visible (when pressed, hovered and focused), it is
  /// recommended to use a translucent color.
  ///
  /// ```dart
  /// DataRow(
  ///   color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
  ///     if (states.contains(MaterialState.selected))
  ///       return Theme.of(context).colorScheme.primary.withOpacity(0.08);
  ///     return null;  // Use the default value.
  ///   }),
  /// )
  /// ```
  ///
  /// See also:
  ///
  ///  * The Material Design specification for overlay colors and how they
  ///    match a component's state:
  ///    <https://material.io/design/interaction/states.html#anatomy>.
  final MaterialStateProperty<Color?>? color;

  bool get _debugInteractive =>
      onSelectChanged != null ||
      cells.any((CustomDataCell cell) => cell._debugInteractive);
}

/// The data for a cell of a [DataTable].
///
/// One list of [DataCell] objects must be provided for each [DataRow]
/// in the [DataTable], in the new [DataRow] constructor's `cells`
/// argument.
@immutable
class CustomDataCell {
  /// Creates an object to hold the data for a cell in a [DataTable].
  ///
  /// The first argument is the widget to show for the cell, typically
  /// a [Text] or [DropdownButton] widget; this becomes the [child]
  /// property and must not be null.
  ///
  /// If the cell has no data, then a [Text] widget with placeholder
  /// text should be provided instead, and then the [placeholder]
  /// argument should be set to true.
  const CustomDataCell(
    this.child, {
    this.placeholder = false,
    this.showEditIcon = false,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.onDoubleTap,
    this.onTapCancel,
  }) : assert(child != null);

  /// A cell that has no content and has zero width and height.
  static const CustomDataCell empty =
      CustomDataCell(SizedBox(width: 0.0, height: 0.0));

  /// The data for the row.
  ///
  /// Typically a [Text] widget or a [DropdownButton] widget.
  ///
  /// If the cell has no data, then a [Text] widget with placeholder
  /// text should be provided instead, and [placeholder] should be set
  /// to true.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Whether the [child] is actually a placeholder.
  ///
  /// If this is true, the default text style for the cell is changed
  /// to be appropriate for placeholder text.
  final bool placeholder;

  /// Whether to show an edit icon at the end of the cell.
  ///
  /// This does not make the cell actually editable; the caller must
  /// implement editing behavior if desired (initiated from the
  /// [onTap] callback).
  ///
  /// If this is set, [onTap] should also be set, otherwise tapping
  /// the icon will have no effect.
  final bool showEditIcon;

  /// Called if the cell is tapped.
  ///
  /// If non-null, tapping the cell will call this callback. If
  /// null (including [onDoubleTap], [onLongPress], [onTapCancel] and [onTapDown]),
  /// tapping the cell will attempt to select the row (if
  /// [DataRow.onSelectChanged] is provided).
  final GestureTapCallback? onTap;

  /// Called when the cell is double tapped.
  ///
  /// If non-null, tapping the cell will call this callback. If
  /// null (including [onTap], [onLongPress], [onTapCancel] and [onTapDown]),
  /// tapping the cell will attempt to select the row (if
  /// [DataRow.onSelectChanged] is provided).
  final GestureTapCallback? onDoubleTap;

  /// Called if the cell is long-pressed.
  ///
  /// If non-null, tapping the cell will invoke this callback. If
  /// null (including [onDoubleTap], [onTap], [onTapCancel] and [onTapDown]),
  /// tapping the cell will attempt to select the row (if
  /// [DataRow.onSelectChanged] is provided).
  final GestureLongPressCallback? onLongPress;

  /// Called if the cell is tapped down.
  ///
  /// If non-null, tapping the cell will call this callback. If
  /// null (including [onTap] [onDoubleTap], [onLongPress] and [onTapCancel]),
  /// tapping the cell will attempt to select the row (if
  /// [DataRow.onSelectChanged] is provided).
  final GestureTapDownCallback? onTapDown;

  /// Called if the user cancels a tap was started on cell.
  ///
  /// If non-null, cancelling the tap gesture will invoke this callback.
  /// If null (including [onTap], [onDoubleTap] and [onLongPress]),
  /// tapping the cell will attempt to select the
  /// row (if [DataRow.onSelectChanged] is provided).
  final GestureTapCancelCallback? onTapCancel;

  bool get _debugInteractive =>
      onTap != null ||
      onDoubleTap != null ||
      onLongPress != null ||
      onTapDown != null ||
      onTapCancel != null;
}

/// A material design data table.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=ktTajqbhIcY}
///
/// Displaying data in a table is expensive, because to lay out the
/// table all the data must be measured twice, once to negotiate the
/// dimensions to use for each column, and once to actually lay out
/// the table given the results of the negotiation.
///
/// For this reason, if you have a lot of data (say, more than a dozen
/// rows with a dozen columns, though the precise limits depend on the
/// target device), it is suggested that you use a
/// [PaginatedDataTable] which automatically splits the data into
/// multiple pages.
///
/// {@tool dartpad --template=stateless_widget_scaffold}
///
/// This sample shows how to display a [DataTable] with three columns: name, age, and
/// role. The columns are defined by three [DataColumn] objects. The table
/// contains three rows of data for three example users, the data for which
/// is defined by three [DataRow] objects.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/material/data_table.png)
///
/// ```dart
/// Widget build(BuildContext context) {
///   return DataTable(
///     columns: const <DataColumn>[
///       DataColumn(
///         label: Text(
///           'Name',
///           style: TextStyle(fontStyle: FontStyle.italic),
///         ),
///       ),
///       DataColumn(
///         label: Text(
///           'Age',
///           style: TextStyle(fontStyle: FontStyle.italic),
///         ),
///       ),
///       DataColumn(
///         label: Text(
///           'Role',
///           style: TextStyle(fontStyle: FontStyle.italic),
///         ),
///       ),
///     ],
///     rows: const <DataRow>[
///       DataRow(
///         cells: <DataCell>[
///           DataCell(Text('Sarah')),
///           DataCell(Text('19')),
///           DataCell(Text('Student')),
///         ],
///       ),
///       DataRow(
///         cells: <DataCell>[
///           DataCell(Text('Janine')),
///           DataCell(Text('43')),
///           DataCell(Text('Professor')),
///         ],
///       ),
///       DataRow(
///         cells: <DataCell>[
///           DataCell(Text('William')),
///           DataCell(Text('27')),
///           DataCell(Text('Associate Professor')),
///         ],
///       ),
///     ],
///   );
/// }
/// ```
///
/// {@end-tool}
///
///
/// {@tool dartpad --template=stateful_widget_scaffold}
///
/// This sample shows how to display a [DataTable] with alternate colors per
/// row, and a custom color for when the row is selected.
///
/// ```dart
/// static const int numItems = 10;
/// List<bool> selected = List<bool>.generate(numItems, (int index) => false);
///
/// @override
/// Widget build(BuildContext context) {
///   return SizedBox(
///     width: double.infinity,
///     child: DataTable(
///       columns: const <DataColumn>[
///         DataColumn(
///           label: const Text('Number'),
///         ),
///       ],
///       rows: List<DataRow>.generate(
///         numItems,
///         (int index) => DataRow(
///           color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
///             // All rows will have the same selected color.
///             if (states.contains(MaterialState.selected))
///               return Theme.of(context).colorScheme.primary.withOpacity(0.08);
///             // Even rows will have a grey color.
///             if (index.isEven) {
///               return Colors.grey.withOpacity(0.3);
///             }
///             return null;  // Use default value for other states and odd rows.
///           }),
///           cells: <DataCell>[ DataCell(Text('Row $index')) ],
///           selected: selected[index],
///           onSelectChanged: (bool? value) {
///             setState(() {
///               selected[index] = value!;
///             });
///           },
///         ),
///       ),
///     ),
///   );
/// }
/// ```
/// {@end-tool}
///
/// [DataTable] can be sorted on the basis of any column in [columns] in
/// ascending or descending order. If [sortColumnIndex] is non-null, then the
/// table will be sorted by the values in the specified column. The boolean
/// [sortAscending] flag controls the sort order.
///
/// See also:
///
///  * [DataColumn], which describes a column in the data table.
///  * [DataRow], which contains the data for a row in the data table.
///  * [DataCell], which contains the data for a single cell in the data table.
///  * [PaginatedDataTable], which shows part of the data in a data table and
///    provides controls for paging through the remainder of the data.
///  * <https://material.io/design/components/data-tables.html>
class CustomDataTable extends StatefulWidget {
  /// Creates a widget describing a data table.
  ///
  /// The [columns] argument must be a list of as many [DataColumn]
  /// objects as the table is to have columns, ignoring the leading
  /// checkbox column if any. The [columns] argument must have a
  /// length greater than zero and must not be null.
  ///
  /// The [rows] argument must be a list of as many [DataRow] objects
  /// as the table is to have rows, ignoring the leading heading row
  /// that contains the column headings (derived from the [columns]
  /// argument). There may be zero rows, but the rows argument must
  /// not be null.
  ///
  /// Each [DataRow] object in [rows] must have as many [DataCell]
  /// objects in the [DataRow.cells] list as the table has columns.
  ///
  /// If the table is sorted, the column that provides the current
  /// primary key should be specified by index in [sortColumnIndex], 0
  /// meaning the first column in [columns], 1 being the next one, and
  /// so forth.
  ///
  /// The actual sort order can be specified using [sortAscending]; if
  /// the sort order is ascending, this should be true (the default),
  /// otherwise it should be false.
  ///
  ///
  final List<int> customColumnsIndex; //orders of columns
  final List<int> sortedIndexList;
  final List<ValueNotifier<bool>> showCheckboxList = <ValueNotifier<bool>>[];
  final ValueNotifier<bool> showCheckAllbox = ValueNotifier<bool>(false);
  Function(int column, int showColumnNumber) onSortColumn;
  int showColumnNumber;
  final Function(int showColumnNumber) setshowColumnNumber;
  double Function(int index) getColumnsWidth;
  String? addColumnTooltip;
  final double height;

  // bool isSortup;

  ///
  CustomDataTable({
    Key? key,
    required this.customColumnsIndex,
    required this.sortedIndexList,
    required this.columns,
    required this.onSortColumn,
    required this.showColumnNumber,
    required this.getColumnsWidth,
    required this.height,
    required this.setshowColumnNumber,
    this.addColumnTooltip,
    // required this.isSortup,
    this.sortColumnIndexList,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSelectAll,
    this.decoration,
    this.dataRowColor,
    this.dataRowHeight,
    this.dataTextStyle,
    this.headingRowColor,
    this.headingRowHeight,
    this.headingTextStyle,
    this.horizontalMargin,
    this.columnSpacing,
    this.showCheckboxColumn = true,
    this.showBottomBorder = false,
    this.dividerThickness,
    required this.rows,
    this.checkboxHorizontalMargin,
  })  : assert(columns != null),
        assert(columns.isNotEmpty),
        // assert(sortColumnIndex == null ||
        //     (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
        assert(sortColumnIndexList == null ||
            sortColumnIndexList.every((columnIndex) =>
                columnIndex >= 0 && columnIndex < columns.length)),
        assert(sortAscending != null),
        assert(showCheckboxColumn != null),
        assert(rows != null),
        assert(!rows
            .any((CustomDataRow row) => row.cells.length != columns.length)),
        assert(dividerThickness == null || dividerThickness >= 0),
        _onlyTextColumn = _initOnlyTextColumn(columns),
        super(key: key);

  /// The configuration and labels for the columns in the table.
  final List<CustomDataColumn> columns;

  /// The current primary sort key's column.
  ///
  /// If non-null, indicates that the indicated column is the column
  /// by which the data is sorted. The number must correspond to the
  /// index of the relevant column in [columns].
  ///
  /// Setting this will cause the relevant column to have a sort
  /// indicator displayed.
  ///
  /// When this is null, it implies that the table's sort order does
  /// not correspond to any of the columns.
  final List<int>? sortColumnIndexList;
  int? sortColumnIndex;

  /// Whether the column mentioned in [sortColumnIndex], if any, is sorted
  /// in ascending order.
  ///
  /// If true, the order is ascending (meaning the rows with the
  /// smallest values for the current sort column are first in the
  /// table).
  ///
  /// If false, the order is descending (meaning the rows with the
  /// smallest values for the current sort column are last in the
  /// table).
  final bool sortAscending;

  /// Invoked when the user selects or unselects every row, using the
  /// checkbox in the heading row.
  ///
  /// If this is null, then the [DataRow.onSelectChanged] callback of
  /// every row in the table is invoked appropriately instead.
  ///
  /// To control whether a particular row is selectable or not, see
  /// [DataRow.onSelectChanged]. This callback is only relevant if any
  /// row is selectable.
  final ValueSetter<bool?>? onSelectAll;

  /// {@template flutter.material.dataTable.decoration}
  /// The background and border decoration for the table.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.decoration] is used. By default there is no
  /// decoration.
  final Decoration? decoration;

  /// {@template flutter.material.dataTable.dataRowColor}
  /// The background color for the data rows.
  ///
  /// The effective background color can be made to depend on the
  /// [MaterialState] state, i.e. if the row is selected, pressed, hovered,
  /// focused, disabled or enabled. The color is painted as an overlay to the
  /// row. To make sure that the row's [InkWell] is visible (when pressed,
  /// hovered and focused), it is recommended to use a translucent background
  /// color.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.dataRowColor] is used. By default, the
  /// background color is transparent unless selected. Selected rows have a grey
  /// translucent color. To set a different color for individual rows, see
  /// [DataRow.color].
  ///
  /// {@template flutter.material.DataTable.dataRowColor}
  /// ```dart
  /// DataTable(
  ///   dataRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
  ///     if (states.contains(MaterialState.selected))
  ///       return Theme.of(context).colorScheme.primary.withOpacity(0.08);
  ///     return null;  // Use the default value.
  ///   }),
  /// )
  /// ```
  ///
  /// See also:
  ///
  ///  * The Material Design specification for overlay colors and how they
  ///    match a component's state:
  ///    <https://material.io/design/interaction/states.html#anatomy>.
  /// {@endtemplate}
  final MaterialStateProperty<Color?>? dataRowColor;

  /// {@template flutter.material.dataTable.dataRowHeight}
  /// The height of each row (excluding the row that contains column headings).
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.dataRowHeight] is used. This value defaults
  /// to [kMinInteractiveDimension] to adhere to the Material Design
  /// specifications.
  final double? dataRowHeight;

  /// {@template flutter.material.dataTable.dataTextStyle}
  /// The text style for data rows.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.dataTextStyle] is used. By default, the text
  /// style is [TextTheme.bodyText2].
  final TextStyle? dataTextStyle;

  /// {@template flutter.material.dataTable.headingRowColor}
  /// The background color for the heading row.
  ///
  /// The effective background color can be made to depend on the
  /// [MaterialState] state, i.e. if the row is pressed, hovered, focused when
  /// sorted. The color is painted as an overlay to the row. To make sure that
  /// the row's [InkWell] is visible (when pressed, hovered and focused), it is
  /// recommended to use a translucent color.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.headingRowColor] is used.
  ///
  /// {@template flutter.material.DataTable.headingRowColor}
  /// ```dart
  /// DataTable(
  ///   headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
  ///     if (states.contains(MaterialState.hovered))
  ///       return Theme.of(context).colorScheme.primary.withOpacity(0.08);
  ///     return null;  // Use the default value.
  ///   }),
  /// )
  /// ```
  ///
  /// See also:
  ///
  ///  * The Material Design specification for overlay colors and how they
  ///    match a component's state:
  ///    <https://material.io/design/interaction/states.html#anatomy>.
  /// {@endtemplate}
  final MaterialStateProperty<Color?>? headingRowColor;

  /// {@template flutter.material.dataTable.headingRowHeight}
  /// The height of the heading row.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.headingRowHeight] is used. This value
  /// defaults to 56.0 to adhere to the Material Design specifications.
  final double? headingRowHeight;

  /// {@template flutter.material.dataTable.headingTextStyle}
  /// The text style for the heading row.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.headingTextStyle] is used. By default, the
  /// text style is [TextTheme.subtitle2].
  final TextStyle? headingTextStyle;

  /// {@template flutter.material.dataTable.horizontalMargin}
  /// The horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  ///
  /// When a checkbox is displayed, it is also the margin between the checkbox
  /// the content in the first data column.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.horizontalMargin] is used. This value
  /// defaults to 24.0 to adhere to the Material Design specifications.
  ///
  /// If [checkboxHorizontalMargin] is null, then [horizontalMargin] is also the
  /// margin between the edge of the table and the checkbox, as well as the
  /// margin between the checkbox and the content in the first data column.
  final double? horizontalMargin;

  /// {@template flutter.material.dataTable.columnSpacing}
  /// The horizontal margin between the contents of each data column.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.columnSpacing] is used. This value defaults
  /// to 56.0 to adhere to the Material Design specifications.
  final double? columnSpacing;

  /// {@template flutter.material.dataTable.showCheckboxColumn}
  /// Whether the widget should display checkboxes for selectable rows.
  ///
  /// If true, a [Checkbox] will be placed at the beginning of each row that is
  /// selectable. However, if [DataRow.onSelectChanged] is not set for any row,
  /// checkboxes will not be placed, even if this value is true.
  ///
  /// If false, all rows will not display a [Checkbox].
  /// {@endtemplate}
  final bool showCheckboxColumn;

  /// The data to show in each row (excluding the row that contains
  /// the column headings).
  ///
  /// Must be non-null, but may be empty.
  final List<CustomDataRow> rows;

  /// {@template flutter.material.dataTable.dividerThickness}
  /// The width of the divider that appears between [TableRow]s.
  ///
  /// Must be greater than or equal to zero.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.dividerThickness] is used. This value
  /// defaults to 1.0.
  final double? dividerThickness;

  /// Whether a border at the bottom of the table is displayed.
  ///
  /// By default, a border is not shown at the bottom to allow for a border
  /// around the table defined by [decoration].
  final bool showBottomBorder;

  /// {@template flutter.material.dataTable.checkboxHorizontalMargin}
  /// Horizontal margin around the checkbox, if it is displayed.
  /// {@endtemplate}
  ///
  /// If null, [DataTableThemeData.checkboxHorizontalMargin] is used. If that is
  /// also null, then [horizontalMargin] is used as the margin between the edge
  /// of the table and the checkbox, as well as the margin between the checkbox
  /// and the content in the first data column. This value defaults to 24.0.
  final double? checkboxHorizontalMargin;

  // Set by the constructor to the index of the only Column that is
  // non-numeric, if there is exactly one, otherwise null.
  final int? _onlyTextColumn;
  static int? _initOnlyTextColumn(List<CustomDataColumn> columns) {
    int? result;
    for (int index = 0; index < columns.length; index += 1) {
      final CustomDataColumn column = columns[index];
      if (!column.numeric) {
        if (result != null) return null;
        result = index;
      }
    }
    return result;
  }

  static final LocalKey _headingRowKey = UniqueKey();

  /// The default height of the heading row.
  static const double _headingRowHeight = 56.0;

  /// The default horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  static const double _horizontalMargin = 24.0;

  /// The default horizontal margin between the contents of each data column.
  static const double _columnSpacing = 56.0;

  /// The default padding between the heading content and sort arrow.
  static const double _sortArrowPadding = 2.0;

  /// The default divider thickness.
  static const double _dividerThickness = 1.0;

  static const Duration _sortArrowAnimationDuration =
      Duration(milliseconds: 150);

  @override
  _CustomDataTableState createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  bool get _debugInteractive {
    return widget.columns
            .any((CustomDataColumn column) => column._debugInteractive) ||
        widget.rows.any((CustomDataRow row) => row._debugInteractive);
  }

  void _handleSelectAll(bool? checked, ValueNotifier<bool> allChecked) {
    // If some checkboxes are checked, all checkboxes are selected. Otherwise,
    // use the new checked value but default to false if it's null.
    // final bool effectiveChecked = someChecked || (checked ?? false);
    // if (widget.onSelectAll != null) {
    //   widget.onSelectAll!(effectiveChecked);
    // } else {
    //   for (final CustomDataRow row in widget.rows) {
    //     if (row.onSelectChanged != null &&
    //         row.selected.value != effectiveChecked)
    //       row.onSelectChanged!(effectiveChecked);
    //   }
    // }

    allChecked.value = !allChecked.value;
    for (final CustomDataRow row in widget.rows) {
      row.selected.value = allChecked.value;
    }
  }

  void _handleCancleSort() {
    if (widget.sortColumnIndex != null) {
      setState(() {
        widget.sortColumnIndex = null;
      });
    }
  }

  Widget _buildCheckbox({
    required BuildContext context,
    required ValueNotifier<bool> checked,
    required ValueNotifier<bool> showCheckbox,
    required VoidCallback? onRowTap,
    required ValueChanged<bool?>? onCheckboxChanged,
    required MaterialStateProperty<Color?>? overlayColor,
    required bool tristate,
  }) {
    final ThemeData themeData = Theme.of(context);
    final double effectiveHorizontalMargin = widget.horizontalMargin ??
        themeData.dataTableTheme.horizontalMargin ??
        CustomDataTable._horizontalMargin;
    final double effectiveCheckboxHorizontalMarginStart =
        widget.checkboxHorizontalMargin ??
            themeData.dataTableTheme.checkboxHorizontalMargin ??
            effectiveHorizontalMargin;
    final double effectiveCheckboxHorizontalMarginEnd =
        widget.checkboxHorizontalMargin ??
            themeData.dataTableTheme.checkboxHorizontalMargin ??
            effectiveHorizontalMargin / 2.0;

    // Widget checkbox = ValueListenableBuilder<bool>(
    //     valueListenable: checked,
    //     builder: (_, checked, __) {
    //       return Checkbox(
    //         // TODO(per): Remove when Checkbox has theme, https://github.com/flutter/flutter/issues/53420.
    //         activeColor: themeData.colorScheme.primary,
    //         checkColor: themeData.colorScheme.onPrimary,
    //         value: checked,
    //         onChanged: onCheckboxChanged,
    //         tristate: tristate,
    //       );
    //     });

    // Widget showedCheckbox = ValueListenableBuilder<bool>(valueListenable: showCheckbox, builder: (_,showCheckbox,__){
    //   return SizedBox(child: Visibility(child: checkbox ,visible: showCheckbox || checked.value),width: Checkbox.width,);
    // });

    Widget shownCheckbox = ValueListenableBuilder<bool>(
        valueListenable: checked,
        builder: (_, checked, __) {
          return ValueListenableBuilder<bool>(
              valueListenable: showCheckbox,
              builder: (_, showCheckbox, __) {
                return SizedBox(
                  child: Visibility(
                      child: Checkbox(
                        // TODO(per): Remove when Checkbox has theme, https://github.com/flutter/flutter/issues/53420.
                        activeColor: themeData.colorScheme.primary,
                        checkColor: themeData.colorScheme.onPrimary,
                        value: checked,
                        onChanged: onCheckboxChanged,
                        tristate: tristate,
                      ),
                      visible: showCheckbox || checked),
                  width: Checkbox.width,
                  height: Checkbox.width,
                );
              });
        });

    Widget contents = Semantics(
      container: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: effectiveCheckboxHorizontalMarginStart,
          end: effectiveCheckboxHorizontalMarginEnd,
        ),
        child: Center(
          child: shownCheckbox,
        ),
      ),
    );
    if (onRowTap != null) {
      contents = TableRowInkWell(
        onTap: () => onCheckboxChanged!(false),
        child: contents,
        overlayColor: overlayColor,
      );
    }

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: contents,
    );
  }

  Widget _buildHeadingCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget label,
    required String? tooltip,
    required bool numeric,
    required VoidCallback? onSort,
    required bool sorted,
    required bool ascending,
    required MaterialStateProperty<Color?>? overlayColor,
  }) {
    final ThemeData themeData = Theme.of(context);
    label = Row(
      textDirection: numeric ? TextDirection.rtl : null,
      children: <Widget>[
        label,
        if (sorted) ...<Widget>[
          _SortArrow(
            visible: sorted,
            up: sorted ? ascending : null,
            duration: CustomDataTable._sortArrowAnimationDuration,
          ),
          const SizedBox(width: CustomDataTable._sortArrowPadding),
        ],
      ],
    );

    final TextStyle effectiveHeadingTextStyle = widget.headingTextStyle ??
        themeData.dataTableTheme.headingTextStyle ??
        themeData.textTheme.subtitle2!;
    final double effectiveHeadingRowHeight = widget.headingRowHeight ??
        themeData.dataTableTheme.headingRowHeight ??
        CustomDataTable._headingRowHeight;
    label = Container(
      padding: padding,
      height: effectiveHeadingRowHeight,
      alignment:
          numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: AnimatedDefaultTextStyle(
        style: effectiveHeadingTextStyle,
        softWrap: false,
        duration: CustomDataTable._sortArrowAnimationDuration,
        child: label,
      ),
    );
    if (tooltip != null) {
      label = Tooltip(
        message: tooltip,
        child: label,
      );
    }

    // TODO(dkwingsmt): Only wrap Inkwell if onSort != null. Blocked by
    // https://github.com/flutter/flutter/issues/51152
    label = InkWell(
      onTap: onSort,
      overlayColor: overlayColor,
      child: label,
    );
    return label;
  }

  Widget _buildDataCell({
    required BuildContext context,
    required EdgeInsetsGeometry padding,
    required Widget label,
    required bool numeric,
    required bool placeholder,
    required bool showEditIcon,
    required GestureTapCallback? onTap,
    required VoidCallback? onSelectChanged,
    required GestureTapCallback? onDoubleTap,
    required GestureLongPressCallback? onLongPress,
    required GestureTapDownCallback? onTapDown,
    required GestureTapCancelCallback? onTapCancel,
    required MaterialStateProperty<Color?>? overlayColor,
  }) {
    final ThemeData themeData = Theme.of(context);
    if (showEditIcon) {
      const Widget icon = Icon(Icons.edit, size: 18.0);
      label = Expanded(child: label);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[label, icon],
      );
    }

    final TextStyle effectiveDataTextStyle = widget.dataTextStyle ??
        themeData.dataTableTheme.dataTextStyle ??
        themeData.textTheme.bodyText2!;
    final double effectiveDataRowHeight = widget.dataRowHeight ??
        themeData.dataTableTheme.dataRowHeight ??
        kMinInteractiveDimension;
    label = Container(
      padding: padding,
      height: effectiveDataRowHeight,
      alignment:
          numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: DefaultTextStyle(
        style: effectiveDataTextStyle.copyWith(
          color: placeholder
              ? effectiveDataTextStyle.color!.withOpacity(0.6)
              : null,
        ),
        child: DropdownButtonHideUnderline(child: label),
      ),
    );
    if (onTap != null ||
        onDoubleTap != null ||
        onLongPress != null ||
        onTapDown != null ||
        onTapCancel != null) {
      label = InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onTapCancel: onTapCancel,
        onTapDown: onTapDown,
        child: label,
        overlayColor: overlayColor,
      );
    } else if (onSelectChanged != null) {
      label = TableRowInkWell(
        onTap: onSelectChanged,
        child: label,
        overlayColor: overlayColor,
        onHover: (value) => {}, //print("onHover $value"), //on row Hover
      );
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    assert(!_debugInteractive || debugCheckHasMaterial(context));

    final ThemeData theme = Theme.of(context);
    final MaterialStateProperty<Color?>? effectiveHeadingRowColor =
        widget.headingRowColor ?? theme.dataTableTheme.headingRowColor;
    final MaterialStateProperty<Color?>? effectiveDataRowColor =
        widget.dataRowColor ?? theme.dataTableTheme.dataRowColor;
    final MaterialStateProperty<Color?> defaultRowColor =
        MaterialStateProperty.resolveWith(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected))
          return theme.colorScheme.primary.withOpacity(0.08);
        return null;
      },
    );
    final bool anyRowSelectable =
        widget.rows.any((CustomDataRow row) => row.onSelectChanged != null);
    final bool displayCheckboxColumn =
        widget.showCheckboxColumn && anyRowSelectable;
    final Iterable<CustomDataRow> rowsWithCheckbox = displayCheckboxColumn
        ? widget.rows.where((CustomDataRow row) => row.onSelectChanged != null)
        : <CustomDataRow>[];
    final Iterable<CustomDataRow> rowsChecked =
        rowsWithCheckbox.where((CustomDataRow row) => row.selected.value);
    final ValueNotifier<bool> allChecked = ValueNotifier<bool>(
        displayCheckboxColumn && rowsChecked.length == rowsWithCheckbox.length);
    final bool anyChecked = displayCheckboxColumn && rowsChecked.isNotEmpty;
    final bool someChecked = anyChecked && !allChecked.value;
    final double effectiveHorizontalMargin = widget.horizontalMargin ??
        theme.dataTableTheme.horizontalMargin ??
        CustomDataTable._horizontalMargin;
    final double effectiveCheckboxHorizontalMarginStart =
        widget.checkboxHorizontalMargin ??
            theme.dataTableTheme.checkboxHorizontalMargin ??
            effectiveHorizontalMargin;
    final double effectiveCheckboxHorizontalMarginEnd =
        widget.checkboxHorizontalMargin ??
            theme.dataTableTheme.checkboxHorizontalMargin ??
            effectiveHorizontalMargin / 2.0;
    final double effectiveColumnSpacing = widget.columnSpacing ??
        theme.dataTableTheme.columnSpacing ??
        CustomDataTable._columnSpacing;

    final List<TableColumnWidth> tableColumns = List<TableColumnWidth>.filled(
        widget.columns.length + (displayCheckboxColumn ? 1 : 0),
        const _NullTableColumnWidth());
    final List<TableRow> tableRows = List<TableRow>.generate(
      widget.rows.length + 1, // the +1 is for the header row
      (int index) {
        final bool isSelected =
            index > 0 && widget.rows[index - 1].selected.value;
        final bool isDisabled = index > 0 &&
            anyRowSelectable &&
            widget.rows[index - 1].onSelectChanged == null;
        final Set<MaterialState> states = <MaterialState>{
          if (isSelected) MaterialState.selected,
          if (isDisabled) MaterialState.disabled,
        };
        final Color? resolvedDataRowColor = index > 0
            ? (widget.rows[index - 1].color ?? effectiveDataRowColor)
                ?.resolve(states)
            : null;
        final Color? resolvedHeadingRowColor =
            effectiveHeadingRowColor?.resolve(<MaterialState>{});
        final Color? rowColor =
            index > 0 ? resolvedDataRowColor : resolvedHeadingRowColor;
        final BorderSide borderSide = Divider.createBorderSide(
          context,
          width: widget.dividerThickness ??
              theme.dataTableTheme.dividerThickness ??
              CustomDataTable._dividerThickness,
        );
        final Border? border = widget.showBottomBorder
            ? Border(bottom: borderSide)
            : index == 0
                ? null
                : Border(top: borderSide);
        return TableRow(
          key: index == 0
              ? CustomDataTable._headingRowKey
              : widget.rows[index - 1].key,
          decoration: BoxDecoration(
            border: border,
            color: rowColor ?? defaultRowColor.resolve(states),
          ),
          children: List<Widget>.filled(
              widget.showColumnNumber + (widget.showCheckboxColumn ? 1 : 0),
              const _NullWidget()),
        );
      },
    );

    int rowIndex;

    int displayColumnIndex = 0;
    if (displayCheckboxColumn) {
      tableColumns[0] = FixedColumnWidth(
          effectiveCheckboxHorizontalMarginStart +
              Checkbox.width +
              effectiveCheckboxHorizontalMarginEnd);
      tableRows[0].children![0] = _buildCheckbox(
        context: context,
        checked: allChecked, //someChecked ? null : allChecked
        showCheckbox: widget.showCheckAllbox,
        onRowTap: null,
        onCheckboxChanged: (bool? checked) =>
            _handleSelectAll(checked, allChecked),
        overlayColor: null,
        tristate: true,
      );
      rowIndex = 1;
      bool showCheckboxNotBuilded = widget.showCheckboxList.isEmpty;
      for (final CustomDataRow row in widget.rows) {
        final ValueNotifier<bool> showCheckbox = ValueNotifier<bool>(false);
        if (showCheckboxNotBuilded) widget.showCheckboxList.add(showCheckbox);
        tableRows[rowIndex].children![0] = _buildCheckbox(
          context: context,
          checked: row.selected,
          showCheckbox: showCheckboxNotBuilded
              ? showCheckbox
              : widget.showCheckboxList[rowIndex - 1],
          onRowTap:
              () {}, //print("custom row handler"), //Taprow rowTap onRowTap
          onCheckboxChanged: (value) {
            row.onSelectChanged!(value);
            allChecked.value = widget.rows.every((row) => row.selected.value);
          },
          overlayColor: row.color ?? effectiveDataRowColor,
          tristate: false,
        );
        rowIndex += 1;
      }
      displayColumnIndex += 1;
    }

    for (int columnIndex = 0;
        columnIndex < widget.showColumnNumber;
        columnIndex += 1) {
      final dataColumnIndex =
          widget.customColumnsIndex[columnIndex]; // reorder columnindex

      final CustomDataColumn column = widget.columns[dataColumnIndex];
      final double columnWidth = widget.getColumnsWidth(dataColumnIndex);

      final double paddingStart;
      if (dataColumnIndex == 0 &&
          displayCheckboxColumn &&
          widget.checkboxHorizontalMargin != null) {
        paddingStart = effectiveHorizontalMargin;
      } else if (dataColumnIndex == 0 && displayCheckboxColumn) {
        paddingStart = effectiveHorizontalMargin / 2.0;
      } else if (dataColumnIndex == 0 && !displayCheckboxColumn) {
        paddingStart = effectiveHorizontalMargin;
      } else {
        paddingStart = effectiveColumnSpacing / 2.0;
      }

      final double paddingEnd;
      if (dataColumnIndex == widget.columns.length - 1) {
        paddingEnd = effectiveHorizontalMargin;
      } else {
        paddingEnd = effectiveColumnSpacing / 2.0;
      }

      final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
        start: effectiveColumnSpacing / 2.0, //paddingStart,
        end: effectiveColumnSpacing / 2.0, //paddingEnd,
      );
      if (dataColumnIndex == widget._onlyTextColumn) {
        tableColumns[displayColumnIndex] =
            const IntrinsicColumnWidth(flex: 1.0);
      } else {
        tableColumns[displayColumnIndex] = const IntrinsicColumnWidth();
      }
      tableRows[0].children![displayColumnIndex] = _buildHeadingCell(
        context: context,
        padding: padding,
        label: SizedBox(
          child: column.label,
          width: columnWidth,
        ),
        tooltip: column.tooltip,
        numeric: column.numeric,
        onSort: column.onSort != null
            ? () => column.onSort!(
                dataColumnIndex,
                widget.sortColumnIndex != dataColumnIndex ||
                    !widget.sortAscending)
            : null,
        sorted: dataColumnIndex == widget.sortColumnIndex,
        ascending: widget.sortAscending,
        overlayColor: effectiveHeadingRowColor,
      );
      rowIndex = 1;
      for (final CustomDataRow row in widget.rows) {
        final CustomDataCell cell = row.cells[dataColumnIndex];
        tableRows[rowIndex].children![displayColumnIndex] = _buildDataCell(
          context: context,
          padding: padding,
          label: widget.customColumnsIndex[displayColumnIndex -
                      (widget.showCheckboxColumn ? 1 : 0)] ==
                  widget.sortColumnIndex
              ? Row(
                  children: [
                    SizedBox(
                        child: cell.child,
                        width: widget.getColumnsWidth(dataColumnIndex) + 16),
                  ],
                )
              : SizedBox(
                  child: cell.child,
                  width: widget.getColumnsWidth(dataColumnIndex),
                ),
          numeric: column.numeric,
          placeholder: cell.placeholder,
          showEditIcon: cell.showEditIcon,
          onTap: cell.onTap,
          onDoubleTap: cell.onDoubleTap,
          onLongPress: cell.onLongPress,
          onTapCancel: cell.onTapCancel,
          onTapDown: cell.onTapDown,
          onSelectChanged: () {}, //=> print("select cell"), //cellTap
          overlayColor: row.color ?? effectiveDataRowColor,
        );
        rowIndex += 1;
      }
      displayColumnIndex += 1;
    }

    // Widget addColumnButton = PopupMenuButton<int>(
    //     itemBuilder: (context) => widget.customColumnsIndex
    //         .sublist(widget.showColumnNumber)
    //         .map<PopupMenuEntry<int>>((value) =>
    //             PopupMenuItem(child: widget.columns[value].label, value: value))
    //         .toList(),
    //     onSelected: (index) {
    //       setState(() {
    //         widget.customColumnsIndex.remove(index);
    //         widget.customColumnsIndex.insert(widget.showColumnNumber++, index);
    //       });
    //     });

    // Widget dropColumnBox = DragTarget(
    //   builder: (_, __, ___) => addColumnButton,
    //   onAccept: (ValueKey item) {
    //     setState(() {
    //       widget.showColumnNumber--;
    //     });
    //     print(widget.customColumnsIndex);
    //     print(widget.showColumnNumber);
    //   },
    // );

    Widget buildAddColumnCheckbox(
        ValueNotifier<bool> checkedNotifier, Widget heading) {
      return ValueListenableBuilder<bool>(
          valueListenable: checkedNotifier,
          builder: (_, checked, __) {
            return InkWell(
              child: Row(
                children: [
                  Checkbox(
                    // TODO(per): Remove when Checkbox has theme, https://github.com/flutter/flutter/issues/53420.
                    activeColor: Theme.of(context).colorScheme.primary,
                    checkColor: Theme.of(context).colorScheme.onPrimary,
                    value: checked,
                    onChanged: (_) {
                      checkedNotifier.value = !checkedNotifier.value;
                    },
                    tristate: false,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  heading,
                ],
              ),
              onTap: () => checkedNotifier.value = !checkedNotifier.value,
            );
          });
    }

    Widget buildAddColumnBox(
        ValueNotifier<bool> checkedNotifier, Widget heading) {
      return InkWell(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(children: [
            ValueListenableBuilder<bool>(
                valueListenable: checkedNotifier,
                builder: (_, checked, __) {
                  return checked
                      ? Icon(Icons.check, size: 19, color: Colors.green)
                      : SizedBox(
                          width: 19,
                        );
                }),
            SizedBox(
              width: 20,
            ),
            heading,
          ]),
        ),
        onTap: () => checkedNotifier.value = !checkedNotifier.value,
      );
    }

    List<ValueNotifier<bool>> shownHeader = List.generate(
        widget.columns.length,
        (index) => ValueNotifier<bool>(widget.customColumnsIndex
            .sublist(0, widget.showColumnNumber)
            .contains(index)));

    // List<Widget> headerMenu = widget.columns
    //       .map<Widget>((value) => buildAddColumnCheckbox(
    //           widget.customColumnsIndex
    //               .sublist(0, widget.showColumnNumber)
    //               .contains(value),
    //           value.label))
    //       .toList();

    List<Widget> headerMenu = List.generate(
        widget.columns.length,
        (index) => buildAddColumnBox(
            //buildAddColumnCheckbox(
            shownHeader[index],
            widget.columns[index].label));

    // Widget headerMenu = Column(
    //   children:
    // );

    Widget addColumnButton = PopupMenuButton<int>(
      tooltip: widget.addColumnTooltip,
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Column(children: headerMenu),
        )
      ],
      onCanceled: () {
        List<int> toAdd = [];
        List<int> toRemove = [];
        for (int index = 0; index < widget.columns.length; index++) {
          bool isShown = widget.customColumnsIndex
              .sublist(0, widget.showColumnNumber)
              .contains(index);
          // print("$index $isShown");
          if (isShown != shownHeader[index].value) {
            if (shownHeader[index].value) {
              toAdd.add(index);
            } else {
              toRemove.add(index);
            }
          }
        }
        // print(toAdd);
        // print(toRemove);

        widget.customColumnsIndex.removeWhere(
            (index) => toRemove.contains(index) || toAdd.contains(index));

        widget.showColumnNumber -= toRemove.length;

        for (int index in toAdd) {
          widget.customColumnsIndex.insert(widget.showColumnNumber++, index);
        }

        widget.customColumnsIndex.addAll(toRemove);
        // print(widget.customColumnsIndex);
        widget.setshowColumnNumber(widget.showColumnNumber);
        setState(() {});
      },
    );

    // Widget addColumnButton = TextButton(onPressed: (){
    //   final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    // final RenderBox button = context.findRenderObject()! as RenderBox;
    // final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    // final RelativeRect position = RelativeRect.fromRect(
    //   Rect.fromPoints(
    //     button.localToGlobal(Offset.zero, ancestor: overlay),
    //     button.localToGlobal(button.size.bottomRight (Offset.zero) + Offset.zero, ancestor: overlay),
    //   ),
    //   Offset.zero & overlay.size,
    // );
    // final List<PopupMenuEntry<int>> items = [
    //   PopupMenuItem(
    //     child: Text("data"),
    //     value: 5,
    //   ),
    //   PopupMenuItem(
    //     child: Text("data"),
    //     value: 4,
    //   ),
    // ];
    // // Only show the menu if there is something to show
    // if (items.isNotEmpty) {
    //   // showMenu<int?>(
    //   //   context: context,
    //   //   elevation: popupMenuTheme.elevation,
    //   //   items: items,
    //   //   initialValue: 0,
    //   //   position: position,
    //   //   shape: popupMenuTheme.shape,
    //   //   color: popupMenuTheme.color,
    //   // );
    //   showMenu(context: context, position: position, items: items);
    //   // showDialog(context: context, builder: (context) => AlertDialog(
    //   //   content: InkResponse(
    //   //     onTap: () {
    //   //       Navigator.of(context).pop();
    //   //     },
    //   //     child: CircleAvatar(
    //   //       child: Icon(Icons.close),
    //   //       backgroundColor: Colors.red,
    //   //     ),
    //   //   ),
    //   // ));
    //   }
    // }, child: Text("hello world"));

    // Widget addColumnButton = IconButton(
    //   onPressed: () {
    //     // showModalBottomSheet(context: context, builder: (context) => Card());
    //     showMenu(context: context, position: RelativeRect.fill, items: items)
    //   },
    //   icon: Icon(Icons.add_box),
    // );

    Widget header = Row(children: [
      if (widget.showCheckboxColumn)
        InkWell(
          child: (tableRows[0].children![0] as TableCell).child,
          onHover: (isHover) => widget.showCheckAllbox.value = isHover,
          onTap: () {},
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      CustomAdjustHeaderIndex(
        columns: widget.showCheckboxColumn
            ? tableRows[0].children!.sublist(1, widget.showColumnNumber + 1)
            : tableRows[0].children!.sublist(0, widget.showColumnNumber),
        moveHeadingIndex: (oldIndex, newIndex) {
          // print(widget.customColumnsIndex);

          int colIndex = widget.customColumnsIndex.removeAt(oldIndex);
          widget.customColumnsIndex.insert(newIndex, colIndex);

          // print(widget.customColumnsIndex);
          setState(() {});
        },
        onRowHover: (isHover) => widget.showCheckAllbox.value = isHover,
        sortColumnIndexList: widget.sortColumnIndexList,
        columnIndexlist: widget.customColumnsIndex,
        onSortIndex: (index) {
          widget.onSortColumn(index, widget.showColumnNumber);
        },
      ),
      addColumnButton,
    ]);

    double width = 0;

    widget.customColumnsIndex.sublist(0, widget.showColumnNumber).forEach(
        (index) =>
            width += widget.getColumnsWidth(index) + effectiveColumnSpacing);

    if (widget.showCheckboxColumn)
      width += effectiveHorizontalMargin * 2 + Checkbox.width;
    if (widget.customColumnsIndex
        .sublist(0, widget.showColumnNumber)
        .contains(widget.sortColumnIndex)) width += 20;

    Widget table = CustomAdjustRowIndex(
      width: width + 27.5,
      height: widget.height,
      cancleSort: _handleCancleSort,
      columns: List.generate(
        tableRows.length - 1,
        (index) => widget.showCheckboxColumn
            ? ValueListenableBuilder<bool>(
                valueListenable: widget.rows[index].selected,
                builder: (_, selected, __) {
                  final bool isSelected = widget.rows[index].selected.value;
                  final bool isDisabled = index > 0 &&
                      anyRowSelectable &&
                      widget.rows[index].onSelectChanged == null;
                  final Set<MaterialState> states = <MaterialState>{
                    if (isSelected) MaterialState.selected,
                    if (isDisabled) MaterialState.disabled,
                  };
                  final BorderSide borderSide = Divider.createBorderSide(
                    context,
                    width: widget.dividerThickness ??
                        theme.dataTableTheme.dividerThickness ??
                        CustomDataTable._dividerThickness,
                  );
                  final Border? border = widget.showBottomBorder
                      ? Border(bottom: borderSide)
                      : index == 0
                          ? null
                          : Border(top: borderSide);
                  final Color? resolvedDataRowColor = index > 0
                      ? (widget.rows[index - 1].color ?? effectiveDataRowColor)
                          ?.resolve(states)
                      : null;
                  final Color? resolvedHeadingRowColor =
                      effectiveHeadingRowColor?.resolve(<MaterialState>{});
                  final Color? rowColor = index > 0
                      ? resolvedDataRowColor
                      : resolvedHeadingRowColor;
                  tableRows[index + 1] = TableRow(
                    key: widget.rows[index].key,
                    decoration: BoxDecoration(
                      border: border,
                      color: rowColor ?? defaultRowColor.resolve(states),
                    ),
                    children: tableRows[index + 1]
                        .children!
                        .sublist(0, widget.showColumnNumber + 1),
                  );

                  return InkWell(
                    child: Table(
                      columnWidths: tableColumns.asMap(),
                      children: [tableRows[index + 1]],
                      key: UniqueKey(),
                    ),
                    onTap: () {},
                    onHover: widget.showCheckboxColumn
                        ? (isHover) =>
                            widget.showCheckboxList[index].value = isHover
                        : null,
                  );
                })
            : Table(
                columnWidths: tableColumns.asMap(),
                children: [tableRows[index + 1]],
                key: UniqueKey(),
              ),
      ),
      sortedIndexList: widget.sortedIndexList,
    );

    return Container(
      decoration: widget.decoration ?? theme.dataTableTheme.decoration,
      child: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              table,
            ],
          ),
        ),
      ),
    );
  }
}

/// A rectangular area of a Material that responds to touch but clips
/// its ink splashes to the current table row of the nearest table.
///
/// Must have an ancestor [Material] widget in which to cause ink
/// reactions and an ancestor [Table] widget to establish a row.
///
/// The [TableRowInkWell] must be in the same coordinate space (modulo
/// translations) as the [Table]. If it's rotated or scaled or
/// otherwise transformed, it will not be able to describe the
/// rectangle of the row in its own coordinate system as a [Rect], and
/// thus the splash will not occur. (In general, this is easy to
/// achieve: just put the [TableRowInkWell] as the direct child of the
/// [Table], and put the other contents of the cell inside it.)
///
/// See also:
///
///  * [DataTable], which makes use of [TableRowInkWell] when
///    [DataRow.onSelectChanged] is defined and [DataCell.onTap]
///    is not.
class TableRowInkWell extends InkResponse {
  /// Creates an ink well for a table row.
  const TableRowInkWell({
    Key? key,
    Widget? child,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    ValueChanged<bool>? onHighlightChanged,
    MaterialStateProperty<Color?>? overlayColor,
    Function(bool)? onHover,
  }) : super(
          key: key,
          child: child,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          onHighlightChanged: onHighlightChanged,
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          overlayColor: overlayColor,
          onHover: onHover,
        );

  @override
  RectCallback getRectCallback(RenderBox referenceBox) {
    return () {
      RenderObject cell = referenceBox;
      AbstractNode? table = cell.parent;
      final Matrix4 transform = Matrix4.identity();
      while (table is RenderObject && table is! RenderTable) {
        table.applyPaintTransform(cell, transform);
        assert(table == cell.parent);
        cell = table;
        table = table.parent;
      }
      if (table is RenderTable) {
        final TableCellParentData cellParentData =
            cell.parentData! as TableCellParentData;
        assert(cellParentData.y != null);
        final Rect rect = table.getRowBox(cellParentData.y!);
        // The rect is in the table's coordinate space. We need to change it to the
        // TableRowInkWell's coordinate space.
        table.applyPaintTransform(cell, transform);
        final Offset? offset = MatrixUtils.getAsTranslation(transform);
        if (offset != null) return rect.shift(-offset);
      }
      return Rect.zero;
    };
  }

  @override
  bool debugCheckContext(BuildContext context) {
    assert(debugCheckHasTable(context));
    return super.debugCheckContext(context);
  }
}

class _SortArrow extends StatefulWidget {
  const _SortArrow({
    Key? key,
    required this.visible,
    required this.up,
    required this.duration,
  }) : super(key: key);

  final bool visible;

  final bool? up;

  final Duration duration;

  @override
  _SortArrowState createState() => _SortArrowState();
}

class _SortArrowState extends State<_SortArrow> with TickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

  late AnimationController _orientationController;
  late Animation<double> _orientationAnimation;
  double _orientationOffset = 0.0;

  bool? _up;

  static final Animatable<double> _turnTween =
      Tween<double>(begin: 0.0, end: math.pi)
          .chain(CurveTween(curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _opacityAnimation = CurvedAnimation(
      parent: _opacityController = AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
      curve: Curves.fastOutSlowIn,
    )..addListener(_rebuild);
    _opacityController.value = widget.visible ? 1.0 : 0.0;
    _orientationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _orientationAnimation = _orientationController.drive(_turnTween)
      ..addListener(_rebuild)
      ..addStatusListener(_resetOrientationAnimation);
    if (widget.visible) _orientationOffset = widget.up! ? 0.0 : math.pi;
  }

  void _rebuild() {
    setState(() {
      // The animations changed, so we need to rebuild.
    });
  }

  void _resetOrientationAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      assert(_orientationAnimation.value == math.pi);
      _orientationOffset += math.pi;
      _orientationController.value =
          0.0; // TODO(ianh): This triggers a pointless rebuild.
    }
  }

  @override
  void didUpdateWidget(_SortArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool skipArrow = false;
    final bool? newUp = widget.up ?? _up;
    if (oldWidget.visible != widget.visible) {
      if (widget.visible &&
          (_opacityController.status == AnimationStatus.dismissed)) {
        _orientationController.stop();
        _orientationController.value = 0.0;
        _orientationOffset = newUp! ? 0.0 : math.pi;
        skipArrow = true;
      }
      if (widget.visible) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
    if ((_up != newUp) && !skipArrow) {
      if (_orientationController.status == AnimationStatus.dismissed) {
        _orientationController.forward();
      } else {
        _orientationController.reverse();
      }
    }
    _up = newUp;
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _orientationController.dispose();
    super.dispose();
  }

  static const double _arrowIconBaselineOffset = -1.5;
  static const double _arrowIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Transform(
        transform:
            Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value)
              ..setTranslationRaw(0.0, _arrowIconBaselineOffset, 0.0),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_upward,
          size: _arrowIconSize,
        ),
      ),
    );
  }
}

class _NullTableColumnWidth extends TableColumnWidth {
  const _NullTableColumnWidth();

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      throw UnimplementedError();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
