import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_message.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../core/common/post_card.dart';
import '../../models/community_model.dart';
import '../controller/auth_controller.dart';

class CommunityScreen extends ConsumerWidget {

  final String name;
  const CommunityScreen({super.key, required this.name});

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref.read(communityControllerProvider.notifier).joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
          data: (community) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(child: Image.network(
                          community.banner,
                          fit: BoxFit.cover,
                        )
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                      padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Align(
                              alignment: Alignment.topLeft,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                                radius: 35,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'r/${community.name}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!isGuest) // If user exists on Community group
                                  community.mods.contains(user.uid) ? OutlinedButton(
                                        onPressed: () {
                                          navigateToModTools(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20)
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 25),
                                        ),
                                        child: const Text('Mod Tools'),
                                      )
                                      : OutlinedButton(
                                          onPressed: () => joinCommunity(ref, community, context),
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20)
                                              ),
                                            padding: const EdgeInsets.symmetric(horizontal: 25),
                                          ),
                                          child: Text(community.members.contains(user.uid) ? 'Leave' : 'Join'),
                                      ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text('${community.members.length} member(s)'),
                            ),
                          ],
                        ),
                    ),
                  )
                ];
              },
              body: ref.watch(getCommunityPostsProvider(name)).when(
                data: (data) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = data[index];
                      return PostCard(post: post);
                    },
                  );
                },
                error: (error, stackTrace) {
                  return ErrorMessage(error: error.toString());
                },
                loading: () => const Loader(),
              ),
          ),
          error: (error, stackTrace) => ErrorMessage(error: error.toString()),
          loading: () => const Loader(),
      ),
    );
  }
}