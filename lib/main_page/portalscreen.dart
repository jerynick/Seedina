import 'package:flutter/material.dart';
import 'package:seedina/menu_page/monitoring/monitoring.dart';
import 'package:seedina/menu_page/overview/overview.dart';
import 'package:seedina/menu_page/profile/profile.dart';
import 'package:seedina/menu_page/profile/settings/esp32conn.dart';
import 'package:seedina/services/auth_service.dart';
import 'package:seedina/utils/rewidgets/global/myappbar.dart';
import 'package:seedina/utils/rewidgets/global/mynav.dart';
import 'package:seedina/utils/style/gcolor.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const OverviewScreen(),
    const MonitoringScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBar(
        title: _selectedIndex == 0
        ? Image.asset('assets/logo_app/logo_app-v2.png', height: 40)
        : (_selectedIndex == 1
          ? Text('Monitoring', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Quicksand', color: GColors.myKuning),)
          : Text('Profile', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Quicksand', color: GColors.myKuning),)
        ),
        showBackButton: false,
        actions: _selectedIndex == 2
        ? []
        : <Widget>[
          IconButton(
            icon: Icon(Icons.wifi, color: GColors.myKuning),
            onPressed: () {
              GNav.slideNavStateless(context, WiFiConn());
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_outlined, color: GColors.myKuning),
            onPressed: () {
              AuthService.signOut(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF61A3BA),
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.dashboard_sharp,
                  color: _selectedIndex == 1 ? GColors.myHijau : GColors.myKuning,
                  size: 32,
                ),
                onPressed: () => _onItemTapped(1),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.person_sharp,
                  color: _selectedIndex == 2 ? GColors.myHijau : GColors.myKuning,
                  size: 32,
                ),
                onPressed: () => _onItemTapped(2),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(0),
          backgroundColor: GColors.myBiru,
          shape: CircleBorder(),
          elevation: 6,
          child: _selectedIndex == 0
              ? Image.asset('assets/myicon/selected.png', width: 44, height: 44)
              : Image.asset('assets/myicon/unselected.png', width: 44, height: 44),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
