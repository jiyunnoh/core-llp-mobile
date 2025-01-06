// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:biot/model/encounter.dart' as _i18;
import 'package:biot/model/episode_of_care.dart' as _i21;
import 'package:biot/model/patient.dart' as _i19;
import 'package:biot/model/pre_post_episode_of_care.dart' as _i20;
import 'package:biot/ui/views/add_lead/add_lead_view.dart' as _i7;
import 'package:biot/ui/views/add_lead_dialog/add_lead_dialog_view.dart' as _i8;
import 'package:biot/ui/views/amputation/amputation_view.dart' as _i16;
import 'package:biot/ui/views/amputation_form/amputation_form_view.dart'
    as _i13;
import 'package:biot/ui/views/app_description/app_description_view.dart'
    as _i25;
import 'package:biot/ui/views/bottom_nav_view.dart' as _i3;
import 'package:biot/ui/views/complete/complete_view.dart' as _i15;
import 'package:biot/ui/views/episode/episode_view.dart' as _i11;
import 'package:biot/ui/views/evaluation/evaluation_view.dart' as _i4;
import 'package:biot/ui/views/lead_form/lead_form_view.dart' as _i9;
import 'package:biot/ui/views/login/login_view.dart' as _i2;
import 'package:biot/ui/views/outcome_measure_info/outcome_measure_info_view.dart'
    as _i14;
import 'package:biot/ui/views/patient/patient_view.dart' as _i23;
import 'package:biot/ui/views/patient_detail/patient_detail_view.dart' as _i12;
import 'package:biot/ui/views/patient_view_navigator.dart' as _i22;
import 'package:biot/ui/views/pre_post/pre_post_view.dart' as _i10;
import 'package:biot/ui/views/settings/settings_view.dart' as _i24;
import 'package:biot/ui/views/settings_view_navigator.dart' as _i6;
import 'package:biot/ui/views/summary/summary_view.dart' as _i5;
import 'package:flutter/material.dart' as _i17;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i26;

class Routes {
  static const loginView = '/login-view';

  static const bottomNavView = '/bottom-nav-view';

  static const evaluationView = '/evaluation-view';

  static const summaryView = '/summary-view';

  static const settingsViewNavigator = '/settings-view-navigator';

  static const addLeadView = '/add-lead-view';

  static const addLeadDialogView = '/add-lead-dialog-view';

  static const leadFormView = '/lead-form-view';

  static const prePostView = '/pre-post-view';

  static const episodeView = '/episode-view';

  static const patientDetailView = '/patient-detail-view';

  static const amputationFormView = '/amputation-form-view';

  static const outcomeMeasureInfoView = '/outcome-measure-info-view';

  static const completeView = '/complete-view';

  static const amputationView = '/amputation-view';

