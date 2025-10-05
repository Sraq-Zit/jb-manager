import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jbmanager/constants/assets.dart';

// ignore: must_be_immutable
class JBAppBar {
  List<Widget>? actions;
  final void Function(String)? onSearch;
  final bool notificationAction;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  bool _isSearching = false;
  JBAppBar({this.actions, this.onSearch, this.notificationAction = true});

  AppBar build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      surfaceTintColor: Colors.white,
      shape: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      elevation: 1,
      actions: [
        if (onSearch != null)
          StatefulBuilder(
            builder: (context, setState) {
              return AnimatedCrossFade(
                firstChild: IconButton(
                  icon: const Icon(LucideIcons.search, color: Colors.grey),
                  onPressed: () {
                    setState(() => _isSearching = true);
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () => searchFocusNode.requestFocus(),
                    );
                  },
                ),
                secondChild: SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width - 100,
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(width: 1.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      prefixIcon: Icon(LucideIcons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () => setState(() {
                          _isSearching = false;
                          searchController.clear();
                          if (onSearch != null) onSearch!("");
                        }),
                      ),
                    ),
                    onSubmitted: onSearch,
                    onChanged: onSearch,
                  ),
                ),
                crossFadeState: _isSearching
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              );
            },
          ),
        if (actions != null) ...actions!,
        if (actions == null || notificationAction)
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: Colors.grey),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
      ],
      title: SizedBox(
        height: 35,
        width: 35,
        child: CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage(Assets.appLogo),
        ),
      ),
    );
  }
}
