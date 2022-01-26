import 'dart:io';

import 'package:flutter/material.dart';

class ImageDispatcher extends StatelessWidget {
  ImageDispatcher(this.image);

  dynamic image;

  @override
  Widget build(BuildContext context) {
    return image != null
        ? image is String
            ? FadeInImage.assetNetwork(
                placeholder: "assets/images/image_loading_placeholder.png", // Todo: change, sucks
                image: image!,
                fit: BoxFit.cover,
              )
            : image is File
                ? Image.file(
                    image!,
                    fit: BoxFit.cover,
                    color: const Color.fromRGBO(255, 255, 255, 0.85),
                    colorBlendMode: BlendMode.modulate,
                  )
                : Image.memory(
                    image!,
                    fit: BoxFit.cover,
                    color: const Color.fromRGBO(255, 255, 255, 0.85),
                    colorBlendMode: BlendMode.modulate,
                  )
        : Image.asset(
            "assets/images/missing_image_placeholder.png",
            fit: BoxFit.cover,
          );
  }
}
