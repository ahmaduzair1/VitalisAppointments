import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/reminder_service.dart';
import '../services/appointment_service.dart';
import 'home_screen.dart';
import 'my_appointments_screen.dart';
import 'alerts_screen.dart';
import 'profile_settings_screen.dart';

class MainTabNavigator extends StatefulWidget {
  final int initialIndex;
  const MainTabNavigator({super.key, this.initialIndex = 0});

  @override
  State<MainTabNavigator> createState() => _MainTabNavigatorState();
}

class _MainTabNavigatorState extends State<MainTabNavigator> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _warmup();
  }

  Future<void> _warmup() async {
    try {
      await ReminderService.instance.sync();
      await AppointmentService.instance.ensureMySlots();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screens = const [
      HomeScreen(),
      MyAppointmentsScreen(),
      AlertsScreen(),
      ProfileSettingsScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.35))),
        ),
        child: SafeArea(
          child: StreamBuilder<int>(
            stream: NotificationService.instance.unreadCount(),
            builder: (context, snapshot) {
              final unread = snapshot.data ?? 0;
              return BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    activeIcon: Icon(Icons.calendar_today_rounded),
                    label: 'Visits',
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                    activeIcon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.notifications_rounded),
                    ),
                    label: 'Alerts',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
