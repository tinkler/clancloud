import 'package:Clan/pages/service/me_page.dart';
import 'package:Clan/pages/service/service_page.dart';
import 'package:flutter/material.dart';

class HomeTabItem {
  Icon icon;
  String label;
  HomeTabItem({required this.icon, required this.label});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 0);

  int _selectedIndex = 0;
  static final List<HomeTabItem> _list = [
    HomeTabItem(icon: const Icon(Icons.home), label: '首页'),
    HomeTabItem(icon: const Icon(Icons.search), label: '服务'),
    HomeTabItem(icon: const Icon(Icons.person_rounded), label: '我的')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_list[_selectedIndex].label),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
            ),
            ServicePage(),
            MePage()
          ],
        ),
      ),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ]),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                _pageController.jumpToPage(_selectedIndex);
              });
            },
            items: _list.map((e) {
              return BottomNavigationBarItem(
                icon: e.icon,
                label: e.label,
              );
            }).toList(),
          )),
    );
  }
}
