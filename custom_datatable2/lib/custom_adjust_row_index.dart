import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class CustomAdjustRowIndex extends StatefulWidget {
  // final List<TableRow> headerRow;
  // final List<TableColumnWidth> tableColumns;
  final List<Widget> columns;
  // final List<int> columnIndexList;
  // final VoidCallback updateTable;
  final List<int> sortedIndexList;
  final double width;
  final double height;
  final VoidCallback cancleSort;

  CustomAdjustRowIndex({
    Key? key,
    required this.columns,
    required this.sortedIndexList,
    required this.width,
    required this.height,
    required this.cancleSort,
  }) : super(key: key);

  @override
  _CustomAdjustRowIndexState createState() => _CustomAdjustRowIndexState();
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
              onTap: () {
                // print("click column ${widget.columnIndexList[index]}");
              },
              key: UniqueKey(),
            ));

    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        // Widget row = widget.columns.removeAt(oldIndex);
        int rowIndex = widget.sortedIndexList.removeAt(oldIndex);
        // widget.columns.insert(newIndex, row);
        widget.sortedIndexList.insert(newIndex<oldIndex ? newIndex:newIndex-1, rowIndex);
        // widget.updateTable();
        widget.cancleSort();

        // widget.moveHeadingIndex(oldIndex,newIndex);
      });
    }

    return 

    // SizedBox(
    //   width: widget.width,
    //   height: widget.height,
    //   child: 
    //   ReorderableListView.builder(
    //     itemBuilder: (context, index) => _columns[index],
    //     itemCount: _columns.length,
    //     onReorder: _onReorder,
    //   ),
    // );

    Container(
      width: widget.width - 37.5,
      height: widget.height,
      alignment: Alignment.centerLeft,
      child: 
      ListView.builder(
        itemBuilder: (context, index) => _columns[index],
        itemCount: _columns.length,
        // onReorder: _onReorder,
      ),
    );
  }
}
