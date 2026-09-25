// lib/shell.dart — پوسته اصلی اپ با NavDock
// Home (browser) • Live (IPTV) • Discover (online) • Library • Settings
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'browser.dart' show BrowserScreen, BrowserScreenState;
import 'iptv_screen.dart' show IptvScreen;
import 'online_player_sheet.dart' show OnlinePlayerSheet;
import 'library_screen.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';
import 'signals.dart';
import 'glass.dart';
import 'vz_motion.dart';

/// پوسته اصلی — IndexedStack با ۵ مقصد (Discover به‌صورت مودال باز می‌شود)
class VzShell extends StatefulWidget {
  const VzShell({super.key});
  @override State<VzShell> createState()=>_VzShellState();
}

class _VzShellState extends State<VzShell>{
  VzNavDest _dest = VzNavDest.home;

  /// ترتیب تب‌های واقعی — Discover در این لیست نیست چون مودال است.
  static const _tabs = [VzNavDest.home, VzNavDest.live, VzNavDest.gallery, VzNavDest.library, VzNavDest.sponsors, VzNavDest.settings];

  int get _index {
    final i = _tabs.indexOf(_dest);
    return i < 0 ? 0 : i;
  }

  void _onOpenFolderSignal(){
    final path = vzOpenFolderSignal.value;
    if(path == null) return;
    vzOpenFolderSignal.value = null;
    setState(()=>_dest = VzNavDest.home);
    // یک frame بعد از فعال شدن Home
    WidgetsBinding.instance.addPostFrameCallback((_){
      final ctx = _browserKey.currentContext;
      if(ctx != null){
        final state = ctx.findAncestorStateOfType<BrowserScreenState>();
        state?.openPath(path);
      }
    });
  }

  // برای Home یک key پایدار — Home همیشه در درخت می‌ماند (IndexedStack)
  final GlobalKey _browserKey = GlobalKey();

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

  void _onSelect(VzNavDest d){
    HapticFeedback.selectionClick();
    if(d==VzNavDest.discover){
      // Discover = پخش آنلاین (مودال، وابسته به تب جاری نیست)
      showModalBottomSheet(
        context: context, isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_)=>const OnlinePlayerSheet());
      return;
    }
    if(d == _dest) return;
    setState(()=>_dest=d);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBody: true,
      // پس‌زمینه شفاف تا گرادیان Ambient دیده شود (سبک‌های bg واقعاً کار کنند)
      backgroundColor: Colors.transparent,
      // IndexedStack: state هر تب حفظ می‌شود و هیچ صفحه‌ای با opacity صفر
      // در هر فریم composite نمی‌شود.
      body: VzTabSwitcher(
        index: _index,
        child: IndexedStack(
          index: _index,
          children: [
            // بدون const — این صفحات باید با عوض شدن تم از نو ساخته شوند،
            // وگرنه رنگ‌های Vz.* سراسری روی آن‌ها کهنه می‌ماند.
            KeyedSubtree(key: _browserKey, child: BrowserScreen()),
            IptvScreen(),
            GalleryScreen(),
            LibraryScreen(),
            SponsorsScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: VzNavDock(
        current: _dest,
        onSelect: _onSelect,
      ),
    );
  }
}
