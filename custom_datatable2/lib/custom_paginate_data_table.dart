// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:custom_datatable/base_scrollbar.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'custom_data_table.dart';
import 'custom_data_table_source.dart';

// import 'button_bar.dart';
// import 'card.dart';
// import 'constants.dart';
// import 'data_table.dart';
// import 'data_table_source.dart';
// import 'debug.dart';
// import 'dropdown.dart';
// import 'icon_button.dart';
// import 'icons.dart';
// import 'ink_decoration.dart';
// import 'material_localizations.dart';
// import 'progress_indicator.dart';
// import 'theme.dart';

/// A material design data table that shows data using multiple pages.
///
/// A paginated data table shows [rowsPerPage] rows of data per page and
/// provides controls for showing other pages.
///
/// Data is read lazily from from a [DataTableSource]. The widget is presented
/// as a [Card].
///
/// See also:
///
///  * [DataTable], which is not paginated.
///  * <https://material.io/go/design-data-tables#data-tables-tables-within-cards>
class CustomPaginatedDataTable extends StatefulWidget {
  /// Creates a widget describing a paginated [DataTable] on a [Card].
  ///
  /// The [header] should give the card's header, typically a [Text] widget.
  ///
  /// The [columns] argument must be a list of as many [DataColumn] objects as
  /// the table is to have columns, ignoring the leading checkbox column if any.
  /// The [columns] argument must have a length greater than zero and cannot be
  /// null.
  ///
  /// If the table is sorted, the column that provides the current primary key
  /// should be specified by index in [sortColumnIndex], 0 meaning the first
  /// column in [columns], 1 being the next one, and so forth.
  ///
  /// The actual sort order can be specified using [sortAscending]; if the sort
  /// order is ascending, this should be true (the default), otherwise it should
  /// be false.
  ///
  /// The [source] must not be null. The [source] should be a long-lived
  /// [DataTableSource]. The same source should be provided each time a
  /// particular [PaginatedDataTable] widget is created; avoid creating a new
  /// [DataTableSource] with each new instance of the [PaginatedDataTable]
  /// widget unless the data table really is to now show entirely different
  /// data from a new source.
  ///
  /// The [rowsPerPage] and [availableRowsPerPage] must not be null (they
  /// both have defaults, though, so don't have to be specified).
  ///
  /// Themed by [DataTableTheme]. [DataTableThemeData.decoration] is ignored.
  /// To modify the border or background color of the [PaginatedDataTable], use
  /// [CardTheme], since a [Card] wraps the inner [DataTable].
  ///
  List<int>? customColumnsIndex;
  final List<int>? sortedIndexList;
  List<int> allSortedIndexList = <int>[];
  int Function(int a, int b, int column) onSort;
  int showColumnNumber;
  double Function(int index) getColumnsWidth;
  String? addColumnTooltip;
  final double height;

