import 'package:easy_localization/easy_localization.dart';
import 'package:stacked/stacked.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../model/outcome_measures/outcome_measure.dart';

class OutcomeMeasureInfoViewModel extends BaseViewModel {
  final OutcomeMeasure outcomeMeasure;
  OutcomeMeasureInfoViewModel({required this.outcomeMeasure});

  String getCurrentOutcomeName() {
    switch (outcomeMeasure.id) {
      case 'psfs':
        return LocaleKeys.psfs.tr();
      case 'dash':
        return LocaleKeys.dash.tr();
      case 'scs':
        return LocaleKeys.scs.tr();
      case '10mwt':
        return LocaleKeys.tenMWT.tr();
      case 'faam':
        return LocaleKeys.faam.tr();
      case 'tug':
        return LocaleKeys.tug.tr();
      case 'promispi':
        return LocaleKeys.promispi.tr();
      case 'pmq':
        return LocaleKeys.pmq.tr();
      default:
        return outcomeMeasure.name;
    }
  }
}
