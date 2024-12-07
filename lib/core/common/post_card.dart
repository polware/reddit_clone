import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_message.dart';
import 'package:reddit_clone/core/common/responsive.dart';
import 'package:routemaster/routemaster.dart';

import '../../features/controller/auth_controller.dart';
import '../../features/controller/community_controller.dart';
import '../../features/controller/post_controller.dart';
import '../../models/post_model.dart';
import '../../theme/pallete.dart';
import '../constants/constants.dart';
import 'loader.dart';

// Terminal: flutter pub add any_link_preview

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upVotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upVote(post);
  }

  void downVotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downVote(post);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref.read(postControllerProvider.notifier).awardPost(post: post, award: award, context: context);
  }

  void navigateToUserProfile(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Responsive(
      child: Column(
        children: [
          const SizedBox(height: 20), // Espacio superior de Postcard
          Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kIsWeb)
                  Column(
                    children: [
                      IconButton(
                        onPressed: isGuest ? () {} : () => upVotePost(ref),
                        icon: Icon(
                          Constants.upVote,
                          size: 30,
                          color: post.upvotes.contains(user.uid) ? Colors.green.shade300 : null,
                        ),
                      ),
                      Text(
                        '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                        style: const TextStyle(fontSize: 17),
                      ),
                      IconButton(
                        onPressed: isGuest ? () {} : () => downVotePost(ref),
                        icon: Icon(
                          Constants.downVote,
                          size: 30,
                          color: post.downvotes.contains(user.uid) ? Pallete.redColor : null,
                        ),
                      ),
                    ],
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4, // 4
                          horizontal: 16,
                        ).copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToCommunity(context),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          post.communityProfilePic,
                                        ),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'r/${post.communityName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => navigateToUserProfile(context),
                                            child: Text(
                                              'u/${post.username}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.uid == user.uid) // Delete icon
                                  IconButton(
                                    onPressed: () => deletePost(ref, context),
                                    icon: Icon(
                                      Icons.delete,
                                      color: Pallete.redColor,
                                    ),
                                  ),
                              ],
                            ),
                            if (post.awards.isNotEmpty) ...[ /** Post awards */
                              const SizedBox(height: 5),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final awardItem = post.awards[index];
                                    return Image.asset(
                                      Constants.awards[awardItem]!,
                                      height: 23,
                                    );
                                  },
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isTypeImage) /** Post type Image */
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: Image.network(
                                          post.link!,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            if (isTypeLink) /** Post type Link */
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: AnyLinkPreview(
                                        displayDirection: UIDirection.uiDirectionHorizontal,
                                        link: post.link!,
                                        ),
                              ),
                            if (isTypeText) /** Post type Text */
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!kIsWeb)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: isGuest ? () {} : () => upVotePost(ref),
                                        icon: Icon(
                                          Constants.upVote,
                                          size: 30,
                                          color: post.upvotes.contains(user.uid) ? Pallete.redColor : null,
                                        ),
                                      ),
                                      Text(
                                        '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                      IconButton(
                                        onPressed: isGuest ? () {} : () => downVotePost(ref),
                                        icon: Icon(
                                          Constants.downVote,
                                          size: 30,
                                          color: post.downvotes.contains(user.uid) ? Pallete.blueColor : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => navigateToComments(context),
                                      icon: const Icon(
                                        Icons.comment,
                                      ),
                                    ),
                                    Text(
                                      '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                ref.watch(getCommunityByNameProvider(post.communityName)).when( // Moderator icon
                                  data: (data) {
                                    if (data.mods.contains(user.uid)) {
                                      return IconButton(
                                        onPressed: () => deletePost(ref, context),
                                        icon: const Icon(
                                          Icons.admin_panel_settings,
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                  error: (error, stackTrace) => ErrorMessage(
                                    error: error.toString(),
                                  ),
                                  loading: () => const Loader(),
                                ),
                                IconButton(
                                  onPressed: isGuest ? () {} : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                            ),
                                            itemCount: user.awards.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final awardIndex = user.awards[index];

                                              return GestureDetector(
                                                onTap: () => awardPost(ref, awardIndex, context),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset(Constants.awards[awardIndex]!),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.card_giftcard_outlined),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //const SizedBox(height: 10), // Espacio inferior de Postcard
        ],
      ),
    );
  }
}