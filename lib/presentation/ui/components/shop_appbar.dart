import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shop_controller.dart';

class ShopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ShopController controller = Get.find<ShopController>();
  final title ;
  ShopAppBar({super.key, this.title = "Shop Ai"});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {

    return AppBar(
      title: Text(title),
      actions: [
        Obx(() {
          final connected = controller.isInternetConnected.value;
          // final syncing = controller.isSyncing.value;
          const syncing = false;

          return Row(
            children: [
              // 🔄 Sync Progress Spinner
              if (syncing)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  ),
                ),

              // 📶 Connectivity Icon
              Icon(
                connected ? Icons.wifi : Icons.wifi_off,
                color: connected ? Colors.green : Colors.red,
              ),

              // const BlinkingDot(),

              // "Online"/"Offline" Label
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 12),
                child: Text(
                  connected ? "Online" : "Offline",
                  style: TextStyle(
                    color: connected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
