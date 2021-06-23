import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class CustomAdjustHeaderIndex extends StatefulWidget {
  // final List<TableRow> headerRow;
  // final List<TableColumnWidth> tableColumns;
  final List<Widget> columns;
  // final List<int> columnIndexList;
  // final VoidCallback updateTable;
  final Function(int,int) moveHeadingIndex;
  final Function(bool) onRowHover;
  final Function(int)? sort;
  final List<int>? sortColumnIndexList;
  final List<int>? columnIndexlist;
  final Function(int)? onSortIndex;

  CustomAdjustHeaderIndex({
    Key? key,
    required this.columns,
    required this.moveHeadingIndex,
    required this.onRowHover,
    this.sort,
    this.sortColumnIndexList,
    this.columnIndexlist,
    this.onSortIndex,
  }) : super(key: key);

  @override
  _CustomAdjustHeaderIndexState createState() =>
      _CustomAdjustHeaderIndexState();
}

class _CustomAdjustHeaderIndexState extends State<CustomAdjustHeaderIndex> {
  // late List<Widget> _columns;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _columns = List.generate(
        widget.columns.length,(index){
          bool sortable;
          if (widget.sortColumnIndexList != null && widget.columnIndexlist != null && widget.onSortIndex != null){
            sortable = widget.sortColumnIndexList!.contains(widget.columnIndexlist![index]);
          }
          else{
            sortable = false;
          }
          return InkWell(
              child: widget.columns[index],
              onTap: (){
                if(sortable){
                  widget.onSortIndex!(widget.columnIndexlist![index]);
                  // print(index);
                }
              },
              onHover: widget.onRowHover,
              hoverColor: sortable ? Colors.black26 : null,
              key: UniqueKey(),
            );
        });


    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        // Widget col = widget.columns.removeAt(oldIndex);
        // int colIndex = widget.columnIndexList.removeAt(oldIndex);
        // widget.columns.insert(newIndex, col);
        // widget.columnIndexList.insert(newIndex, colIndex);
        // widget.updateTable();

        widget.moveHeadingIndex(oldIndex,newIndex);
      });
    }

    return ReorderableRow(
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
