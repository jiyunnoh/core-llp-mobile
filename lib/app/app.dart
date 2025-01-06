import 'package:biot/services/app_locale_service.dart';
import 'package:biot/services/tts_service.dart';
import 'package:biot/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:biot/ui/views/bottom_nav_view.dart';
import 'package:biot/ui/views/patient_detail/patient_detail_view.dart';
import 'package:biot/ui/views/patient_view_navigator.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:biot/ui/views/patient/patient_view.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:biot/services/database_service.dart';
import 'package:biot/services/shared_preferences_service.dart';
import 'package:biot/ui/dialogs/confirm_alert/confirm_alert_dialog.dart';
import 'package:biot/services/package_info_service.dart';
import 'package:biot/ui/views/summary/summary_view.dart';
import 'package:biot/services/file_service.dart';
import 'package:biot/ui/views/login/login_view.dart';
import 'package:biot/ui/views/settings/settings_view.dart';

import '../services/outcome_measure_load_service.dart';
import '../ui/views/amputation_form/amputation_form_view.dart';
import '../ui/views/settings_view_navigator.dart';
import 'package:biot/ui/views/app_description/app_description_view.dart';
import 'package:biot/services/outcome_measure_selection_service.dart';
import 'package:biot/ui/views/add_lead/add_lead_view.dart';
import 'package:biot/ui/views/add_lead_dialog/add_lead_dialog_view.dart';
import 'package:biot/ui/views/lead_form/lead_form_view.dart';
import 'package:biot/ui/views/evaluation/evaluation_view.dart';
import 'package:biot/services/pdf_service.dart';
import 'package:biot/services/file_saver_service.dart';
import 'package:biot/ui/views/pre_post/pre_post_view.dart';
import 'package:biot/ui/views/episode/episode_view.dart';
import 'package:biot/ui/views/outcome_measure_info/outcome_measure_info_view.dart';
import 'package:biot/ui/views/complete/complete_view.dart';
import 'package:biot/ui/dialogs/loading_indicator/loading_indicator_dialog.dart';
import 'package:biot/services/logger_service.dart';
import 'package:biot/ui/views/amputation/amputation_view.dart';
import 'package:biot/services/analytics_service.dart';
import 'package:biot/ui/dialogs/cancel_lead_compass/cancel_lead_compass_dialog.dart';
import 'package:biot/ui/dialogs/busy/busy_dialog.dart';
// @stacked-import

@StackedApp(routes: [
  MaterialRoute(page: LoginView),
  MaterialRoute(page: BottomNavView, children: [
    MaterialRoute(page: PatientViewNavigator, children: [
      MaterialRoute(page: PatientView),
    ]),
  ]),
  MaterialRoute(page: EvaluationView),
  MaterialRoute(page: SummaryView),
  MaterialRoute(page: SettingsViewNavigator, children: [
    MaterialRoute(page: SettingsView),
    MaterialRoute(page: AppDescriptionView),
  ]),
  MaterialRoute(page: AddLeadView),
  MaterialRoute(page: AddLeadDialogView),
  MaterialRoute(page: LeadFormView),
  MaterialRoute(page: PrePostView),
  MaterialRoute(page: EpisodeView),
  MaterialRoute(page: PatientDetailView),
  MaterialRoute(page: AmputationFormView),
  MaterialRoute(page: OutcomeMeasureInfoView, fullscreenDialog: true),
  MaterialRoute(page: CompleteView),
  MaterialRoute(page: AmputationView),
// @stacked-route
], dependencies: [
  LazySingleton(classType: BottomSheetService),
  LazySingleton(classType: DialogService),
  LazySingleton(classType: NavigationService),
  LazySingleton(classType: BiotService),
  LazySingleton(classType: DatabaseService),
  LazySingleton(classType: SharedPreferencesService),
  LazySingleton(classType: PackageInfoService),
  LazySingleton(classType: FileService),
  LazySingleton(classType: OutcomeMeasureLoadService),
  LazySingleton(classType: AppLocaleService),
  LazySingleton(classType: OutcomeMeasureSelectionService),
  LazySingleton(classType: TtsService),
  LazySingleton(classType: PdfService),
  LazySingleton(classType: FileSaverService),
  LazySingleton(classType: LoggerService),
  LazySingleton(classType: AnalyticsService),
// @stacked-service
], dialogs: [
  StackedDialog(classType: InfoAlertDialog),
  StackedDialog(classType: ConfirmAlertDialog),
  StackedDialog(classType: LoadingIndicatorDialog),
  StackedDialog(classType: CancelLeadCompassDialog),
  StackedDialog(classType: BusyDialog),
// @stacked-dialog
], logger: StackedLogger())
class App {}