  static const all = <String>{
    loginView,
    bottomNavView,
    evaluationView,
    summaryView,
    settingsViewNavigator,
    addLeadView,
    addLeadDialogView,
    leadFormView,
    prePostView,
    episodeView,
    patientDetailView,
    amputationFormView,
    outcomeMeasureInfoView,
    completeView,
    amputationView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.loginView,
      page: _i2.LoginView,
    ),
    _i1.RouteDef(
      Routes.bottomNavView,
      page: _i3.BottomNavView,
    ),
    _i1.RouteDef(
      Routes.evaluationView,
      page: _i4.EvaluationView,
    ),
    _i1.RouteDef(
      Routes.summaryView,
      page: _i5.SummaryView,
    ),
    _i1.RouteDef(
      Routes.settingsViewNavigator,
      page: _i6.SettingsViewNavigator,
    ),
    _i1.RouteDef(
      Routes.addLeadView,
      page: _i7.AddLeadView,
    ),
    _i1.RouteDef(
      Routes.addLeadDialogView,
      page: _i8.AddLeadDialogView,
    ),
    _i1.RouteDef(
      Routes.leadFormView,
      page: _i9.LeadFormView,
    ),
    _i1.RouteDef(
      Routes.prePostView,
      page: _i10.PrePostView,
    ),
    _i1.RouteDef(
      Routes.episodeView,
      page: _i11.EpisodeView,
    ),
    _i1.RouteDef(
      Routes.patientDetailView,
      page: _i12.PatientDetailView,
    ),
    _i1.RouteDef(
      Routes.amputationFormView,
      page: _i13.AmputationFormView,
    ),
    _i1.RouteDef(
      Routes.outcomeMeasureInfoView,
      page: _i14.OutcomeMeasureInfoView,
    ),
    _i1.RouteDef(
      Routes.completeView,
      page: _i15.CompleteView,
    ),
    _i1.RouteDef(
      Routes.amputationView,
      page: _i16.AmputationView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => const LoginViewArguments(),
      );
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i2.LoginView(key: args.key, isAuthCheck: args.isAuthCheck),
        settings: data,
      );
    },
    _i3.BottomNavView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.BottomNavView(),
        settings: data,
      );
    },
    _i4.EvaluationView: (data) {
      final args = data.getArgs<EvaluationViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.EvaluationView(args.encounter, key: args.key),
        settings: data,
      );
    },
    _i5.SummaryView: (data) {
      final args = data.getArgs<SummaryViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.SummaryView(args.encounter,
            key: args.key, isNewAdded: args.isNewAdded),
        settings: data,
      );
    },
    _i6.SettingsViewNavigator: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.SettingsViewNavigator(),
        settings: data,
      );
    },
    _i7.AddLeadView: (data) {
      final args = data.getArgs<AddLeadViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.AddLeadView(args.onClickedDone,
            key: args.key, isEdit: args.isEdit, patient: args.patient),
        settings: data,
      );
    },
    _i8.AddLeadDialogView: (data) {
      final args = data.getArgs<AddLeadDialogViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.AddLeadDialogView(args.onClickedDone,
            key: args.key, isEdit: args.isEdit, patient: args.patient),
        settings: data,
      );
    },
    _i9.LeadFormView: (data) {
      final args = data.getArgs<LeadFormViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i9.LeadFormView(args.onClickedDone,
            key: args.key, isEdit: args.isEdit, patient: args.patient),
        settings: data,
      );
    },
    _i10.PrePostView: (data) {
      final args = data.getArgs<PrePostViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i10.PrePostView(args.encounter,
            key: args.key, isEdit: args.isEdit, onUpdate: args.onUpdate),
        settings: data,
      );
    },
    _i11.EpisodeView: (data) {
      final args = data.getArgs<EpisodeViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i11.EpisodeView(args.encounter,
            key: args.key, isEdit: args.isEdit, onUpdate: args.onUpdate),
        settings: data,
      );
    },
    _i12.PatientDetailView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.PatientDetailView(),
        settings: data,
      );
    },
    _i13.AmputationFormView: (data) {
      final args = data.getArgs<AmputationFormViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i13.AmputationFormView(
            key: args.key,
            encounter: args.encounter,
            isEdit: args.isEdit,
            shouldUpdateCloud: args.shouldUpdateCloud),
        settings: data,
      );
    },
    _i14.OutcomeMeasureInfoView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.OutcomeMeasureInfoView(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    _i15.CompleteView: (data) {
      final args = data.getArgs<CompleteViewArguments>(nullOk: false);
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i15.CompleteView(args.encounter,
            key: args.key, pdfPath: args.pdfPath),
        settings: data,
      );
    },
    _i16.AmputationView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.AmputationView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class LoginViewArguments {
  const LoginViewArguments({
    this.key,
    this.isAuthCheck = false,
  });

  final _i17.Key? key;

  final bool isAuthCheck;

  @override
  String toString() {
    return '{"key": "$key", "isAuthCheck": "$isAuthCheck"}';
  }

  @override
  bool operator ==(covariant LoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.isAuthCheck == isAuthCheck;
  }

  @override
  int get hashCode {
    return key.hashCode ^ isAuthCheck.hashCode;
  }
}

class EvaluationViewArguments {
  const EvaluationViewArguments({
    required this.encounter,
    this.key,
  });

  final _i18.Encounter encounter;

  final _i17.Key? key;

