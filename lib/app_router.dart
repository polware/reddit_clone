import 'package:flutter/material.dart';
import 'package:reddit_clone/features/screens/add_moderators.dart';
import 'package:reddit_clone/features/screens/home.dart';
import 'package:reddit_clone/features/screens/user_profile.dart';
import 'package:routemaster/routemaster.dart';
import 'features/screens/add_post.dart';
import 'features/screens/comments.dart';
import 'features/screens/community.dart';
import 'features/screens/create_community.dart';
import 'features/screens/edit_community.dart';
import 'features/screens/edit_profile.dart';
import 'features/screens/login.dart';
import 'features/screens/mod_tools.dart';
import 'features/screens/post_type.dart';

final loggedOutRoute = RouteMap(routes: {

  '/': (_) => const MaterialPage(child: Login()),
  }
);

final loggedInRoute = RouteMap(routes: {

  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const MaterialPage(child: CreateCommunity()),
  '/r/:name': (route) => MaterialPage(
      child: CommunityScreen(
        name: route.pathParameters['name']!,
      )
  ),
  '/mod-tools/:name': (routeData) => MaterialPage(
      child: ModToolsScreen(
        name: routeData.pathParameters['name']!,
      )
  ),
  '/edit-community/:name': (routeData) => MaterialPage(
    child: EditCommunityScreen(
      name: routeData.pathParameters['name']!,
    )
  ),
  '/add-mods/:name': (routeData) => MaterialPage(
      child: AddModsScreen(
        name: routeData.pathParameters['name']!,
      )
  ),
  '/u/:uid': (routeData) => MaterialPage(
      child: UserProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )
  ),
  '/edit-profile/:uid': (routeData) => MaterialPage(
      child: EditProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )
  ),
  '/add-post': (routeData) => const MaterialPage(
      child: AddPostScreen()
  ),
  '/add-post/:type': (routeData) => MaterialPage(
    child: PostTypeScreen(
      type: routeData.pathParameters['type']!,
    ),
  ),
  '/post/:postId/comments': (route) => MaterialPage(
    child: CommentsScreen(
      postId: route.pathParameters['postId']!,
    ),
  ),

});
