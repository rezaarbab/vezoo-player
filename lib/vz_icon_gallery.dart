// lib/vz_icon_gallery.dart — گالری گلیف‌های فونت موئه
//
// فونت VanFont (استخراج‌شده از وب Bilibili) ۶۲ گلیف دارد. ۵ تای آن
// شناخته‌شده است و بقیه با نام `van<hex>` در دسترس‌اند. این صفحه همه را
// کنار هم نشان می‌دهد تا بتوانی هر گلیف را ببینی و برایش نام معنادار
// انتخاب کنی.
//
// ── چطور یک گلیف را نام‌گذاری کنم؟ ──
//  ۱) این صفحه را باز کن و کدپوینت گلیف موردنظر را بردار (مثل U+E604).
//  ۲) در lib/vz_icons.dart داخل BiliIconPack.known اضافه کن:
//         'myName': 0xE604,
//  ۳) از آن به بعد در کل اپ با VzIcon('myName') در دسترس است.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'glass.dart';
import 'l10n.dart';
import 'vz_icons.dart';

class VzIconGalleryScreen extends StatelessWidget {
  const VzIconGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('VanFont — ${BiliIconPack.allCodePoints.length} glyphs'),
        leading: IconButton(
          icon: Icon(VzIcons.data('back')),
          onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, Sp.xxl),
          children: [
            // ── راهنما ──
            VzGlass(
              padding: const EdgeInsets.all(Sp.md),
              child: Row(children: [
                Icon(VzIcons.data('info'), size: 18, color: Vz.accent),
                const SizedBox(width: Sp.sm),
                Expanded(child: Text(
                  'Tap any glyph to copy its code point, then add it to '
                  'BiliIconPack.known in lib/vz_icons.dart to give it a name.',
                  style: Ty.caption.copyWith(fontSize: 11))),
              ]),
            ),
            const SizedBox(height: Sp.md),

            // ── گلیف‌های نام‌دار ──
            VzSectionLabel(text: 'Named (${BiliIconPack.known.length})'),
            _grid(context, BiliIconPack.known.entries
              .map((e) => MapEntry(e.key, e.value)).toList(),
              named: true),

            // ── بقیه ──
            VzSectionLabel(
              text: 'Unnamed (${BiliIconPack.allCodePoints.length - BiliIconPack.known.length})'),
            _grid(context,
              BiliIconPack.allCodePoints
                .where((cp) => !BiliIconPack.known.containsValue(cp))
                .map((cp) => MapEntry('van${cp.toRadixString(16).toUpperCase()}', cp))
                .toList(),
              named: false),
          ],
        ),
      ),
    );
  }

  Widget _grid(BuildContext context, List<MapEntry<String,int>> items,
      {required bool named}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 110, mainAxisSpacing: 8, crossAxisSpacing: 8,
        childAspectRatio: 0.86),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final entry = items[i];
        final cp = entry.value;
        return InkWell(
          borderRadius: Rad.r(Rad.sm),
          onTap: () {
            Clipboard.setData(ClipboardData(
              text: 'U+${cp.toRadixString(16).toUpperCase()}'));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Copied U+${cp.toRadixString(16).toUpperCase()}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating));
          },
          child: VzGlass(
            padding: const EdgeInsets.all(6),
            radius: Rad.s(Rad.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: Icon(
                  IconData(cp, fontFamily: 'VanFont'),
                  size: 34,
                  color: named ? Vz.accent : Vz.text))),
                Text(entry.key,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Ty.mono.copyWith(fontSize: 8.5)),
              ]),
          ),
        );
      },
    );
  }
}