  @override
  String toString() {
    return '{"encounter": "$encounter", "key": "$key"}';
  }

  @override
  bool operator ==(covariant EvaluationViewArguments other) {
    if (identical(this, other)) return true;
    return other.encounter == encounter && other.key == key;
  }

  @override
  int get hashCode {
    return encounter.hashCode ^ key.hashCode;
  }
}

class SummaryViewArguments {
  const SummaryViewArguments({
    required this.encounter,
    this.key,
    required this.isNewAdded,
  });

  final _i18.Encounter encounter;

  final _i17.Key? key;

  final bool isNewAdded;

  @override
  String toString() {
    return '{"encounter": "$encounter", "key": "$key", "isNewAdded": "$isNewAdded"}';
  }

  @override
  bool operator ==(covariant SummaryViewArguments other) {
    if (identical(this, other)) return true;
    return other.encounter == encounter &&
        other.key == key &&
        other.isNewAdded == isNewAdded;
  }

  @override
  int get hashCode {
    return encounter.hashCode ^ key.hashCode ^ isNewAdded.hashCode;
  }
}

class AddLeadViewArguments {
  const AddLeadViewArguments({
    required this.onClickedDone,
    this.key,
    this.isEdit = false,
    this.patient,
  });

  final dynamic Function(_i19.Patient) onClickedDone;

  final _i17.Key? key;

  final bool isEdit;

  final _i19.Patient? patient;

  @override
  String toString() {
    return '{"onClickedDone": "$onClickedDone", "key": "$key", "isEdit": "$isEdit", "patient": "$patient"}';
  }

  @override
  bool operator ==(covariant AddLeadViewArguments other) {
    if (identical(this, other)) return true;
    return other.onClickedDone == onClickedDone &&
        other.key == key &&
        other.isEdit == isEdit &&
        other.patient == patient;
  }

  @override
  int get hashCode {
    return onClickedDone.hashCode ^
        key.hashCode ^
        isEdit.hashCode ^
        patient.hashCode;
  }
}

class AddLeadDialogViewArguments {
  const AddLeadDialogViewArguments({
    required this.onClickedDone,
    this.key,
    this.isEdit = false,
    this.patient,
  });

  final dynamic Function(_i19.Patient) onClickedDone;

  final _i17.Key? key;

  final bool isEdit;

  final _i19.Patient? patient;

  @override
  String toString() {
    return '{"onClickedDone": "$onClickedDone", "key": "$key", "isEdit": "$isEdit", "patient": "$patient"}';
  }

  @override
  bool operator ==(covariant AddLeadDialogViewArguments other) {
    if (identical(this, other)) return true;
    return other.onClickedDone == onClickedDone &&
        other.key == key &&
        other.isEdit == isEdit &&
        other.patient == patient;
  }

  @override
  int get hashCode {
    return onClickedDone.hashCode ^
        key.hashCode ^
        isEdit.hashCode ^
        patient.hashCode;
  }
}

class LeadFormViewArguments {
  const LeadFormViewArguments({
    required this.onClickedDone,
    this.key,
    this.isEdit = false,
    this.patient,
  });

  final dynamic Function(_i19.Patient) onClickedDone;

  final _i17.Key? key;

  final bool isEdit;

  final _i19.Patient? patient;

  @override
  String toString() {
    return '{"onClickedDone": "$onClickedDone", "key": "$key", "isEdit": "$isEdit", "patient": "$patient"}';
  }

  @override
  bool operator ==(covariant LeadFormViewArguments other) {
    if (identical(this, other)) return true;
    return other.onClickedDone == onClickedDone &&
        other.key == key &&
        other.isEdit == isEdit &&
        other.patient == patient;
  }

  @override
  int get hashCode {
    return onClickedDone.hashCode ^
        key.hashCode ^
        isEdit.hashCode ^
        patient.hashCode;
  }
}

class PrePostViewArguments {
  const PrePostViewArguments({
    required this.encounter,
    this.key,
    required this.isEdit,
    this.onUpdate,
  });

  final _i18.Encounter encounter;

  final _i17.Key? key;

