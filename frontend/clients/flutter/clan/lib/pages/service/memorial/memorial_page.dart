import 'package:Clan/api/http_config.dart';
import 'package:Clan/api/model/memorial/memorial.dart';
import 'package:Clan/pages/service/memorial/memorial_edit.dart';
import 'package:Clan/pages/service/memorial/memorial_view.dart';
import 'package:Clan/utils/toast.dart';
import 'package:flutter/material.dart';

class MemorialPage extends StatelessWidget {
  const MemorialPage({super.key});

  static const String routeName = '/service/memorial';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('纪念堂'),
        actions: [
          Builder(builder: (context) {
            return IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(MemorialEditPage.routeName,
                      arguments: Memorial());
                },
                icon: const Icon(Icons.add));
          })
        ],
      ),
      body: const _MemorialList(),
    );
  }
}

class _MemorialList extends StatefulWidget {
  const _MemorialList();
  @override
  State<_MemorialList> createState() => _MemorialListState();
}

class _MemorialListState extends State<_MemorialList> {
  final List<Memorial> _data = [];
  bool _isLoadMore = false;
  bool _isLoading = false;
  final Memorials memorialPage = Memorials();
  // The width of each memorial card

  Future<void> _handleRefresh() async {
    memorialPage.page = 1;
    await _loadData(true);
  }

  Future<void> _handleMore() async {
    if (memorialPage.total == _data.length) {
      CToast.show('已经全部了');
      return;
    }
    if (_isLoadMore) return;
    setState(() {
      _isLoadMore = true;
    });
    memorialPage.page++;
    await _loadData(false);
    setState(() {
      _isLoadMore = false;
    });
  }

  Future<void> _loadData(bool clearData) async {
    try {
      final response = await memorialPage.load();
      setState(() {
        _data.clear();
        _data.addAll(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CToast.showErr(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    memorialPage.page = 1;
    memorialPage.pageSize = 10;
    _isLoading = true;
    _loadData(false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.maxScrollExtent != 0.0 &&
              notification.metrics.maxScrollExtent ==
                  notification.metrics.pixels) {
            _handleMore();
          }
        }
        return true;
      },
      child: RefreshIndicator(
          onRefresh: _handleRefresh,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: _data.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == _data.length) {
                  return Center(
                    child: _isLoadMore
                        ? const CircularProgressIndicator()
                        : Container(),
                  );
                } else {
                  return _MemorialCard(
                    memorial: _data[index],
                  );
                }
              })),
    );
  }
}

class _MemorialCard extends StatelessWidget {
  final Memorial memorial;
  const _MemorialCard({required this.memorial});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(MemorialViewPage.routeName, arguments: memorial);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            memorial.picPath.isEmpty
                ? const Icon(
                    Icons.photo_album,
                    size: 100,
                  )
                : Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                NetworkImage(basePicUrl + memorial.picPath))),
                  ),
            Text(memorial.name)
          ],
        ),
      ),
    );
  }
}
