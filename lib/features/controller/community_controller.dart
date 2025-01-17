import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';
import '../../core/constants/constants.dart';
import '../../core/failure.dart';
import '../../core/providers/storage_repository_provider.dart';
import '../../core/utils.dart';
import '../../models/community_model.dart';
import '../../models/post_model.dart';
import '../repository/community_repository.dart';
import 'auth_controller.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref.watch(communityControllerProvider.notifier).getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});

final communityControllerProvider = StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);

  return CommunityController(
    communityRepository: communityRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  }) : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';

    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final res = await _communityRepository.createCommunity(community);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully!');
      Routemaster.of(context).pop();
    });
  }

  void joinCommunity(Community community, BuildContext context) async {

    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;

    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    }
    else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, 'Community left successfully!');
      }
      else {
        showSnackBar(context, 'Community joined successfully!');
      }
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid); // Conecta con la clase CommunityRepository
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true; // Valor usado en isLoading

    if (profileFile != null || profileWebFile != null) {

      final res = await _storageRepository.saveFileToFbStorage(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold(
            (l) => showSnackBar(context, l.message),
            (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerFile != null || bannerWebFile != null) {

      final res = await _storageRepository.saveFileToFbStorage(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold(
            (l) => showSnackBar(context, l.message),
            (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);
    state = false; // Valor usado en isLoading
    res.fold(
          (l) => showSnackBar(context, l.message),
          (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold(
          (l) => showSnackBar(context, l.message),
          (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }

}
