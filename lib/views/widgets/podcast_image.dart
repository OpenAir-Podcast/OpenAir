import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget podcastImage(String imagePath,
    {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      width: width,
      height: height,
      fit: fit,
      errorWidget: (context, url, error) => const Icon(
        Icons.podcasts,
        size: 32,
      ),
    );
  }
  return Image.file(
    File(imagePath),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => const Icon(
      Icons.podcasts,
      size: 32,
    ),
  );
}
