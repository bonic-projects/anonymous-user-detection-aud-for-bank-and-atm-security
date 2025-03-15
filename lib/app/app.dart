import 'package:aud_for_bank/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:aud_for_bank/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:aud_for_bank/ui/views/home/home_view.dart';
import 'package:aud_for_bank/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:aud_for_bank/services/vediostream_service.dart';
import 'package:aud_for_bank/services/notification_service.dart';
import 'package:aud_for_bank/ui/views/notification/notification_view.dart';
import 'package:aud_for_bank/services/database_service.dart';

import '../ui/views/notification/notification_view_arguments.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(
      page: NotificationView,
      path: '/notification-view',
      // Specify that it takes arguments
      // arguments: NotificationViewArguments,
    ),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: VediostreamService),
    LazySingleton(classType: NotificationService),
    LazySingleton(classType: DatabaseService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
