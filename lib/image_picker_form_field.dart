import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'ImageSourceSelectionDialog.dart';

class ImagePickerFormField extends FormField<File> {
  final bool previewEnabled;
  final Widget child;
  ImagePickerFormField(
      {required BuildContext context,
      FormFieldSetter<File>? onSaved,
      FormFieldValidator<File>? validator,
      File? initialValue,
      AutovalidateMode autovalidateMode = AutovalidateMode.always,
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
                          cropImage(image, state);
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
                      "Name: " + state.value!.path.split('/').last,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
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

  static Future<void> cropImage(XFile? image, state) async {
    if (image != null) {
      File? imageFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        compressQuality: 100,
      );
      if (imageFile != null) state.didChange(File(imageFile.path));
    }
  }
}