  ///
  CustomPaginatedDataTable({
    Key? key,
    this.customColumnsIndex,
    this.sortedIndexList,
    required this.onSort,
    required this.getColumnsWidth,
    required this.height,
    this.addColumnTooltip,
    this.showColumnNumber = 1,
    this.header,
    this.actions,
    required this.columns,
    this.sortColumnIndex,
    this.sortColumnIndexList,
    this.sortAscending = true,
    this.onSelectAll,
    this.dataRowHeight = kMinInteractiveDimension,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = false,
    this.initialFirstRowIndex = 0,
    this.onPageChanged,
    this.rowsPerPage = defaultRowsPerPage,
    this.availableRowsPerPage = const <int>[],
    // this.onRowsPerPageChanged,
    required this.source,
    this.dragStartBehavior = DragStartBehavior.start,
    this.checkboxHorizontalMargin,
  })  : assert(actions == null || (actions != null && header != null)),
        assert(columns != null),
        assert(dragStartBehavior != null),
        assert(columns.isNotEmpty),
        assert(sortColumnIndex == null ||
            (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
        assert(sortAscending != null),
        assert(dataRowHeight != null),
        assert(headingRowHeight != null),
        assert(horizontalMargin != null),
        assert(columnSpacing != null),
        assert(showCheckboxColumn != null),
        assert(showFirstLastButtons != null),
        assert(rowsPerPage != null),
        assert(rowsPerPage > 0),
        //  assert(() {
        //    if (onRowsPerPageChanged != null)
        //      assert(availableRowsPerPage != null && availableRowsPerPage.contains(rowsPerPage));
        //    return true;
        //  }()),
        assert(source != null),
        super(key: key);

  /// The table card's optional header.
  ///
  /// This is typically a [Text] widget, but can also be a [Row] of
  /// [TextButton]s. To show icon buttons at the top end side of the table with
  /// a header, set the [actions] property.
  ///
  /// If items in the table are selectable, then, when the selection is not
  /// empty, the header is replaced by a count of the selected items. The
  /// [actions] are still visible when items are selected.
  final Widget? header;

  /// Icon buttons to show at the top end side of the table. The [header] must
  /// not be null to show the actions.
  ///
  /// Typically, the exact actions included in this list will vary based on
  /// whether any rows are selected or not.
  ///
  /// These should be size 24.0 with default padding (8.0).
  final List<Widget>? actions;

  /// The configuration and labels for the columns in the table.
  final List<CustomDataColumn> columns;

  /// The current primary sort key's column.
  ///
  /// See [DataTable.sortColumnIndex].
  final int? sortColumnIndex;
  final List<int>? sortColumnIndexList;

  /// Whether the column mentioned in [sortColumnIndex], if any, is sorted
  /// in ascending order.
  ///
  /// See [DataTable.sortAscending].
  final bool sortAscending;

  /// Invoked when the user selects or unselects every row, using the
  /// checkbox in the heading row.
  ///
  /// See [DataTable.onSelectAll].
  final ValueSetter<bool?>? onSelectAll;

  /// The height of each row (excluding the row that contains column headings).
  ///
  /// This value is optional and defaults to kMinInteractiveDimension if not
  /// specified.
  final double dataRowHeight;

  /// The height of the heading row.
  ///
  /// This value is optional and defaults to 56.0 if not specified.
  final double headingRowHeight;

  /// The horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  ///
  /// When a checkbox is displayed, it is also the margin between the checkbox
  /// the content in the first data column.
  ///
  /// This value defaults to 24.0 to adhere to the Material Design specifications.
  ///
  /// If [checkboxHorizontalMargin] is null, then [horizontalMargin] is also the
  /// margin between the edge of the table and the checkbox, as well as the
  /// margin between the checkbox and the content in the first data column.
  final double horizontalMargin;

  /// The horizontal margin between the contents of each data column.
  ///
  /// This value defaults to 56.0 to adhere to the Material Design specifications.
  final double columnSpacing;

  /// {@macro flutter.material.dataTable.showCheckboxColumn}
  final bool showCheckboxColumn;

  /// Flag to display the pagination buttons to go to the first and last pages.
  final bool showFirstLastButtons;

  /// The index of the first row to display when the widget is first created.
  final int? initialFirstRowIndex;

  /// Invoked when the user switches to another page.
  ///
  /// The value is the index of the first row on the currently displayed page.
  final ValueChanged<int>? onPageChanged;

  /// The number of rows to show on each page.
  ///
  /// See also:
  ///
  ///  * [onRowsPerPageChanged]
  ///  * [defaultRowsPerPage]
  int rowsPerPage;

  /// The default value for [rowsPerPage].
  ///
  /// Useful when initializing the field that will hold the current
  /// [rowsPerPage], when implemented [onRowsPerPageChanged].
  static const int defaultRowsPerPage = 10;

  /// The options to offer for the rowsPerPage.
  ///
  /// The current [rowsPerPage] must be a value in this list.
  ///
  /// The values in this list should be sorted in ascending order.
  final List<int> availableRowsPerPage;

  /// Invoked when the user selects a different number of rows per page.
  ///
  /// If this is null, then the value given by [rowsPerPage] will be used
  /// and no affordance will be provided to change the value.
  // final ValueChanged<int?>? onRowsPerPageChanged;

  /// The data source which provides data to show in each row. Must be non-null.
  ///
  /// This object should generally have a lifetime longer than the
  /// [PaginatedDataTable] widget itself; it should be reused each time the
  /// [PaginatedDataTable] constructor is called.
  final CustomDataTableSource source;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// Horizontal margin around the checkbox, if it is displayed.
  ///
  /// If null, then [horizontalMargin] is used as the margin between the edge
  /// of the table and the checkbox, as well as the margin between the checkbox
  /// and the content in the first data column. This value defaults to 24.0.
  final double? checkboxHorizontalMargin;

  @override
  CustomPaginatedDataTableState createState() =>
      CustomPaginatedDataTableState();
}

/// Holds the state of a [PaginatedDataTable].
///
/// The table can be programmatically paged using the [pageTo] method.
class CustomPaginatedDataTableState extends State<CustomPaginatedDataTable> {
  late int _firstRowIndex;
  late int _rowCount;
  late bool _rowCountApproximate;
  int _selectedRowCount = 0;
  final Map<int, CustomDataRow?> _rows = <int, CustomDataRow?>{};

  int? sortedColumnIndex;
  bool isSortup = true;

  late SyncScrollController _syncScroller;

  final ScrollController _fistScrollController = ScrollController();
  final ScrollController _secondScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _firstRowIndex = PageStorage.of(context)?.readState(context) as int? ??
        widget.initialFirstRowIndex ??
        0;
    widget.source.addListener(_handleDataSourceChanged);
    _handleDataSourceChanged();

    _syncScroller =
        SyncScrollController([_fistScrollController, _secondScrollController]);
  }

  @override
  void onRowsPerPageChanged(int? rowNumber) {
    print(rowNumber);
    if (rowNumber != null) {
      widget.rowsPerPage = rowNumber;
      setState(() {
        
      });
    }
  }

  void setShowColumnNumber(int showColumnNumber){
    widget.showColumnNumber = showColumnNumber;
  }

  void didUpdateWidget(CustomPaginatedDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      oldWidget.source.removeListener(_handleDataSourceChanged);
      widget.source.addListener(_handleDataSourceChanged);
      _handleDataSourceChanged();
    }
  }

