import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as Img;

class OurImageProvider extends ImageProvider<_OurKey>{
final ImageProvider imageProvider;
 List<int> bytes;
 
  OurImageProvider({this.imageProvider});

    @override
    Future<_OurKey>  obtainKey(ImageConfiguration configuration) {
     Completer<_OurKey> completer;

     SynchronousFuture<_OurKey> result;
     imageProvider.obtainKey(configuration).then((Object key){
       if(completer == null){
         result = SynchronousFuture<_OurKey>(_OurKey(key));
       }
       else{
         completer.complete(_OurKey(key));
       }
     });

     if(result != null){
       return result;
     }

     return completer.future;
  }

  @override
  ImageStreamCompleter load(_OurKey   key, decode) {
    final ourDecoder = (
      Uint8List bytes, {
        bool allowUpscaling,
        int cacheWidth,
        int cacheHeight,
      }) async {
        return decode(
          await whiteToAlfa(bytes),
          cacheWidth : cacheWidth,
          cacheHeight : cacheHeight,
        );
      };

      return imageProvider.load(key.pCachKey, ourDecoder);
  }

  whiteToAlfa(Uint8List bytes) async{
    final image = Img.decodeImage(bytes);

    final pixels = image.getBytes();
    final lenth = pixels.lengthInBytes;

    int r = (pixels[0] + pixels[8]) ~/ 2;
    int g = (pixels[1] + pixels[9]) ~/ 2;
    int b = (pixels[2] + pixels[10]) ~/ 2;

    int x = image.width.toInt();
    int y = image.height.toInt();
    int w = 0;
    int h = 100;

    for(int i = 0; i < lenth; i+=4){
      if((pixels[i] - (r-20)).abs() < 50 && (pixels[i+1] - (g-20)).abs() < 50 && (pixels[i+2] - (b-20)).abs() < 50){
        image.setPixelRgba(((i~/4)%image.width), ((i/4)~/image.width), 255,0,0,0);
      }
      else{
        if(((i~/4)%image.width) < x)
          x = ((i~/4)%image.width);

        if(((i~/4)%image.width) > w)
          w = ((i~/4)%image.width);

        if(y > ((i/4)~/image.width))
          y = ((i/4)~/image.width);

        if(h < ((i/4)~/image.width))
          h = ((i/4)~/image.width);

      }
    }

    image.channels = Img.Channels.rgba;

    var thumbnail = Img.copyCrop(image, x,y,w - x,h-y);

    this.bytes = Img.encodePng(thumbnail);
    return this.bytes;
  }

}

class _OurKey{
  final Object pCachKey;
  const _OurKey(this.pCachKey);

  @override
  bool operator == (Object other){
    if(this.runtimeType != other.runtimeType) return false;

    return other is _OurKey && other.pCachKey == this.pCachKey;
  }

  @override 
  int get hashCode => pCachKey.hashCode;  
}