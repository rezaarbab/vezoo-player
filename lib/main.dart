import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'shell.dart';
import 'store.dart';
import 'l10n.dart';
import 'api_service.dart';
import 'theme.dart';
import 'vz_motion.dart';
import 'vz_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
/// نمایش snackbar که همیشه بالای navbar میاد
/// کلید جهانی برای نمایش snackbar بالای همه چیز (حتی bottom sheet ها)
final GlobalKey<ScaffoldMessengerState> rootScaffoldKey = GlobalKey<ScaffoldMessengerState>();

/// نمایش snackbar که همیشه بالای navbar میاد — حتی از داخل sheet
void showSnack(BuildContext ctx, String msg, {
  Color? color,
  int seconds = 5,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = rootScaffoldKey.currentState ?? ScaffoldMessenger.of(ctx);
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: color ?? Vz.accent,
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
  // لایه‌ی آیکون نباید به theme وابسته باشد — کلید انیمیشن را اینجا وصل می‌کنیم
  VzIcons.animationsEnabled = () => Vz.animations;
  await L.load(); // بارگذاری زبان ذخیره‌شده
  await Store.load();
  await ApiService.init();

  // ── Theme persistence hooks (wired to SharedPreferences) ──
  storeThemePrefs = () async {
    final p = await SharedPreferences.getInstance();
    return p.getString('app_theme');
  };
  storeThemeSave = (v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('app_theme', v);
  };
  // تم انتخاب‌شده (VzThemeDef id)
  storeThemeIdPrefs = () async =>
      (await SharedPreferences.getInstance()).getString('app_theme_id');
  storeThemeIdSave = (v) async {
    await (await SharedPreferences.getInstance()).setString('app_theme_id', v);
  };
  // رنگ دانه‌ی دلخواه کاربر
  storeCustomSeedPrefs = () async =>
      (await SharedPreferences.getInstance()).getInt('app_seed_custom');
  storeCustomSeedSave = (v) async {
    final p = await SharedPreferences.getInstance();
    if (v == null) {
      await p.remove('app_seed_custom');
    } else {
      await p.setInt('app_seed_custom', v);
    }
  };
  storeAnimPrefs = () async =>
      (await SharedPreferences.getInstance()).getBool('app_animations');
  storeAnimSave = (v) async {
    await (await SharedPreferences.getInstance()).setBool('app_animations', v);
  };
  // سبک انیمیشن کلیک
  storeClickPrefs = () async =>
      (await SharedPreferences.getInstance()).getString('app_click_style');
  storeClickSave = (v) async {
    await (await SharedPreferences.getInstance()).setString('app_click_style', v);
  };
  storeBgPrefs = () async =>
      (await SharedPreferences.getInstance()).getString('app_bg_style');
  storeBgSave = (v) async {
    await (await SharedPreferences.getInstance()).setString('app_bg_style', v);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // VzTheme بالای MaterialApp تا بتونه theme data رو rebuild کنه
    return VzTheme(
      child: VzThemeScopeBuilder(),
    );
  }
}

/// MaterialApp را از روی scope می‌سازد.
///
/// مهم: باید به **همه‌ی** فیلدهای تم وابسته باشد نه فقط روشن/تیره — وگرنه
/// عوض کردن تم (Shade → Anime هر دو تیره) یا رنگ دانه هیچ rebuildی
/// نمی‌دهد و کاربر مجبور می‌شود اپ را ببندد و باز کند.
class VzThemeScopeBuilder extends StatelessWidget {
  const VzThemeScopeBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    // وابستگی به همه‌ی ابعاد تم
    final scope = VzThemeScope.maybeOf(context);
    final dark = scope?.isDark ?? Vz.isDark;
    final themeId = scope?.themeId ?? Vz.theme.id;
    final seed = scope?.customSeed ?? scope?.dynamicSeed ?? Vz.seed;
    final bgStyle = scope?.bgStyle ?? Vz.bgStyle;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    ));

    // کلید یکتا: با هر تغییر تم/seed/حالت، MaterialApp از نو ساخته می‌شود
    // تا پالت و theme data هرگز کهنه نمانند.
    final themeKey = ValueKey('$themeId|$seed|$dark|$bgStyle');

    return MaterialApp(
      key: themeKey,
      scaffoldMessengerKey: rootScaffoldKey,
      title: 'Vezoo',
      debugShowCheckedModeBanner: false,
      theme: buildVezooTheme(dark: dark),
      darkTheme: buildVezooTheme(dark: true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      builder: (ctx, child) {
        final mq = MediaQuery.of(ctx);
        return MediaQuery(
          // کلید انیمیشن کاربر — ترنزیشن‌های خود فریم‌ورک را هم خاموش می‌کند
          data: mq.copyWith(disableAnimations: !Vz.animations),
          child: Directionality(
            textDirection: langDir(L.current),
            child: VzAmbientBg(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
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
  /// اسپلش فقط یک‌بار در طول عمر پروسه نشان داده می‌شود (نه با هر تغییر تم).
  static bool _splashShown = false;
  bool _splash = !_splashShown;

  @override void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)=>_startup());
    if (!_splash) return;
    _splashShown = true;
    Future.delayed(Duration(milliseconds: Vz.animations ? 1500 : 300), (){
      if (mounted) setState(()=>_splash = false);
    });
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

  @override Widget build(BuildContext ctx) => AnimatedSwitcher(
    duration: Mo.sheet,
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    child: _splash
      ? const VzSplash(key: ValueKey('splash'))
      : const VzShell(key: ValueKey('shell')),
  );
}
