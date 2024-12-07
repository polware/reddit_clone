import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_message.dart';

import '../../core/common/loader.dart';
import '../../core/common/responsive.dart';
import '../../core/utils.dart';
import '../../models/community_model.dart';
import '../../theme/pallete.dart';
import '../controller/community_controller.dart';
import '../controller/post_controller.dart';

class PostTypeScreen extends ConsumerStatefulWidget {
  final String type;

  const PostTypeScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostTypeScreenState();
}

class _PostTypeScreenState extends ConsumerState<PostTypeScreen> {

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? postImageFile;
  Uint8List? postImageWebFile;
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectPostImage() async {
    final res = await pickImage();

    if (res != null) {
      if (kIsWeb) {
        setState(() {
          postImageWebFile = res.files.first.bytes;
        });
      }
      setState(() {
        postImageFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' && (postImageFile != null || postImageWebFile != null) && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
        context: context,
        title: titleController.text.trim(),
        selectedCommunity: selectedCommunity ?? communities[0],
        file: postImageFile,
        webFile: postImageWebFile,
      );
    }
    else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
        context: context,
        title: titleController.text.trim(),
        selectedCommunity: selectedCommunity ?? communities[0],
        description: descriptionController.text.trim(),
      );
    }
    else if (widget.type == 'link' && titleController.text.isNotEmpty && linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
        context: context,
        title: titleController.text.trim(),
        selectedCommunity: selectedCommunity ?? communities[0],
        link: linkController.text.trim(),
      );
    }
    else {
      showSnackBar(context, 'Please complete all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text('Share'),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Responsive(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter Title',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
                maxLength: 30,
              ),
              const SizedBox(height: 10),
              if (isTypeImage) /** Post tipo Imagen */
                GestureDetector(
                  onTap: selectPostImage,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: currentTheme.textTheme.bodyMedium!.color!,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: postImageWebFile != null
                          ? Image.memory(postImageWebFile!)
                          : postImageFile != null
                          ? Image.file(postImageFile!)
                          : const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isTypeText) /** Post tipo Texto */
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Enter Description',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),
                  maxLines: 5,
                ),
              if (isTypeLink) /** Post tipo Link */
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Enter Link',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Select Community',
                ),
              ),
              ref.watch(userCommunitiesProvider).when(
                data: (data) {
                  communities = data;

                  if (data.isEmpty) {
                    return const SizedBox();
                  }

                  return DropdownButton(
                    value: selectedCommunity ?? data[0],
                    items: data.map(
                          (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ),
                    ).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCommunity = val;
                      });
                    },
                  );
                },
                error: (error, stackTrace) => ErrorMessage(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}