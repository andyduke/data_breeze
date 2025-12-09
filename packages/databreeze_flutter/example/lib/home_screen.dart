import 'package:databreeze_flutter_example/demo/fetch/fetch_demo_screen.dart';
import 'package:databreeze_flutter_example/demo/kvm/kvm_demo_screen.dart';
import 'package:databreeze_flutter_example/demo/list_n_agg/list_n_agg_screen.dart';
import 'package:databreeze_flutter_example/demo/sqlite/sqlite_demo_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int pageIndex = 0;
  final controller = PageController();

  final pages = <({IconData icon, String title, Widget body})>[
    (icon: Icons.sim_card_download_outlined, title: 'Fetch', body: FetchDemoScreen()),
    (icon: Icons.local_offer_rounded, title: 'KVM', body: KvmDemoScreen()),
    (icon: Icons.storage, title: 'Sqlite', body: SqliteDemoScreen()),
    (icon: Icons.summarize_outlined, title: 'Agg', body: ListNAggScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: [
          for (final page in pages) page.body,
        ],
      ),
      bottomNavigationBar: SizedBox(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          currentIndex: pageIndex,
          onTap: (value) {
            setState(() {
              pageIndex = value;
            });

            controller.animateToPage(
              pageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: [
            for (final page in pages)
              BottomNavigationBarItem(
                icon: Icon(page.icon),
                label: page.title,
              ),
          ],
        ),
      ),
    );
  }
}
