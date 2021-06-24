import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_data_table.dart';
import 'custom_data_table_source.dart';
import 'custom_paginate_data_table.dart';

// import 'custom_paginated_data_table.dart';
// import 'custom_data_table_source.dart';
// import 'custom_data_table.dart';

class DemoTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DemoTableBody();
  }
}

class _DemoTableBody extends StatefulWidget {
  @override
  __DemoTableBodyState createState() => __DemoTableBodyState();
}

class __DemoTableBodyState extends State<_DemoTableBody> {
  int _rowsPerPage = 10;

  // A Variable to hold the length of table based on the condition of comparing the actual data length with the CustomDataTable.defaultRowsPerPage

  int _rowsPerPage1 = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    //Obtain the data to be displayed from the Derived DataTableSource
    final n_col = 40;
    final n_row = 1000;

    var dts = DTS(n_col: n_col, n_row: n_row);

    // dts.rowcount provides the actual data length, ForInstance, If we have 7 data stored in the DataTableSource Object, then we will get 12 as dts.rowCount

    var tableItemsCount = dts.rowCount;

    // CustomDataTable.defaultRowsPerPage provides value as 10

    var defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;

    // We are checking whether tablesItemCount is less than the defaultRowsPerPage which means we are actually checking the length of the data in DataTableSource with default CustomDataTable.defaultRowsPerPage i.e, 10

    var isRowCountLessDefaultRowsPerPage = tableItemsCount < defaultRowsPerPage;

    // Assigning rowsPerPage as 10 or acutal length of our data in stored in the DataTableSource Object

    _rowsPerPage =
        isRowCountLessDefaultRowsPerPage ? tableItemsCount : defaultRowsPerPage;
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo Custom Paginated Table"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomPaginatedDataTable(
              height: 600,
              header: Text('data with 7 rows per page'),
              // comparing the actual data length with the CustomDataTable.defaultRowsPerPage and then assigning it to _rowPerPage1 variable which then set using the setsState()
              // onRowsPerPageChanged:
              //     isRowCountLessDefaultRowsPerPage // The source of problem!
              //         ? null
              //         : (rowCount) {
              //             setState(() {
              //               _rowsPerPage1 = rowCount!;
              //             });
              //           },
              columns: List.generate(
                  n_col,
                  (index) => CustomDataColumn(
                        label: Text("head $index"),
                      )),
              getColumnsWidth: (index) => 150,
              source: dts,
              rowsPerPage: 20,
              showCheckboxColumn: true,
              showColumnNumber: 4,
              customColumnsIndex: [4, 5, 6, 7, 8, 9],
              sortColumnIndexList: List.generate(20, (index) => index * 2 + 1),
              sortAscending: true,
              onSort: (int a, int b, int column) {
                if (a % column != b % column)
                  return a % column - b % column;
                else {
                  return b - a;
                }
              },
              availableRowsPerPage: [10, 20, 50, 100, 200, 500],
            ),
          ],
        ),
      ),
    );
  }
}

class DTS extends CustomDataTableSource {
  final n_col;
  final n_row;
  DTS({
    required this.n_col,
    required this.n_row,
  });

  @override
  CustomDataRow getRow(int index) {
    ValueNotifier<bool> selected = ValueNotifier<bool>(false);

    return CustomDataRow.byIndex(
      selected: selected,
      index: index,
      cells: List.generate(
        n_col,
        (columnIndex) => CustomDataCell(Text("col$columnIndex : row$index")),
      ),
      onSelectChanged: (bool) {
        selected.value = !selected.value;
        print(selected.value);
      },
    );
  }

  @override
  int get rowCount => n_row; // Manipulate this to which ever value you wish

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
