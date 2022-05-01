import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'ImageSourceSelectionDialog.dart';

class ImagePickerFormFieldCroppingConfiguration {
  final int? maxWidth;
  final int? maxHeight;
  final CropAspectRatio? aspectRatio;
  final CropStyle cropStyle;
  final ImageCompressFormat compressFormat;
  final int compressQuality;
  final AndroidUiSettings? androidUiSettings;
  final IOSUiSettings? iosUiSettings;

  ImagePickerFormFieldCroppingConfiguration({
    this.maxWidth,
    this.maxHeight,
    this.aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1),
    this.cropStyle = CropStyle.rectangle,
    this.compressFormat = ImageCompressFormat.jpg,
    this.compressQuality = 90,
    this.androidUiSettings,
    this.iosUiSettings,
  });
}

class ImagePickerFormField extends FormField<File> {
  final bool previewEnabled;
  final Widget child;
  final ImagePickerFormFieldCroppingConfiguration? croppingConfiguration;
  ImagePickerFormField(
      {required BuildContext context,
      FormFieldSetter<File>? onSaved,
      FormFieldValidator<File>? validator,
      File? initialValue,
      AutovalidateMode autovalidateMode = AutovalidateMode.always,
      this.croppingConfiguration,
      required this.previewEnabled,
      required this.child})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<File> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        ImagePicker imagePicker = ImagePicker();
                        XFile? image;
                        ImageSourceSelectionDialog dialog =
                            ImageSourceSelectionDialog(
                                callback: (source) async {
                          if (source == 'gallery') {
                            image = await imagePicker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 100,
                                preferredCameraDevice: CameraDevice.front);
                          } else
                            image = await imagePicker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 100,
                                preferredCameraDevice: CameraDevice.front);
                          final croppedImage = await cropImage(
                              image, state, croppingConfiguration);
                          if (croppedImage != null && onSaved != null) {
                            onSaved(croppedImage);
                          }
                        });
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return dialog;
                            });
                      },
                      child: child),
                  SizedBox(
                    height: 8,
                  ),
                  if (previewEnabled && state.value != null)
                    Image.file(
                      state.value!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  if (state.value != null)
                    Text(
                      "${((state.value?.lengthSync() ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB",
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      textAlign: TextAlign.center,
                    ),
                  if (state.errorText != null)
                    Text(
                      state.errorText!,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(color: Colors.red),
                    )
                ],
              );
            });

  static Future<File?> cropImage(
    XFile? image,
    state,
    ImagePickerFormFieldCroppingConfiguration? croppingConfiguration,
  ) async {
    if (image != null) {
      File? imageFile = croppingConfiguration != null
          ? await ImageCropper.cropImage(
              maxHeight: croppingConfiguration.maxHeight,
              maxWidth: croppingConfiguration.maxWidth,
              compressFormat: croppingConfiguration.compressFormat,
              compressQuality: croppingConfiguration.compressQuality,
              sourcePath: image.path,
              cropStyle: croppingConfiguration.cropStyle,
              aspectRatio: croppingConfiguration.aspectRatio,
            )
          : await ImageCropper.cropImage(
              sourcePath: image.path,
              compressQuality: 100,
            );
      if (imageFile != null) {
        state.didChange(File(imageFile.path));
        return imageFile;
      }
    }
    return null;
  }
}
