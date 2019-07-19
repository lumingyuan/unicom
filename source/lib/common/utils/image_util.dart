import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';
import 'package:quiver/strings.dart';

class ImageUtil {
  static Image image(String image,
      {BoxFit fit,
      ImageRepeat repeat = ImageRepeat.noRepeat,
      double width,
      double height}) {
    return Image.asset(
      'assets/images/$image',
      fit: fit,
      repeat: repeat,
      width: width,
      height: height,
    );
  }

  static ImageProvider assetImage(String image) {
    return AssetImage('assets/images/$image');
  }

  //显示网络图片
  static Widget imageFromUrl(String url,
      {Image placeholder,
      BoxFit fit = BoxFit.contain,
      double width,
      double height}) {
    if (placeholder == null) {
      placeholder = image('placeholder.png', fit: fit);
    }
    if (isEmpty(url)) {
      return placeholder;
    }
    try {
      return CachedNetworkImage(
        width: width,
        height: height,
        imageUrl: url,
        fit: fit,
        placeholder: (context, url) {
          return CupertinoActivityIndicator();
        },
        errorWidget: (context, url, obj) {
          return placeholder;
        },
      );
    } catch (e) {
      print('$e');
      return image('placeholder.png', fit: fit);
    }
  }

  static ImageProvider imageProviderFromUrl(String url) {
    try {
      return CachedNetworkImageProvider(url);
    } catch (e) {
      print('$e');
      return assetImage('placeholder.png');
    }
  }

  static Image imageFromBase64(String base64) {
    return Image.memory(base64Decode(base64));
  }

  ///清空缓存
  static void clearCache() async {
    await DefaultCacheManager().emptyCache();
  }

  /// 递归方式 计算文件的大小
  static Future<double> getTotalSizeOfFilesInDir(
      final FileSystemEntity file) async {
    try {
      if (file is File) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        double total = 0;
        if (children != null)
          for (final FileSystemEntity child in children)
            total += await getTotalSizeOfFilesInDir(child);
        return total;
      }
      return 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }
}
