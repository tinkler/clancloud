import 'package:flutter/material.dart';

class Service {
  final String titleText;
  final String name;
  final String titleImage;
  Service(
      {required this.titleText, required this.name, required this.titleImage});
}

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  static final List<Service> _list = [
    Service(
        titleText: '吊线图',
        name: '/service/diagram',
        titleImage: 'assets/images/diagram.png')
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 30.0,
        padding: const EdgeInsets.all(10.0),
        childAspectRatio: 1.0,
        children: _list.map((Service service) {
          return _ServiceCard(
            titleText: service.titleText,
            name: service.name,
            titleImage: service.titleImage,
          );
        }).toList());
  }
}

/// service card widget
/// 卡片样式的服务图标
class _ServiceCard extends StatelessWidget {
  final String titleText;
  final String name;
  final String titleImage;
  const _ServiceCard(
      {required this.titleText, required this.name, required this.titleImage});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            alignment: Alignment.topCenter,
            child: Image.asset(
              titleImage,
              width: 50.0,
              height: 50.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              titleText,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Color(0xff333333)),
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).pushNamed(name);
      },
    );
  }
}
