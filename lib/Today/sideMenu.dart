import 'package:flutter/material.dart';
import 'HomePage.dart';

class SideMenu extends StatelessWidget {
  final void Function(int)? onMenuTap;
  final int? selectedId;

  SideMenu({super.key, this.onMenuTap, this.selectedId});

  final List<MenuItemData> _menuItems = [
    MenuItemData(id: 1, icon: Icons.dashboard_outlined, title: 'Dashboard'),
    MenuItemData(id: 2, icon: Icons.auto_graph_sharp, title: 'Financial Reports'),
    MenuItemData(id: 3, icon: Icons.analytics_outlined, title: 'AI & Forecasting'),
    MenuItemData(id: 4, icon: Icons.running_with_errors_outlined, title: 'Anomaly Detection'),
    MenuItemData(id: 5, icon: Icons.attachment, title: 'Data & Integrations'),
    MenuItemData(id: 6, icon: Icons.logout_outlined, title: 'Settings & Profile'),
    MenuItemData(id: 7, icon: Icons.maps_ugc_sharp, title: 'Chitraguptha AI'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showText = screenWidth >= 600; // Hide text below 600 px

    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),  // deep navy
        Color(0xFF1E293B),
        ],// slate           ], // dark indigo theme
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),

          /// ── Logo ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/circle_logo.png',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Revenue Radar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                   //   fontFamily: 'fontoo',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ── Menu Items ──
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = selectedId == item.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Material(
                    color: isSelected
                        ? const Color(0xFF334155)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        onMenuTap?.call(item.id );
                        if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? Colors.white : Colors.white70,
                              size: 20,
                            ),
                            if (showText || screenWidth > 250)
                              ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: screenWidth < 400 ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                   //   fontFamily: 'fontoo',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ]
                            else
                              const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
