import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class CustomAdjustRowIndex extends StatefulWidget {
  // final List<TableRow> headerRow;
  // final List<TableColumnWidth> tableColumns;
  final List<Widget> columns;
  // final List<int> columnIndexList;
  // final VoidCallback updateTable;
  final List<int> sortedIndexList;

  CustomAdjustRowIndex({
    Key? key,
    required this.columns,
    required this.sortedIndexList,
  }) : super(key: key);

  @override
  _CustomAdjustRowIndexState createState() =>
      _CustomAdjustRowIndexState();
}

class _CustomAdjustRowIndexState extends State<CustomAdjustRowIndex> {
  // late List<Widget> _columns;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _columns = List.generate(
        widget.columns.length,
        (index) => InkWell(
              child: widget.columns[widget.sortedIndexList[index]],
              onTap: (){
                // print("click column ${widget.columnIndexList[index]}");
              },
              key: UniqueKey(),
            ));

    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        // Widget row = widget.columns.removeAt(oldIndex);
        int rowIndex = widget.sortedIndexList.removeAt(oldIndex);
        // widget.columns.insert(newIndex, row);
        widget.sortedIndexList.insert(newIndex, rowIndex);
        // widget.updateTable();

        // widget.moveHeadingIndex(oldIndex,newIndex);
      });
    }

    return ReorderableColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _columns,
      onReorder: _onReorder,
      onNoReorder: (int index) {
        //this callback is optional
        // debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
        // print(index);
      },
    );
  }
}
