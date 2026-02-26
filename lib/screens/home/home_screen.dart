import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_out_provider.dart';
import '../inventory/inventory_screen.dart';
import '../products/products_screen.dart';
import '../profile/profile_screen.dart';
import 'home_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().listen();
      context.read<InventoryProvider>().listen();
      context.read<StockOutProvider>().listen();
    });
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeDashboard(),
      ProductsScreen(),
      InventoryScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon:       Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label:      AppStrings.home),
          BottomNavigationBarItem(
            icon:       Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label:      AppStrings.products),
          BottomNavigationBarItem(
            icon:       Icon(Icons.warehouse_outlined),
            activeIcon: Icon(Icons.warehouse_rounded),
            label:      AppStrings.inventory),
          BottomNavigationBarItem(
            icon:       Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label:      AppStrings.profile),
        ],
      ),
    );
  }
}