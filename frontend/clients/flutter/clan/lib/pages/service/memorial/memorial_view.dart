import 'package:Clan/api/http_config.dart';
import 'package:Clan/api/model/memorial/memorial.dart';
import 'package:Clan/pages/service/memorial/memorial_edit.dart';
import 'package:Clan/providers/user_provider.dart';
import 'package:flutter/material.dart';

class MemorialViewPage extends StatelessWidget {
  final Memorial memorial;
  final GlobalKey<_CommemorationRecordWidgetState> _recordKey = GlobalKey();
  MemorialViewPage({super.key, required this.memorial});

  static const String routeName = '/service/memorial/view';

  Future<void> _commemorate(_CommemorateEvent event) async {
    await memorial.commemorate(Commemorate()..event = event.index);
    await _recordKey.currentState?.load();
  }

  @override
  Widget build(BuildContext context) {
    double picWidth = MediaQuery.maybeSizeOf(context)!.width / 2;
    double picHeight = picWidth / 2 * 3;
    return Scaffold(
      appBar: AppBar(
        title: Text(memorial.name),
        actions: [
          memorial.createByUserId == UserProvider.of(context).user.id
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(MemorialEditPage.routeName,
                        arguments: memorial);
                  },
                  icon: const Icon(Icons.edit))
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              memorial.picPath.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Container(
                        width: picWidth,
                        height: picHeight,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: NetworkImage(basePicUrl + memorial.picPath),
                        )),
                      ),
                    )
                  : Container(),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 10.0,
                shrinkWrap: true,
                children: [
                  _CommemorateBtn(
                    event: _CommemorateEvent.sx,
                    onCommemorate: _commemorate,
                  ),
                  _CommemorateBtn(
                    event: _CommemorateEvent.sh,
                    onCommemorate: _commemorate,
                  ),
                  _CommemorateBtn(
                    event: _CommemorateEvent.jg,
                    onCommemorate: _commemorate,
                  ),
                  _CommemorateBtn(
                    event: _CommemorateEvent.dn,
                    onCommemorate: _commemorate,
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  '祭拜记录',
                  style: Theme.of(context).primaryTextTheme.titleMedium,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              _CommemorationRecordWidget(key: _recordKey, memorial: memorial)
            ],
          ),
        ),
      ),
    );
  }
}

enum _CommemorateEvent {
  sx,
  sh,
  jg,
  dn,
}

class _CommemorateBtn extends StatefulWidget {
  final _CommemorateEvent event;
  final ValueChanged<_CommemorateEvent> onCommemorate;
  const _CommemorateBtn({required this.event, required this.onCommemorate});

  @override
  State<_CommemorateBtn> createState() => _CommemorateBtnState();
}

class _CommemorateBtnState extends State<_CommemorateBtn> {
  @override
  Widget build(BuildContext context) {
    late final Widget content;
    switch (widget.event) {
      case _CommemorateEvent.sx:
        content = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/images/sxImage.png')),
            Text('上香')
          ],
        );
        break;
      case _CommemorateEvent.sh:
        content = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/images/xhImage.png')),
            Text('送花')
          ],
        );
        break;
      case _CommemorateEvent.jg:
        content = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/images/jgImage.png')),
            Text('鞠躬')
          ],
        );
        break;
      case _CommemorateEvent.dn:
        content = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/images/zsImage.png')),
            Text('悼念')
          ],
        );
    }
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)))),
        onPressed: () {
          widget.onCommemorate(widget.event);
        },
        child: content);
  }
}

class _CommemorationRecordWidget extends StatefulWidget {
  final Memorial memorial;
  const _CommemorationRecordWidget({super.key, required this.memorial});

  @override
  State<_CommemorationRecordWidget> createState() =>
      _CommemorationRecordWidgetState();
}

class _CommemorationRecordWidgetState
    extends State<_CommemorationRecordWidget> {
  final List<Commemorate> _data = [];
  bool _loading = false;

  Future<void> load() async {
    setState(() {
      _loading = true;
    });
    _data.clear();
    _data.addAll(await widget.memorial.latestCommemorations());
    setState(() {
      _loading = false;
    });
  }

  Widget _getCommemorationWidget(int eventIndex) {
    late final String eventTitle;
    switch (_CommemorateEvent.values[eventIndex]) {
      case _CommemorateEvent.sx:
        eventTitle = '上香';
        break;
      case _CommemorateEvent.sh:
        eventTitle = '送花';
        break;
      case _CommemorateEvent.jg:
        eventTitle = '鞠躬';
        break;
      case _CommemorateEvent.dn:
        eventTitle = '悼念';
        break;
    }
    return Text(
      eventTitle,
      style: const TextStyle(color: Colors.grey),
    );
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _loading ? _data.length + 1 : _data.length,
        itemBuilder: (context, index) {
          if (index == 0 && _loading) {
            return const ListTile(
              title: Center(child: Text('刷新中...')),
            );
          }
          var dataIndex = index;
          if (_loading) {
            dataIndex--;
          }
          final commemoration = _data[dataIndex];
          return ListTile(
              title: Row(
            children: [
              Container(
                alignment: Alignment.center,
                width: 80,
                child: Text(commemoration.personName),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commemoration.createAt,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  _getCommemorationWidget(commemoration.event)
                ],
              ),
            ],
          ));
        });
  }
}
