import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'whisper_service.dart';
import 'player.dart';
import 'l10n.dart';

/// تاریخچه‌ی ویدیوهایی که برایشان زیرنویس AI ساخته شده
class AiHistoryScreen extends StatefulWidget {
  const AiHistoryScreen({super.key});
  @override State<AiHistoryScreen> createState() => _AiHistoryScreenState();
}

class _AiHistoryScreenState extends State<AiHistoryScreen> {
  List<String> _videos = [];
  bool _loading = true;

  @override void initState(){ super.initState(); _load(); }

  Future<void> _load() async {
    final list = await WhisperService.getHistoryVideos();
    if(mounted) setState((){ _videos=list; _loading=false; });
  }

  Future<void> _remove(String path) async {
    final ok = await showDialog<bool>(context:context, builder:(_)=>AlertDialog(
      backgroundColor:Vz.bgDeep,
      title:Text(L.deleteFromHistory,style:TextStyle(color:Vz.text,fontSize:15)),
      content:Text(L.deleteFromHistoryDesc,
        style:TextStyle(color:Vz.textSec,fontSize:12)),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context,false),child:Text(L.cancel)),
        FilledButton(onPressed:()=>Navigator.pop(context,true),
          style:FilledButton.styleFrom(backgroundColor:Colors.red),child:Text(L.delete)),
      ],
    ));
    if(ok==true){ await WhisperService.removeFromHistory(path); await _load(); }
  }

  Future<void> _openVideo(String path) async {
    await Navigator.push(context,MaterialPageRoute(
      builder:(_)=>PlayerScreen(playlist:[File(path)],playlistIndex:0),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor:Vz.bgDeep,
    appBar:AppBar(
      backgroundColor:Vz.bgDeep,
      title:Text(L.aiHistory,style:TextStyle(color:Vz.text,fontSize:15)),
      leading:IconButton(icon:Icon(Icons.arrow_back,color:Vz.text),onPressed:()=>Navigator.pop(context)),
    ),
    body: _loading
      ? Center(child:CircularProgressIndicator(color:Vz.accent))
      : _videos.isEmpty
        ? Center(child:Padding(
            padding:EdgeInsets.all(24),
            child:Text(L.noAiHistoryYet,
              style:TextStyle(color:Vz.textDim,fontSize:13),textAlign:TextAlign.center)))
        : ListView.builder(
            padding:const EdgeInsets.all(12),
            itemCount:_videos.length,
            itemBuilder:(_,i){
              final path = _videos[i];
              final langs = WhisperService.existingLanguages(path);
              return Container(
                margin:const EdgeInsets.only(bottom:8),
                decoration:BoxDecoration(color:Vz.bgDeep,borderRadius:BorderRadius.circular(12)),
                child:ListTile(
                  onTap:()=>_openVideo(path),
                  leading:Icon(Icons.movie_outlined,color:Vz.accent),
                  title:Text(p.basename(path),style:TextStyle(color:Vz.text,fontSize:13),
                    overflow:TextOverflow.ellipsis),
                  subtitle:Wrap(spacing:4,runSpacing:2,children:langs.map((l)=>Container(
                    padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),
                    decoration:BoxDecoration(color:Vz.accent.withOpacity(0.2),borderRadius:BorderRadius.circular(6)),
                    child:Text(kLanguages[l]??l,style:TextStyle(color:Vz.accent,fontSize:10)),
                  )).toList()),
                  trailing:IconButton(
                    icon:const Icon(Icons.close,color:Colors.white38,size:18),
                    onPressed:()=>_remove(path),
                  ),
                ),
              );
            },
          ),
  );
}