  @override
  void dispose() {
    widget.source.removeListener(_handleDataSourceChanged);
    super.dispose();
  }

  void _handleDataSourceChanged() {
    setState(() {
      _rowCount = widget.source.rowCount;
      _rowCountApproximate = widget.source.isRowCountApproximate;
      _selectedRowCount = widget.source.selectedRowCount;
      _rows.clear();
    });
  }

  /// Ensures that the given row is visible.
  void pageTo(int rowIndex) {
    final int oldFirstRowIndex = _firstRowIndex;
    setState(() {
      final int rowsPerPage = widget.rowsPerPage;
      _firstRowIndex = (rowIndex ~/ rowsPerPage) * rowsPerPage;
    });
    if ((widget.onPageChanged != null) && (oldFirstRowIndex != _firstRowIndex))
      widget.onPageChanged!(_firstRowIndex);
  }

  CustomDataRow _getBlankRowFor(int index) {
    return CustomDataRow.byIndex(
      selected: ValueNotifier<bool>(false),
      index: index,
      cells: widget.columns
          .map<CustomDataCell>(
              (CustomDataColumn column) => CustomDataCell.empty)
          .toList(),
    );
  }

  CustomDataRow _getProgressIndicatorRowFor(int index) {
    bool haveProgressIndicator = false;
    final List<CustomDataCell> cells =
        widget.columns.map<CustomDataCell>((CustomDataColumn column) {
      if (!column.numeric) {
        haveProgressIndicator = true;
        return const CustomDataCell(CircularProgressIndicator());
      }
      return CustomDataCell.empty;
    }).toList();
    if (!haveProgressIndicator) {
      haveProgressIndicator = true;
      cells[0] = const CustomDataCell(CircularProgressIndicator());
    }
    return CustomDataRow.byIndex(
      selected: ValueNotifier<bool>(false),
      index: index,
      cells: cells,
    );
  }

  List<CustomDataRow> _getRows(int firstRowIndex, int rowsPerPage) {
    final List<CustomDataRow> result = <CustomDataRow>[];
    final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;
    bool haveProgressIndicator = false;
    for (int index = firstRowIndex; index < nextPageFirstRowIndex; index += 1) {
      CustomDataRow? row;
      if (index < _rowCount || _rowCountApproximate) {
        row = _rows.putIfAbsent(widget.allSortedIndexList[index],
            () => widget.source.getRow(widget.allSortedIndexList[index]));
        if (row == null && !haveProgressIndicator) {
          row ??= _getProgressIndicatorRowFor(index);
          haveProgressIndicator = true;
        }
      }
      row ??= _getBlankRowFor(index);
      result.add(row);
    }
    // print(widget.allSortedIndexList);

    return result;
  }

  void _handleSort(int column, int showColumnNumber) {
    isSortup = sortedColumnIndex != column || !isSortup;

    sortedColumnIndex = column;

    setState(() {
      if (isSortup) {
        widget.allSortedIndexList.sort((a, b) => widget.onSort(a, b, column));
      } else {
        widget.allSortedIndexList = widget.allSortedIndexList.reversed.toList();
      }
      widget.showColumnNumber = showColumnNumber;
    });
  }

  void _handleFirst() {
    pageTo(0);
  }

