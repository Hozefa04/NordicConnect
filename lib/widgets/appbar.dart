import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_methods.dart';
import '../utils/app_strings.dart';

class HomeAppBar extends StatelessWidget with PreferredSizeWidget {
  final bool hasTabs;

  HomeAppBar({Key? key, this.hasTabs = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        AppStrings.appName,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  AppMethods.getProfileUrl() ?? AppStrings.defaultProfileUrl),
              backgroundColor: Colors.transparent,
              radius: 16,
            ),
          ),
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.transparent,
      bottom: hasTabs
          ? TabBar(
              indicatorColor: AppColors.primaryColor,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.createTab,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_view_day_rounded,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.viewTab,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
    );
  }

  @override
  Size get preferredSize => hasTabs
      ? const Size.fromHeight(kToolbarHeight) * 2
      : const Size.fromHeight(kToolbarHeight);
}