  final bool isEdit;

  final dynamic Function(_i20.PrePostEpisodeOfCare)? onUpdate;

  @override
  String toString() {
    return '{"encounter": "$encounter", "key": "$key", "isEdit": "$isEdit", "onUpdate": "$onUpdate"}';
  }

  @override
  bool operator ==(covariant PrePostViewArguments other) {
    if (identical(this, other)) return true;
    return other.encounter == encounter &&
        other.key == key &&
        other.isEdit == isEdit &&
        other.onUpdate == onUpdate;
  }

  @override
  int get hashCode {
    return encounter.hashCode ^
        key.hashCode ^
        isEdit.hashCode ^
        onUpdate.hashCode;
  }
}

class EpisodeViewArguments {
  const EpisodeViewArguments({
    required this.encounter,
    this.key,
    required this.isEdit,
    this.onUpdate,
  });

  final _i18.Encounter encounter;

  final _i17.Key? key;

  final bool isEdit;

  final dynamic Function(_i21.EpisodeOfCare)? onUpdate;

  @override
  String toString() {
    return '{"encounter": "$encounter", "key": "$key", "isEdit": "$isEdit", "onUpdate": "$onUpdate"}';
  }

  @override
  bool operator ==(covariant EpisodeViewArguments other) {
    if (identical(this, other)) return true;
    return other.encounter == encounter &&
        other.key == key &&
        other.isEdit == isEdit &&
        other.onUpdate == onUpdate;
  }

  @override
  int get hashCode {
    return encounter.hashCode ^
        key.hashCode ^
        isEdit.hashCode ^
        onUpdate.hashCode;
  }
}

class AmputationFormViewArguments {
  const AmputationFormViewArguments({
    this.key,
    this.encounter,
    required this.isEdit,
    this.shouldUpdateCloud = false,
  });

  final _i17.Key? key;

  final _i18.Encounter? encounter;

  final bool isEdit;

  final bool shouldUpdateCloud;

  @override
  String toString() {
    return '{"key": "$key", "encounter": "$encounter", "isEdit": "$isEdit", "shouldUpdateCloud": "$shouldUpdateCloud"}';
  }

  @override
  bool operator ==(covariant AmputationFormViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.encounter == encounter &&
        other.isEdit == isEdit &&
        other.shouldUpdateCloud == shouldUpdateCloud;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        encounter.hashCode ^
        isEdit.hashCode ^
        shouldUpdateCloud.hashCode;
  }
}

class CompleteViewArguments {
  const CompleteViewArguments({
    required this.encounter,
    this.key,
    this.pdfPath,
  });

  final _i18.Encounter encounter;

  final _i17.Key? key;

  final String? pdfPath;

  @override
  String toString() {
    return '{"encounter": "$encounter", "key": "$key", "pdfPath": "$pdfPath"}';
  }

  @override
  bool operator ==(covariant CompleteViewArguments other) {
    if (identical(this, other)) return true;
    return other.encounter == encounter &&
        other.key == key &&
        other.pdfPath == pdfPath;
  }

  @override
  int get hashCode {
    return encounter.hashCode ^ key.hashCode ^ pdfPath.hashCode;
  }
}

class BottomNavViewRoutes {
  static const patientViewNavigator = 'patient-view-navigator';

  static const all = <String>{patientViewNavigator};
}

class BottomNavViewRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      BottomNavViewRoutes.patientViewNavigator,
      page: _i22.PatientViewNavigator,
    )
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i22.PatientViewNavigator: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i22.PatientViewNavigator(),
        settings: data,
      );
    }
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class PatientViewNavigatorRoutes {
  static const patientView = 'patient-view';

  static const all = <String>{patientView};
}

class PatientViewNavigatorRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      PatientViewNavigatorRoutes.patientView,
      page: _i23.PatientView,
    )
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i23.PatientView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i23.PatientView(),
        settings: data,
      );
    }
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class SettingsViewNavigatorRoutes {
  static const settingsView = 'settings-view';

  static const appDescriptionView = 'app-description-view';

  static const all = <String>{
    settingsView,
    appDescriptionView,
  };
}

class SettingsViewNavigatorRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      SettingsViewNavigatorRoutes.settingsView,
      page: _i24.SettingsView,
    ),
    _i1.RouteDef(
      SettingsViewNavigatorRoutes.appDescriptionView,
      page: _i25.AppDescriptionView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i24.SettingsView: (data) {
      final args = data.getArgs<NestedSettingsViewArguments>(
        orElse: () => const NestedSettingsViewArguments(),
      );
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i24.SettingsView(key: args.key, isBeforeLogin: args.isBeforeLogin),
        settings: data,
      );
    },
    _i25.AppDescriptionView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i25.AppDescriptionView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class NestedSettingsViewArguments {
  const NestedSettingsViewArguments({
    this.key,
    this.isBeforeLogin = false,
  });

  final _i17.Key? key;

  final bool isBeforeLogin;

  @override
  String toString() {
    return '{"key": "$key", "isBeforeLogin": "$isBeforeLogin"}';
  }

  @override
  bool operator ==(covariant NestedSettingsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.isBeforeLogin == isBeforeLogin;
  }

  @override
  int get hashCode {
    return key.hashCode ^ isBeforeLogin.hashCode;
  }
}

extension NavigatorStateExtension on _i26.NavigationService {
  Future<dynamic> navigateToLoginView({
    _i17.Key? key,
    bool isAuthCheck = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key, isAuthCheck: isAuthCheck),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToBottomNavView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.bottomNavView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToEvaluationView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.evaluationView,
        arguments: EvaluationViewArguments(encounter: encounter, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSummaryView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    required bool isNewAdded,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.summaryView,
        arguments: SummaryViewArguments(
            encounter: encounter, key: key, isNewAdded: isNewAdded),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSettingsViewNavigator([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.settingsViewNavigator,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAddLeadView({
    required dynamic Function(_i19.Patient) onClickedDone,
    _i17.Key? key,
    bool isEdit = false,
    _i19.Patient? patient,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.addLeadView,
        arguments: AddLeadViewArguments(
            onClickedDone: onClickedDone,
            key: key,
            isEdit: isEdit,
            patient: patient),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAddLeadDialogView({
    required dynamic Function(_i19.Patient) onClickedDone,
    _i17.Key? key,
    bool isEdit = false,
    _i19.Patient? patient,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.addLeadDialogView,
        arguments: AddLeadDialogViewArguments(
            onClickedDone: onClickedDone,
            key: key,
            isEdit: isEdit,
            patient: patient),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLeadFormView({
    required dynamic Function(_i19.Patient) onClickedDone,
    _i17.Key? key,
    bool isEdit = false,
    _i19.Patient? patient,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.leadFormView,
        arguments: LeadFormViewArguments(
            onClickedDone: onClickedDone,
            key: key,
            isEdit: isEdit,
            patient: patient),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPrePostView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    required bool isEdit,
    dynamic Function(_i20.PrePostEpisodeOfCare)? onUpdate,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.prePostView,
        arguments: PrePostViewArguments(
            encounter: encounter, key: key, isEdit: isEdit, onUpdate: onUpdate),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToEpisodeView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    required bool isEdit,
    dynamic Function(_i21.EpisodeOfCare)? onUpdate,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.episodeView,
        arguments: EpisodeViewArguments(
            encounter: encounter, key: key, isEdit: isEdit, onUpdate: onUpdate),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPatientDetailView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.patientDetailView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAmputationFormView({
    _i17.Key? key,
    _i18.Encounter? encounter,
    required bool isEdit,
    bool shouldUpdateCloud = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.amputationFormView,
        arguments: AmputationFormViewArguments(
            key: key,
            encounter: encounter,
            isEdit: isEdit,
            shouldUpdateCloud: shouldUpdateCloud),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOutcomeMeasureInfoView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.outcomeMeasureInfoView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCompleteView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    String? pdfPath,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.completeView,
        arguments: CompleteViewArguments(
            encounter: encounter, key: key, pdfPath: pdfPath),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAmputationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.amputationView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPatientViewNavigator([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(BottomNavViewRoutes.patientViewNavigator,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToNestedPatientViewInPatientViewNavigatorRouter([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(PatientViewNavigatorRoutes.patientView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToNestedSettingsViewInSettingsViewNavigatorRouter({
    _i17.Key? key,
    bool isBeforeLogin = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(SettingsViewNavigatorRoutes.settingsView,
        arguments:
            NestedSettingsViewArguments(key: key, isBeforeLogin: isBeforeLogin),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic>
      navigateToNestedAppDescriptionViewInSettingsViewNavigatorRouter([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(SettingsViewNavigatorRoutes.appDescriptionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView({
    _i17.Key? key,
    bool isAuthCheck = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key, isAuthCheck: isAuthCheck),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithBottomNavView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.bottomNavView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithEvaluationView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.evaluationView,
        arguments: EvaluationViewArguments(encounter: encounter, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSummaryView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    required bool isNewAdded,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.summaryView,
        arguments: SummaryViewArguments(
            encounter: encounter, key: key, isNewAdded: isNewAdded),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSettingsViewNavigator([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.settingsViewNavigator,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAddLeadView({
    required dynamic Function(_i19.Patient) onClickedDone,
    _i17.Key? key,
    bool isEdit = false,
    _i19.Patient? patient,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.addLeadView,
        arguments: AddLeadViewArguments(
            onClickedDone: onClickedDone,
            key: key,
            isEdit: isEdit,
            patient: patient),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAddLeadDialogView({
    required dynamic Function(_i19.Patient) onClickedDone,
    _i17.Key? key,
    bool isEdit = false,
    _i19.Patient? patient,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.addLeadDialogView,
        arguments: AddLeadDialogViewArguments(
            onClickedDone: onClickedDone,
            key: key,
            isEdit: isEdit,
            patient: patient),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLeadFormView({
    required dynamic Function(_i19.Patient) onClickedDone,
    _i17.Key? key,
    bool isEdit = false,
    _i19.Patient? patient,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.leadFormView,
        arguments: LeadFormViewArguments(
            onClickedDone: onClickedDone,
            key: key,
            isEdit: isEdit,
            patient: patient),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPrePostView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    required bool isEdit,
    dynamic Function(_i20.PrePostEpisodeOfCare)? onUpdate,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.prePostView,
        arguments: PrePostViewArguments(
            encounter: encounter, key: key, isEdit: isEdit, onUpdate: onUpdate),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithEpisodeView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    required bool isEdit,
    dynamic Function(_i21.EpisodeOfCare)? onUpdate,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.episodeView,
        arguments: EpisodeViewArguments(
            encounter: encounter, key: key, isEdit: isEdit, onUpdate: onUpdate),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPatientDetailView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.patientDetailView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAmputationFormView({
    _i17.Key? key,
    _i18.Encounter? encounter,
    required bool isEdit,
    bool shouldUpdateCloud = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.amputationFormView,
        arguments: AmputationFormViewArguments(
            key: key,
            encounter: encounter,
            isEdit: isEdit,
            shouldUpdateCloud: shouldUpdateCloud),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOutcomeMeasureInfoView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.outcomeMeasureInfoView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCompleteView({
    required _i18.Encounter encounter,
    _i17.Key? key,
    String? pdfPath,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.completeView,
        arguments: CompleteViewArguments(
            encounter: encounter, key: key, pdfPath: pdfPath),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAmputationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.amputationView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPatientViewNavigator([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(BottomNavViewRoutes.patientViewNavigator,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithNestedPatientViewInPatientViewNavigatorRouter([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(PatientViewNavigatorRoutes.patientView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithNestedSettingsViewInSettingsViewNavigatorRouter({
    _i17.Key? key,
    bool isBeforeLogin = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(SettingsViewNavigatorRoutes.settingsView,
        arguments:
            NestedSettingsViewArguments(key: key, isBeforeLogin: isBeforeLogin),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic>
      replaceWithNestedAppDescriptionViewInSettingsViewNavigatorRouter([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(SettingsViewNavigatorRoutes.appDescriptionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