  void _handlePrevious() {
    pageTo(math.max(_firstRowIndex - widget.rowsPerPage, 0));
  }

  void _handleNext() {
    pageTo(_firstRowIndex + widget.rowsPerPage);
  }

  void _handleLast() {
    pageTo(((_rowCount - 1) / widget.rowsPerPage).floor() * widget.rowsPerPage);
  }

  bool _isNextPageUnavailable() =>
      !_rowCountApproximate &&
      (_firstRowIndex + widget.rowsPerPage >= _rowCount);

  final GlobalKey _tableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.customColumnsIndex == null) {
      widget.customColumnsIndex =
          List.generate(widget.columns.length, (index) => index);
    }

    if (widget.customColumnsIndex!.length < widget.columns.length) {
      for (int i = 0; i < widget.columns.length; i++) {
        if (!widget.customColumnsIndex!.contains(i)) {
          widget.customColumnsIndex!.add(i);
        }
      }
    }
    if (widget.allSortedIndexList.isEmpty) {
      widget.allSortedIndexList =
          List.generate(widget.source.rowCount, (index) => index);
    }
    // TODO(ianh): This whole build function doesn't handle RTL yet.
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    // HEADER
    final List<Widget> headerWidgets = <Widget>[];
    double startPadding = 24.0;
    if (_selectedRowCount == 0 && widget.header != null) {
      headerWidgets.add(Expanded(child: widget.header!));
      if (widget.header is ButtonBar) {
        // We adjust the padding when a button bar is present, because the
        // ButtonBar introduces 2 pixels of outside padding, plus 2 pixels
        // around each button on each side, and the button itself will have 8
        // pixels internally on each side, yet we want the left edge of the
        // inside of the button to line up with the 24.0 left inset.
        startPadding = 12.0;
      }
    } else if (widget.header != null) {
      headerWidgets.add(Expanded(
        child: Text(localizations.selectedRowCountTitle(_selectedRowCount)),
      ));
    }
    if (widget.actions != null) {
      headerWidgets.addAll(
        widget.actions!.map<Widget>((Widget action) {
          return Padding(
            // 8.0 is the default padding of an icon button
            padding: const EdgeInsetsDirectional.only(start: 24.0 - 8.0 * 2.0),
            child: action,
          );
        }).toList(),
      );
    }

    // FOOTER
    final TextStyle? footerTextStyle = themeData.textTheme.caption;
    final List<Widget> footerWidgets = <Widget>[];
    if (widget.availableRowsPerPage.isNotEmpty) {
      final List<Widget> availableRowsPerPage = widget.availableRowsPerPage
          .where(
              (int value) => value <= _rowCount || value == widget.rowsPerPage)
          .map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value'),
        );
      }).toList();
      footerWidgets.addAll(<Widget>[
        Container(
            width:
                14.0), // to match trailing padding in case we overflow and end up scrolling
        Text(localizations.rowsPerPageTitle),
        ConstrainedBox(
          constraints: const BoxConstraints(
              minWidth: 64.0), // 40.0 for the text, 24.0 for the icon
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                items: availableRowsPerPage.cast<DropdownMenuItem<int>>(),
                value: widget.rowsPerPage,
                onChanged: onRowsPerPageChanged,
                style: footerTextStyle,
                iconSize: 24.0,
              ),
            ),
          ),
        ),
      ]);
    }
    footerWidgets.addAll(<Widget>[
      Container(width: 32.0),
      Text(
        localizations.pageRowsInfoTitle(
          _firstRowIndex + 1,
          _firstRowIndex + widget.rowsPerPage,
          _rowCount,
          _rowCountApproximate,
        ),
      ),
      Container(width: 32.0),
      if (widget.showFirstLastButtons)
        IconButton(
          icon: const Icon(Icons.skip_previous),
          padding: EdgeInsets.zero,
          tooltip: localizations.firstPageTooltip,
          onPressed: _firstRowIndex <= 0 ? null : _handleFirst,
        ),
      IconButton(
        icon: const Icon(Icons.chevron_left),
        padding: EdgeInsets.zero,
        tooltip: localizations.previousPageTooltip,
        onPressed: _firstRowIndex <= 0 ? null : _handlePrevious,
      ),
      Container(width: 24.0),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        padding: EdgeInsets.zero,
        tooltip: localizations.nextPageTooltip,
        onPressed: _isNextPageUnavailable() ? null : _handleNext,
      ),
      if (widget.showFirstLastButtons)
        IconButton(
          icon: const Icon(Icons.skip_next),
          padding: EdgeInsets.zero,
          tooltip: localizations.lastPageTooltip,
          onPressed: _isNextPageUnavailable() ? null : _handleLast,
        ),
      Container(width: 14.0),
    ]);

    // CARD
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Card(
          semanticContainer: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    // int index = widget.allSortedIndexList.removeAt(14);
                    // widget.allSortedIndexList.insert(0, index);
                    // print(widget.allSortedIndexList);
                    // setState(() {
                    // widget.allSortedIndexList = widget.allSortedIndexList.reversed.toList();
                    // });
                    _handleSort(2, 7);
                  },
                  child: Text("sort column 2")),
              if (headerWidgets.isNotEmpty)
                Semantics(
                  container: true,
                  child: DefaultTextStyle(
                    // These typographic styles aren't quite the regular ones. We pick the closest ones from the regular
                    // list and then tweak them appropriately.
                    // See https://material.io/design/components/data-tables.html#tables-within-cards
                    style: _selectedRowCount > 0
                        ? themeData.textTheme.subtitle1!
                            .copyWith(color: themeData.colorScheme.secondary)
                        : themeData.textTheme.headline6!
                            .copyWith(fontWeight: FontWeight.w400),
                    child: IconTheme.merge(
                      data: const IconThemeData(
                        opacity: 0.54,
                      ),
                      child: Ink(
                        height: 64.0,
                        color: _selectedRowCount > 0
                            ? themeData.secondaryHeaderColor
                            : null,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                              start: startPadding, end: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: headerWidgets,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.minWidth),
                child: CustomDataTable(
                  key: _tableKey,
                  customColumnsIndex: widget.customColumnsIndex!,
                  sortedIndexList: widget.sortedIndexList ??
                      List.generate(widget.rowsPerPage, (index) => index),
                  columns: widget.columns,
                  sortColumnIndex: sortedColumnIndex, //widget.sortColumnIndex,
                  sortColumnIndexList: widget.sortColumnIndexList,
                  sortAscending: isSortup, //widget.sortAscending,
                  onSelectAll: widget.onSelectAll,
                  onSortColumn: _handleSort,
                  showColumnNumber: widget.showColumnNumber,
                  getColumnsWidth: widget.getColumnsWidth,
                  addColumnTooltip: widget.addColumnTooltip,
                  height: widget.height,
                  setshowColumnNumber: setShowColumnNumber,
                  // Make sure no decoration is set on the DataTable
                  // from the theme, as its already wrapped in a Card.
                  decoration: const BoxDecoration(),
                  dataRowHeight: widget.dataRowHeight,
                  headingRowHeight: widget.headingRowHeight,
                  horizontalMargin: widget.horizontalMargin,
                  checkboxHorizontalMargin: widget.checkboxHorizontalMargin,
                  columnSpacing: widget.columnSpacing,
                  showCheckboxColumn: widget.showCheckboxColumn,
                  showBottomBorder: true,
                  rows: _getRows(_firstRowIndex, widget.rowsPerPage),
                ),
              ),
              DefaultTextStyle(
                style: footerTextStyle!,
                child: IconTheme.merge(
                  data: const IconThemeData(
                    opacity: 0.54,
                  ),
                  child: SizedBox(
                    // TODO(bkonyi): this won't handle text zoom correctly,
                    //  https://github.com/flutter/flutter/issues/48522
                    height: 56.0,
                    child: SingleChildScrollView(
                      dragStartBehavior: widget.dragStartBehavior,
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        children: footerWidgets,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SyncScrollController {
  final List<ScrollController> _registeredScrollControllers = [];

  ScrollController? _scrollingController;
  bool _scrollingActive = false;

  SyncScrollController(List<ScrollController> controllers) {
    controllers.forEach((controller) => registerScrollController(controller));
  }

  void registerScrollController(ScrollController controller) {
    _registeredScrollControllers.add(controller);
  }

  void processNotification(
      ScrollNotification notification, ScrollController sender) {
    if (notification is ScrollStartNotification && !_scrollingActive) {
      _scrollingController = sender;
      _scrollingActive = true;
      return;
    }

    if (identical(sender, _scrollingController) && _scrollingActive) {
      if (notification is ScrollEndNotification) {
        _scrollingController = null;
        _scrollingActive = false;
        return;
      }

      if (notification is ScrollUpdateNotification) {
        _registeredScrollControllers.forEach((controller) => {
              if (!identical(_scrollingController, controller))
                {
                  if (_scrollingController != null)
                    {controller..jumpTo(_scrollingController!.offset)}
                }
            });
        return;
      }
    }
  }
}
