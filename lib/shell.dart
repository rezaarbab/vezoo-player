// lib/shell.dart — پوسته اصلی اپ با NavDock
// Home (browser) • Live (IPTV) • Discover (online) • Library • Settings
import 'package:flutter/material.dart';
import 'browser.dart' show BrowserScreen, BrowserScreenState;
import 'iptv_screen.dart' show IptvScreen;
import 'online_player_sheet.dart' show OnlinePlayerSheet;
import 'library_screen.dart';
import 'settings_screen.dart';
import 'signals.dart';
import 'glass.dart';

/// پوسته اصلی — ناوبری dock شناور با ۵ مقصد
class VzShell extends StatefulWidget {
  const VzShell({super.key});
  @override State<VzShell> createState()=>_VzShellState();
}

class _VzShellState extends State<VzShell>{
  VzNavDest _dest = VzNavDest.home;

  void _onOpenFolderSignal(){
    final path = vzOpenFolderSignal.value;
    if(path == null) return;
    vzOpenFolderSignal.value = null;
    setState(()=>_dest = VzNavDest.home);
    // یک frame بعد از فعال شدن Home
    WidgetsBinding.instance.addPostFrameCallback((_){
      if (!mounted) return;
      _browserKey.currentState?.openPath(path);
    });
  }

  // برای Home یک key پایدار — Home همیشه در درخت می‌ماند (Stack)
  final GlobalKey<BrowserScreenState> _browserKey = GlobalKey<BrowserScreenState>();

  @override
  void initState(){
    super.initState();
    vzOpenFolderSignal.addListener(_onOpenFolderSignal);
  }
  @override
  void dispose(){
    vzOpenFolderSignal.removeListener(_onOpenFolderSignal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBody: false,
      body: _buildBody(),
      bottomNavigationBar: VzNavDock(
        current: _dest,
        onSelect: (d){
          if(d==VzNavDest.discover){
            // Discover = پخش آنلاین (sheet)
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

  // IndexedStack: state همه صفحه‌ها حفظ می‌شود، transition نرم با AnimatedOpacity
  Widget _buildBody(){
    return Stack(children: [
      // Home زیر همه می‌ماند — mount دائم
      _offstage(VzNavDest.home, BrowserScreen(key: _browserKey)),
      _offstage(VzNavDest.live, const IptvScreen()),
      _offstage(VzNavDest.library, const LibraryScreen()),
      _offstage(VzNavDest.settings, const SettingsScreen()),
    ]);
  }

  Widget _offstage(VzNavDest dest, Widget child){
    final active = _dest == dest;
    return ExcludeSemantics(
      excluding: !active,
      child: ExcludeFocus(
        excluding: !active,
        child: IgnorePointer(
          ignoring: !active,
          child: TickerMode(
            enabled: active,
            child: AnimatedOpacity(
              duration: Mo.normal,
              curve: Mo.easeOut,
              opacity: active ? 1 : 0,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
