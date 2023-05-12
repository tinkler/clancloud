import 'dart:async';

import 'package:Clan/api/clans/model/clan.dart';
import 'package:Clan/api/http_config.dart';
import 'package:flutter/material.dart';

typedef TapClan = FutureOr<int?> Function(Member m);

class ClanTree extends StatefulWidget {
  final Member member;
  final int maxStatus;
  final double width;
  final double height;
  final TapClan onTap;
  final int chasedId;

  const ClanTree(this.member,
      {super.key,
      required this.onTap,
      this.maxStatus = -1,
      this.width = 80.0,
      this.height = 20,
      this.chasedId = 0});

  @override
  State<ClanTree> createState() => _ClanTreeState();
}

class _ClanTreeState extends State<ClanTree> {
  late int _chasedId;

  @override
  void initState() {
    super.initState();
    _chasedId = widget.chasedId;
  }

  Widget _buildChildMiddleItem(Member member) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomPaint(
            size: Size(widget.width - 20.0, 20.0),
            painter: TreeLinePainter(TreeLineType.middle, widget.width, 20.0),
          ),
          _buildBaseItem(member)
        ],
      ),
    );
  }

  Widget _buildChildFirstItem(Member member) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomPaint(
            size: Size(widget.width - 20, 20.0),
            painter: TreeLinePainter(TreeLineType.first, widget.width, 20.0),
          ),
          _buildBaseItem(member)
        ],
      ),
    );
  }

  Widget _buildChildLastItem(Member member) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomPaint(
            size: Size(widget.width - 20, 20.0),
            painter: TreeLinePainter(TreeLineType.last, widget.width, 20.0),
          ),
          _buildBaseItem(member)
        ],
      ),
    );
  }

  Widget _buildChildOnlyItem(Member member) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomPaint(
            size: Size(widget.width - 20, 20.0),
            painter:
                TreeLinePainter(TreeLineType.only, widget.width - 10, 20.0),
          ),
          _buildBaseItem(member)
        ],
      ),
    );
  }

  Widget _buildTopItem(Member member) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: widget.width - 20.0,
            height: 20.0,
          ),
          _buildBaseItem(member),
        ],
      ),
    );
  }

  Widget _buildEmptyItem() {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomPaint(
            size: Size(widget.width - 20, 20.0),
            painter: TreeLinePainter(TreeLineType.empty, widget.width, 20.0),
          ),
          _buildBaseItem(null),
        ],
      ),
    );
  }

  Widget _buildPlaceholderMiddleItem() {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: widget.width - 20.0,
            height: 20.0,
          ),
          _buildBaseItem(null),
        ],
      ),
    );
  }

  Widget _buildPlaceholderLastItem() {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: widget.width - 20.0,
            height: 20.0,
          ),
          _buildBaseItem(null),
        ],
      ),
    );
  }

  Widget _buildBaseItem(Member? m) {
    if (m != null) {
      return GestureDetector(
        child: Card(
          margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.brown[700],
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                width: 1,
                color: m.id == _chasedId ? Colors.red : Colors.brown,
              ),
            ),
            width: widget.width - 20,
            height: (widget.width - 20) / 2 * 3,
            child: Column(
              children: <Widget>[
                // 头像
                Container(
                  color: Colors.white,
                  child: Container(
                    height: widget.width / 1.2,
                    width: widget.width / 1.2,
                    color: m.sex == 2
                        ? const Color(0xffFF9966)
                        : const Color(0xff6699CC),
                    child: m.profilePicture != ''
                        ? Image.network(basePicUrl + m.profilePicture,
                            fit: BoxFit.cover)
                        : Icon(
                            Icons.account_circle,
                            size: widget.width / 1.6,
                            color: Colors.white,
                          ),
                  ),
                ),
                Text(
                  m.name,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                )
              ],
            ),
          ),
        ),
        onTap: () {
          () async {
            var id = await widget.onTap(m);

            if (id != null && id != 0) {
              setState(() {
                _chasedId = id;
              });
            }
          }();
        },
      );
    } else {
      return Container(
        margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
        width: widget.width - 20,
        height: (widget.width - 20) / 2 * 3,
      );
    }
  }

  // range 同辈排名
  int _makeTree(List<Row> rows, List<_TreeState> states, int status,
      int maxStatus, Member main, Position position,
      {range = 1}) {
    int currentStatus = status;
    Position currentPosition = position;
    if (rows.length == status - 1) {
      rows.add(Row(
        children: [],
      ));
      states.add(_TreeState());
    }

    if (currentPosition == Position.top) {
      if (main.father != null) {
        if (main.father!.name != '') {
          var fs = _makeTree(
              rows, states, currentStatus, 1, main.father!, Position.top);
          currentStatus = fs + 1;
          rows.add(Row(
            children: <Widget>[],
          ));
          states.add(_TreeState());
          currentPosition = Position.only;
          // if (main.father.father != null) {

          // } else {
          //   rows[currentStatus - 1].children.add(_buildTopItem(main.father));
          //   return currentStatus;
          // }
        }
      }
    }

    switch (currentPosition) {
      case Position.first:
        rows[currentStatus - 1].children.add(_buildChildFirstItem(main));
        break;
      case Position.only:
        rows[currentStatus - 1].children.add(_buildChildOnlyItem(main));
        break;
      case Position.last:
        rows[currentStatus - 1].children.add(_buildChildLastItem(main));
        break;
      case Position.top:
        rows[currentStatus - 1].children.add(_buildTopItem(main));
        break;
      case Position.middle:
        rows[currentStatus - 1].children.add(_buildChildMiddleItem(main));
        break;
    }

    if (main.children.isNotEmpty) {
      int clen = main.children.length;
      if (clen == 1) {
        states[currentStatus - 1].hasSisterOrBrother = false;
        currentStatus = _makeTree(rows, states, currentStatus + 1, maxStatus,
            main.children[0], Position.only);
      } else {
        var currentChildStatus = currentStatus + 1;
        for (int i = 0; i < clen - 1; i++) {
          for (int j = currentStatus; j > 1; j--) {
            //判断父亲是否有
            if (states[j - 2].hasSisterOrBrother) {
              rows[j - 1].children.add(_buildEmptyItem());
            } else {
              rows[j - 1].children.add(_buildPlaceholderLastItem());
            }
          }
        }
        for (int i = currentChildStatus; i <= maxStatus; i++) {
          if (rows.length == i - 1) {
            rows.add(Row(
              children: <Widget>[],
            ));
            states.add(_TreeState());
          }
          for (int j = rows[i - 1].children.length + 1; j < range; j++) {
            rows[i - 1].children.add(_buildPlaceholderMiddleItem());
          }
        }
        for (int i = 0; i < clen; i++) {
          Position cp = Position.first;
          var cs = 0;
          if (i == clen - 1) {
            cp = Position.last;
            states[currentChildStatus - 2].hasSisterOrBrother = false;
            cs = _makeTree(rows, states, currentChildStatus, maxStatus,
                main.children[i], cp);
            // rows[currentStatus - 1].children.add(_buildPlaceholderLastItem());
          } else if (i != 0) {
            cp = Position.middle;
            states[currentChildStatus - 2].hasSisterOrBrother = true;
            cs = _makeTree(
              rows,
              states,
              currentChildStatus,
              maxStatus,
              main.children[i],
              cp,
              range: i + 1,
            );
            // rows[currentStatus - 1].children.add(_buildPlaceholderMiddleItem());
          } else {
            states[currentChildStatus - 2].hasSisterOrBrother = true;
            cs = _makeTree(rows, states, currentChildStatus, maxStatus,
                main.children[i], cp,
                range: i + 1);
          }
          if (currentStatus < cs) {
            currentStatus = cs;
          }
        }
        states[currentChildStatus - 2].hasSisterOrBrother = false;
      }
    } else {
      for (var i = currentStatus + 1; i <= maxStatus; i++) {
        if (rows.length <= i - 1) {
          print('out of index');
        } else {
          rows[i - 1].children.add(_buildPlaceholderMiddleItem());
        }
      }
    }

    return currentStatus;
  }

  int _calStatus(Member m) {
    var fdep = 0;
    if (m.father != null) {
      fdep = _calStatus(m.father!) + 1;
      var cdep = 0;
      if (m.children.isNotEmpty) {
        int status = 1;
        for (var c in m.children) {
          var last = _calStatus(c);
          if (status < last) {
            status = last;
          }
        }
        cdep = status + 1;
      }
      return fdep + cdep;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    List<Row> rows = [];
    if (widget.maxStatus > 0) {
      _makeTree(rows, [], 1, widget.maxStatus, widget.member, Position.top);
    } else {
      int maxStatus = _calStatus(widget.member);
      _makeTree(rows, [], 1, maxStatus, widget.member, Position.top);
    }

    Column col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [col],
    );
  }
}

