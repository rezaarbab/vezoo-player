// lib/shell.dart — پوسته اصلی اپ با NavDock
// Home (browser) • Live (IPTV) • Discover (online) • Library • Settings
import 'package:flutter/material.dart';
import 'browser.dart' show BrowserScreen;
import 'iptv_screen.dart' show IptvScreen;
import 'online_player_sheet.dart' show OnlinePlayerSheet;
import 'library_screen.dart';
import 'settings_screen.dart';
import 'glass.dart';

/// سیگنال بازکردن پوشه در Home از صفحات دیگر (مثل Library)
class VzOpenFolderSignal {
  String? value;
  final List<VoidCallback> _listeners = [];
  void notifyListeners(){ for(final l in List.of(_listeners)) l(); }
  void addListener(VoidCallback l){ _listeners.add(l); }
  void removeListener(VoidCallback l){ _listeners.remove(l); }
}

/// پوسته اصلی — ناوبری dock شناور با ۵ مقصد
class VzShell extends StatefulWidget {
  const VzShell({super.key});
  @override State<VzShell> createState()=>_VzShellState();

  /// سیگنال عمومی: Library → Home folder navigation
  static final VzOpenFolderSignal openFolderInHome = VzOpenFolderSignal();
}

class _VzShellState extends State<VzShell>{
  VzNavDest _dest = VzNavDest.home;
  final GlobalKey<_BrowserHostState> _browserKey = GlobalKey<_BrowserHostState>();

  void _onOpenFolderSignal(){
    final path = VzShell.openFolderInHome.value;
    if(path == null) return;
    VzShell.openFolderInHome.value = null;
    setState(()=>_dest = VzNavDest.home);
    // فرصت یک frame به browser برای mount شدن
    WidgetsBinding.instance.addPostFrameCallback((_){
      _browserKey.currentState?.openPath(path);
    });
  }

  @override
  void initState(){
    super.initState();
    VzShell.openFolderInHome.addListener(_onOpenFolderSignal);
  }
  @override
  void dispose(){
    VzShell.openFolderInHome.removeListener(_onOpenFolderSignal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: Mo.normal,
        switchInCurve: Mo.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim)=>FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween(begin: 0.98, end: 1.0).animate(anim), child: child),
        ),
        child: KeyedSubtree(
          key: ValueKey(_dest),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: VzNavDock(
        current: _dest,
        onSelect: (d){
          if(d==VzNavDest.discover){
            // Discover = پخش آنلاین (sheet — صفحه جدا لازم ندارد)
            showModalBottomSheet(
              context: context, isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_)=>const OnlinePlayerSheet());
            return;
          }
          setState(()=>_dest=d);
        },
      ),
    );
  }

  Widget _buildBody()=>switch(_dest){
    VzNavDest.home     => _BrowserHost(key: _browserKey),
    VzNavDest.live     => const IptvScreen(),
    VzNavDest.library  => const LibraryScreen(),
    VzNavDest.settings=> const SettingsScreen(),
    VzNavDest.discover=> const _BrowserHost(), // unreachable — sheet
  };
}

/// میزبان BrowserScreen با API بازکردن مسیر
class _BrowserHost extends StatefulWidget {
  const _BrowserHost({super.key});
  @override State<_BrowserHost> createState()=>_BrowserHostState();
}
class _BrowserHostState extends State<_BrowserHost>{
  final GlobalKey<BrowserScreenState> _key = GlobalKey<BrowserScreenState>();

  void openPath(String path){
    _key.currentState?.openPath(path);
  }

  @override
  Widget build(BuildContext context)=>BrowserScreen(key: _key);
}
