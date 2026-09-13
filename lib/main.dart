import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'browser.dart';
import 'shell.dart';
import 'store.dart';
import 'l10n.dart';
import 'api_service.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// نمایش snackbar که همیشه بالای navbar میاد
/// کلید جهانی برای نمایش snackbar بالای همه چیز (حتی bottom sheet ها)
final GlobalKey<ScaffoldMessengerState> rootScaffoldKey = GlobalKey<ScaffoldMessengerState>();

/// نمایش snackbar که همیشه بالای navbar میاد — حتی از داخل sheet
void showSnack(BuildContext ctx, String msg, {
  Color color = const Color(0xFF8B5CF6),
  int seconds = 5,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = rootScaffoldKey.currentState ?? ScaffoldMessenger.of(ctx);
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: color,
    duration: Duration(seconds: seconds),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 70),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    action: actionLabel != null ? SnackBarAction(
      label: actionLabel,
      textColor: Colors.white,
      onPressed: onAction ?? () {},
    ) : null,
  ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await L.load(); // بارگذاری زبان ذخیره‌شده
  await Store.load();
  await ApiService.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xFF0B0B10),
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldKey,
      title: 'Vezoo',
      debugShowCheckedModeBanner: false,
      theme: buildVezooTheme(),
      builder: (ctx, child) => Directionality(
        textDirection: langDir(L.current),
        child: VzAmbientBg(child: child ?? const SizedBox.shrink()),
      ),
      home: const _HomeWrapper(),
    );
  }
}

// ── Wrapper: startup check برای آپدیت و اعلان ──
class _HomeWrapper extends StatefulWidget {
  const _HomeWrapper();
  @override State<_HomeWrapper> createState()=>_HomeWrapperState();
}
class _HomeWrapperState extends State<_HomeWrapper>{
  @override void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)=>_startup());
  }

  Future<void> _startup()async{
    ApiService.sendStat('open');
    await Future.delayed(const Duration(seconds:2));
    if(!mounted)return;
    // چک آپدیت
    final cfg=await ApiService.getConfig();
    if(cfg!=null&&mounted){
      final force=cfg['force_update']=='1';
      if(ApiService.isNewer(cfg['app_version']??'',ApiService.appVersion)){
        await _showUpdate(cfg,force);
      }
    }
    if(!mounted)return;
    // چک اعلان
    final ann=await ApiService.getAnnouncement();
    if(ann!=null&&mounted)await _showAnnounce(ann);
  }

  Future<void> _showUpdate(Map cfg,bool force)async{
    await showDialog(context:context,barrierDismissible:!force,builder:(ctx)=>AlertDialog(
      title:Text(cfg['update_title']??L.update),
      content:Text(cfg['update_message']??L.newVersionAvailable),
      actions:[
        if(!force)TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(L.later)),
        FilledButton(onPressed:()async{
          final url=cfg['download_url']??'';
          if(url.isNotEmpty)await launchUrl(Uri.parse(url),mode:LaunchMode.externalApplication);
          if(mounted&&!force)Navigator.pop(ctx);
        },child:Text(L.download)),
      ],
    ));
  }

  Future<void> _showAnnounce(Map ann)async{
    // چک تعداد نمایش
    final annId=ann['id']?.toString()??'0';
    final maxShows=(ann['max_shows']??1) as int;
    final prefs=await SharedPreferences.getInstance();
    final showKey='ann_shown_$annId';
    final shownCount=prefs.getInt(showKey)??0;
    if(maxShows>0&&shownCount>=maxShows)return; // به حد رسیده
    await prefs.setInt(showKey,shownCount+1); // یه بار دیگه نشون داده شد

    final cancel=(ann['cancellable']??1).toString()!='0';
    await showDialog(context:context,barrierDismissible:cancel,builder:(ctx)=>AlertDialog(
      title:Text(ann['title']??''),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        if((ann['image_url']??'').isNotEmpty)ClipRRect(
          borderRadius:BorderRadius.circular(8),
          child:Image.network(ann['image_url'],height:160,fit:BoxFit.cover,
            errorBuilder:(_,__,___)=>const SizedBox())),
        if((ann['message']??'').isNotEmpty)Padding(
          padding:const EdgeInsets.only(top:12),child:Text(ann['message'])),
      ]),
      actions:[
        if(cancel)TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(L.close)),
        if((ann['link']??'').isNotEmpty)FilledButton(
          onPressed:()async{
            await launchUrl(Uri.parse(ann['link']),mode:LaunchMode.externalApplication);
            if(mounted)Navigator.pop(ctx);
          },child:Text(ann['link_text']??L.view)),
      ],
    ));
  }

  @override Widget build(BuildContext ctx)=>const VzShell();
}