enum TreeLineType { first, middle, last, empty, only }

class TreeLinePainter extends CustomPainter {
  final TreeLineType type;
  final double width;
  final double height;
  final double paddingLeft;
  final Color lineColor;
  final double strokeWidth;

  TreeLinePainter(this.type, this.width, this.height,
      {this.paddingLeft = 0.0,
      this.lineColor = Colors.red,
      this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeWidth = strokeWidth;
    switch (type) {
      case TreeLineType.middle:
        {
          canvas.drawLine(Offset(paddingLeft, height / 2),
              Offset(width, height / 2), paint);
          canvas.drawLine(
              Offset(width / 2, height / 2), Offset(width / 2, height), paint);
        }
        break;
      case TreeLineType.first:
        {
          canvas.drawLine(Offset(paddingLeft + width / 2, height / 2),
              Offset(width, height / 2), paint);
          canvas.drawLine(Offset(paddingLeft + width / 2, 0),
              Offset(paddingLeft + width / 2, height), paint);
        }
        break;
      case TreeLineType.empty:
        {
          canvas.drawLine(Offset(paddingLeft, height / 2),
              Offset(width, height / 2), paint);
        }
        break;
      case TreeLineType.last:
        {
          Path path = Path()
            ..moveTo(paddingLeft, height / 2)
            ..lineTo(width / 2, height / 2)
            ..lineTo(width / 2, height);
          canvas.drawPath(path, paint);
        }
        break;
      case TreeLineType.only:
        {
          canvas.drawLine(Offset(paddingLeft + width / 2, 0),
              Offset(paddingLeft + width / 2, height), paint);
        }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _TreeState {
  bool hasSisterOrBrother;
  _TreeState({this.hasSisterOrBrother = false});
}

enum Position {
  first,
  middle,
  last,
  only,
  top,
}
