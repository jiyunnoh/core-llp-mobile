import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../app/app.dialogs.dart';
import '../../app/app.locator.dart';
import '../../constants/compass_lead_enum.dart';
import '../../constants/compass_lead_info.dart';
import '../../model/episode_of_care.dart';
import '../common/app_colors.dart';
import '../common/ui_helpers.dart';

class Page1 extends StatefulWidget {
  final dialogService = locator<DialogService>();

  final EpisodeOfCare episodeOfCare;
  final bool isEdit;
  final Function(EpisodeOfCare)? onChange;

  bool isModified = false;

  final List<Widget> units = <Widget>[
    const Text('Metric'),
    const Text('Imperial')
  ];

  Page1(
      {super.key,
      required this.episodeOfCare,
      required this.isEdit,
      this.onChange});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final List<bool> _selectedUnits = <bool>[true, false];

  List<bool> professions = List.filled(Profession.values.length, false);
  List<bool> rehabilitationServices =
      List.filled(RehabilitationServices.values.length, false);
  List<bool> compressionTherapies =
      List.filled(CompressionTherapy.values.length, false);

  TextEditingController icdCodeController = TextEditingController();
  TextEditingController ctOtherController = TextEditingController();
  TextEditingController cmController = TextEditingController();
  TextEditingController ftController = TextEditingController();
  TextEditingController inchController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  FocusNode cmFocusNode = FocusNode();
  FocusNode ftFocusNode = FocusNode();
  FocusNode inchFocusNode = FocusNode();
  FocusNode weightFocusNode = FocusNode();

  // Always in kg
  double _weight = -1;

  double get weight => isMetric ? _weight : kgToLbs(_weight);

  set weight(double value) {
    isMetric ? _weight = value : _weight = lbsToKg(value);
  }

  double get convertedHeight {
    if (isMetric) {
      heightInCm = convertToCm(heightInScaleDownedFt);
      return heightInCm;
    } else {
      heightInScaleDownedFt = cmToInch(heightInCm) / 12;
      return heightInScaleDownedFt;
    }
  }

  double heightInCm = -1;

  late double heightInScaleDownedFt;

  static const double inchesPerFoot = 12.0;

  static const double cmPerInch = 2.54;

  static const double lbsPerKg = 2.20462;

  bool isMetric = true;

  @override
  void initState() {
    super.initState();
    cmFocusNode.addListener(onCmFocusChange);
    ftFocusNode.addListener(onFtFocusChange);
    inchFocusNode.addListener(onInchFocusChange);
    weightFocusNode.addListener(onWeightFocusChange);
    if (widget.episodeOfCare.height != null) {
      heightInCm = widget.episodeOfCare.height!;
      updateHeightTextControllers(heightInCm);
    } else {
      widget.episodeOfCare.height = heightInCm;
    }
    if (widget.episodeOfCare.weight != null) {
      weight = widget.episodeOfCare.weight!;
      updateWeightTextController(weight);
    } else {
      widget.episodeOfCare.weight = weight;
    }

      icdCodeController.text = widget.episodeOfCare.icdCodesOfConditions;

    ctOtherController.text = widget.episodeOfCare.ctOther;

    for (Profession elem in widget.episodeOfCare.professionsInvolved) {
      professions[elem.index] = true;
    }

    for (RehabilitationServices elem
        in widget.episodeOfCare.rehabilitationServices) {
      rehabilitationServices[elem.index] = true;
    }

    for (CompressionTherapy elem in widget.episodeOfCare.compressionTherapies) {
      compressionTherapies[elem.index] = true;
    }
  }

  void onCmFocusChange() {
    if (cmFocusNode.hasFocus == false) {
      setState(() {
        onCmTextControllerEditingComplete();
      });
    }
  }

  void onFtFocusChange() {
    if (ftFocusNode.hasFocus == false) {
      setState(() {
        onFtInTextControllerEditingComplete();
      });
    }
  }

  void onInchFocusChange() {
    if (inchFocusNode.hasFocus == false) {
      setState(() {
        onFtInTextControllerEditingComplete();
      });
    }
  }

  void onWeightFocusChange() {
    if (weightFocusNode.hasFocus == false) {
      setState(() {
        onWeightEditingComplete();
      });
    }
  }

  double kgToLbs(double kg) {
    return kg < 0 ? -1 : kg * lbsPerKg;
  }

  double lbsToKg(double lbs) {
    return lbs < 0 ? -1 : lbs * (1 / lbsPerKg);
  }

  double cmToInch(double cm) {
    return cm < 0 ? -1 : cm / cmPerInch;
  }

  double convertToCm(double heightInScaleDownedFt) {
    if (heightInScaleDownedFt < 0) {
      return -1;
    } else {
      int truncatedNum = heightInScaleDownedFt.truncate();
      double fractionNum = heightInScaleDownedFt - truncatedNum;

      double inch =
          (truncatedNum * inchesPerFoot) + (fractionNum * inchesPerFoot);
      return inch * cmPerInch;
    }
  }

  (String, String) convertToNormalFt(double scaleDownedFtIn) {
    if (scaleDownedFtIn < 0) {
      return ("-1", "");
    } else {
      int truncatedNum = scaleDownedFtIn.truncate();
      double fractionNum = scaleDownedFtIn - truncatedNum;
      String inch = (fractionNum * inchesPerFoot).toStringAsFixed(0);
      return ("$truncatedNum", inch);
    }
  }

  double convertToScaleDownedFt(int feet, int inches) {
    double totalInches = feet * inchesPerFoot + inches;
    return totalInches / inchesPerFoot;
  }

  void updateHeightTextControllers(double height) {
    if (isMetric) {
      if (height >= 0) {
        cmController.text = height.toStringAsFixed(0);
      } else {
        cmController.clear();
      }
    } else {
      var (ft, inch) = convertToNormalFt(height);
      if (height >= 0) {
        ftController.text = ft;
        inchController.text = inch;
      } else {
        ftController.clear();
        inchController.clear();
      }
    }
  }

  void onFtInTextControllerEditingComplete() {
    FocusManager.instance.primaryFocus?.unfocus();

    double height = convertImperialHeightText();

    heightInCm = convertToCm(height);

    widget.episodeOfCare.height = heightInCm;

    if (widget.isEdit) {
      widget.onChange!(widget.episodeOfCare);
    }

    setState(() {
      updateHeightTextControllers(height);
    });
  }

  void onCmTextControllerEditingComplete() {
    FocusManager.instance.primaryFocus?.unfocus();

    double height = convertMetricHeightText();

    widget.episodeOfCare.height = height;

    if (widget.isEdit) {
      widget.onChange!(widget.episodeOfCare);
    }

    setState(() {
      updateHeightTextControllers(height);
    });
  }

  void onHeightMarkerChange(double value) {
    setState(() {
      if (isMetric) {
        heightInCm = value;
      } else {
        heightInScaleDownedFt = value;
        heightInCm = convertToCm(heightInScaleDownedFt);
      }

      updateHeightTextControllers(value);

      widget.episodeOfCare.height = heightInCm;

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  double convertImperialHeightText() {
    if (ftController.text.isNotEmpty && inchController.text.isNotEmpty) {
      heightInScaleDownedFt = convertToScaleDownedFt(
          int.parse(ftController.text), int.parse(inchController.text));
      if (ftController.text == '0' && inchController.text == '0') {
        heightInScaleDownedFt = -1;
      }
    } else if (ftController.text.isEmpty) {
      heightInScaleDownedFt =
          convertToScaleDownedFt(0, int.parse(inchController.text));
      if (inchController.text == '0') {
        heightInScaleDownedFt = -1;
      }
    } else if (inchController.text.isEmpty) {
      heightInScaleDownedFt =
          convertToScaleDownedFt(int.parse(ftController.text), 0);
      if (ftController.text == '0') {
        heightInScaleDownedFt = -1;
      }
    } else {
      heightInScaleDownedFt = -1;
    }

    return heightInScaleDownedFt;
  }

  double convertMetricHeightText() {
    if (cmController.text.isNotEmpty) {
      heightInCm = double.parse(cmController.text);
      if (cmController.text == '0') {
        heightInCm = -1;
      }
    } else {
      heightInCm = -1;
    }

    return heightInCm;
  }

  void updateWeightTextController(double weight) {
    if (weight >= 0) {
      weightController.text = weight.toStringAsFixed(0);
    } else {
      weightController.clear();
    }
  }

  void onWeightMarkerChange(double value) {
    setState(() {
      weight = value;

      updateWeightTextController(weight);

      widget.episodeOfCare.weight = _weight;

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  void onWeightEditingComplete() {
    FocusManager.instance.primaryFocus?.unfocus();

    weight = convertWeightControllerToValue();

    widget.episodeOfCare.weight = _weight;

    if (widget.isEdit) {
      widget.onChange!(widget.episodeOfCare);
    }

    setState(() {
      updateWeightTextController(weight);
    });
  }

  double convertWeightControllerToValue() {
    if (weightController.text.isNotEmpty) {
      weight = double.parse(weightController.text);
      if (weightController.text == '0') {
        weight = -1;
      }
    } else {
      weight = -1;
    }

    return weight;
  }

  String _buildWeightMarkerText() {
    return weight < 0 ? '' : weight.toStringAsFixed(0);
  }

  String _buildHeightMarkerText() {
    if (isMetric) {
      return heightInCm < 0 ? '' : heightInCm.toStringAsFixed(0);
    } else {
      var (ft, inch) = convertToNormalFt(heightInScaleDownedFt);
      return ft == '-1' ? '' : "$ft' $inch\"";
    }
  }

  Widget _buildBodyMeasurements() {
    return Column(
      children: [
        ToggleButtons(
          onPressed: (int index) {
            setState(() {
              for (int i = 0; i < _selectedUnits.length; i++) {
                _selectedUnits[i] = i == index;
              }

              isMetric = index == 0 ? true : false;

              updateHeightTextControllers(convertedHeight);
              updateWeightTextController(weight);
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          selectedBorderColor: Colors.black,
          selectedColor: Colors.black,
          fillColor: Colors.black12,
          color: Colors.black54,
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          ),
          isSelected: _selectedUnits,
          children: widget.units,
        ),
        _buildHeightInput(),
        _buildWeightInput(),
      ],
    );
  }

  Widget _buildCompressionTherapy() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 38,
              ),
              Text(
                'Compression Therapy',
                style: episodeHeaderTextStyle,
              ),
            ],
          ),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: CompressionTherapy.values.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => onTapCT(index),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 38,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CompressionTherapy.values[index].displayName,
                            style: episodeOptionsTextStyle,
                          ),
                          Checkbox(
                              key: Key('ct_$index'),
                              value: compressionTherapies[index],
                              onChanged: (bool? value) => onTapCT(index))
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              indent: 38,
              height: 0,
            ),
          ),
          if (compressionTherapies[CompressionTherapy.other.index])
            Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: TextField(
                    key: const Key('ct_other'),
                    controller: ctOtherController,
                    onChanged: (String value) {
                      setState(() {
                        widget.episodeOfCare.ctOther = value;

                        if (widget.isEdit) {
                          widget.onChange!(widget.episodeOfCare);
                        }
                      });
                    },
                    onTapOutside: ((event) {
                      FocusScope.of(context).unfocus();
                    }),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.deny(RegExp("[,]")),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Please specify',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  void onTapCT(int index) {
    setState(() {
      compressionTherapies[index] = !compressionTherapies[index];

      if (!compressionTherapies[index] &&
          CompressionTherapy.values[index] == CompressionTherapy.other) {
        // reset model
        widget.episodeOfCare.ctOther = '';

        // reset UI
        ctOtherController.clear();
      }

      widget.episodeOfCare.compressionTherapies = compressionTherapies
          .asMap()
          .entries
          .where((element) => element.value)
          .map((e) => CompressionTherapy.values[e.key])
          .toList();

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  Widget _buildRehabServices() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Rehabilitation Services',
                      data: sectionI),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Please select any rehabilitation interventions received in this episode of care.',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: RehabilitationServices.values.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => onTapRehabServices(index),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 38,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            RehabilitationServices.values[index].displayName,
                            style: episodeOptionsTextStyle,
                          ),
                          Checkbox(
                              key: Key('rehabService_$index'),
                              value: rehabilitationServices[index],
                              onChanged: (bool? value) =>
                                  onTapRehabServices(index))
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              indent: 38,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }

  void onTapRehabServices(int index) {
    setState(() {
      rehabilitationServices[index] = !rehabilitationServices[index];

      // if compressionTherapy is unselected, reset follow up questions.
      if (!rehabilitationServices[index] &&
          RehabilitationServices.values[index] ==
              RehabilitationServices.compressionTherapy) {
        // reset model
        widget.episodeOfCare.compressionTherapies = [];
        widget.episodeOfCare.ctOther = '';

        // reset UI
        for (int i = 0; i < compressionTherapies.length; i++) {
          compressionTherapies[i] = false;
        }
        ctOtherController.clear();
      }

      widget.episodeOfCare.rehabilitationServices = rehabilitationServices
          .asMap()
          .entries
          .where((element) => element.value)
          .map((e) => RehabilitationServices.values[e.key])
          .toList();

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  Widget _buildMorbidities() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('icdCodes_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Morbidities/Conditions (from ICD)',
                      data: sectionQ),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                  child: Text(
                'ICD Codes of health conditions',
                style: episodeHeaderTextStyle,
              )),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 38,
              ),
              Expanded(
                child: TextField(
                  key: const Key('icdCodesOfConditions'),
                  controller: icdCodeController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z .,]")),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onChanged: (String value) {
                    setState(() {
                      widget.episodeOfCare.icdCodesOfConditions =
                          value.toUpperCase();

                      if (widget.isEdit) {
                        widget.onChange!(widget.episodeOfCare);
                      }
                    });
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeightInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('weight_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Body Measurements',
                      data: sectionP_2),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                  child: Text(
                'Weight',
                style: episodeHeaderTextStyle,
              )),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      key: const Key('weight_text'),
                      focusNode: weightFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3)
                      ],
                      onEditingComplete: () => onWeightEditingComplete(),
                      controller: weightController,
                      onTapOutside: (event) => onWeightEditingComplete(),
                      decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder()),
                    ),
                  ),
                  horizontalSpaceTiny,
                  Text(
                    isMetric ? 'kg' : 'lbs',
                    style: episodeHeaderTextStyle,
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 24,
              ),
              Expanded(
                child: SfLinearGauge(
                    markerPointers: [
                      LinearWidgetPointer(
                          key: const Key('weight_pointer'),
                          enableAnimation: false,
                          value: weight,
                          markerAlignment: LinearMarkerAlignment.center,
                          onChanged: onWeightMarkerChange,
                          child: Container(
                            width: 37,
                            height: 37,
                            decoration: BoxDecoration(
                              color: weight < 0 ? Colors.grey : kcBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(
                                        0, 1) // changes position of shadow
                                    ),
                              ],
                            ),
                            child: Center(
                              child: Text(_buildWeightMarkerText(),
                                  key: const Key('weightMarkerText'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  )),
                            ),
                          ))
                    ],
                    minimum: isMetric ? 30.0 : 60.0,
                    maximum: isMetric ? 150.0 : 320.0,
                    orientation: LinearGaugeOrientation.horizontal,
                    axisTrackStyle: const LinearAxisTrackStyle(
                        thickness: 15, edgeStyle: LinearEdgeStyle.bothFlat)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeightInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4),
                      child: IconButton(
                        key: const Key('height_info'),
                        onPressed: () => widget.dialogService.showCustomDialog(
                            barrierDismissible: true,
                            variant: DialogType.infoAlert,
                            title: 'Body measurements',
                            data: sectionP_1),
                        icon: const Icon(Icons.info_outline),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Expanded(
                        child: Text(
                      'Height',
                      style: episodeHeaderTextStyle,
                    )),
                    isMetric
                        ? Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  key: const Key('cm_text'),
                                  focusNode: cmFocusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3)
                                  ],
                                  onEditingComplete: () =>
                                      onCmTextControllerEditingComplete(),
                                  controller: cmController,
                                  onTapOutside: (event) =>
                                      onCmTextControllerEditingComplete(),
                                  decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(8),
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              horizontalSpaceTiny,
                              Text(
                                'cm',
                                style: episodeHeaderTextStyle,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  key: const Key('ft_text'),
                                  focusNode: ftFocusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1)
                                  ],
                                  onEditingComplete: () =>
                                      onFtInTextControllerEditingComplete(),
                                  controller: ftController,
                                  onTapOutside: (event) =>
                                      onFtInTextControllerEditingComplete(),
                                  decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(8),
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              horizontalSpaceTiny,
                              Text(
                                'ft',
                                style: episodeHeaderTextStyle,
                              ),
                              horizontalSpaceSmall,
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  key: const Key('inch_text'),
                                  focusNode: inchFocusNode,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: false),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                          r'^(1[0-2]?|\d)$'), // Allows digits from 0 to 11
                                    ),
                                  ],
                                  onEditingComplete: () =>
                                      onFtInTextControllerEditingComplete(),
                                  controller: inchController,
                                  onTapOutside: (event) =>
                                      onFtInTextControllerEditingComplete(),
                                  decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(8),
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              horizontalSpaceTiny,
                              Text(
                                'in',
                                style: episodeHeaderTextStyle,
                              ),
                            ],
                          )
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 24,
              ),
              Expanded(
                child: SfLinearGauge(
                    markerPointers: [
                      LinearWidgetPointer(
                        key: const Key('height_pointer'),
                          enableAnimation: false,
                          value: isMetric ? heightInCm : heightInScaleDownedFt,
                          markerAlignment: LinearMarkerAlignment.center,
                          onChanged: onHeightMarkerChange,
                          child: Container(
                            width: 37,
                            height: 37,
                            decoration: BoxDecoration(
                              color: isMetric
                                  ? heightInCm < 0
                                      ? Colors.grey
                                      : kcBackgroundColor
                                  : heightInScaleDownedFt < 0
                                      ? Colors.grey
                                      : kcBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(
                                        0, 1) // changes position of shadow
                                    ),
                              ],
                            ),
                            child: Center(
                              child: Text(_buildHeightMarkerText(),
                                  key: const Key('heightMarkerText'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  )),
                            ),
                          ))
                    ],
                    minimum: isMetric ? 125.0 : 4,
                    maximum: isMetric ? 225.0 : 8,
                    interval: isMetric ? 10 : 1,
                    minorTicksPerInterval: isMetric ? 1 : 5,
                    orientation: LinearGaugeOrientation.horizontal,
                    axisTrackStyle: const LinearAxisTrackStyle(
                        thickness: 15, edgeStyle: LinearEdgeStyle.bothFlat)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProstheticIntervention() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('prostheticIntervention_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Prosthetic Interventions',
                      data: sectionJ),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                  child: Text(
                'Prosthetic Interventions',
                style: episodeHeaderTextStyle,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('prostheticIntervention'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: widget.episodeOfCare.prostheticIntervention,
                    items: ProstheticIntervention.values
                        .map((e) => DropdownMenuItem(
                            key: Key('prostheticIntervention_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.episodeOfCare.prostheticIntervention = value;

                        if (widget.isEdit) {
                          widget.onChange!(widget.episodeOfCare);
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxEducation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('maxEducation_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Maximum Education Level',
                      data: sectionR),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'What is the highest level of education that you have obtained?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('maxEducation'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: widget.episodeOfCare.maxEducationLevel,
                    items: MaxEducationLevel.values
                        .map((e) => DropdownMenuItem(
                            key: Key('maxEducation_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.episodeOfCare.maxEducationLevel = value;

                        if (widget.isEdit) {
                          widget.onChange!(widget.episodeOfCare);
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('profession_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Professions Involved in Providing Services',
                      data: sectionH),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Please select any rehabilitation treatments received in this episode of care.',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: Profession.values.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                key: Key('professions_$index}'),
                onTap: () => onTapProfessionItem(index),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 38,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Profession.values[index].displayName,
                            style: episodeOptionsTextStyle,
                          ),
                          Checkbox(
                              key: Key('profession_$index'),
                              value: professions[index],
                              onChanged: (bool? value) =>
                                  onTapProfessionItem(index))
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              indent: 38,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }

  void onTapProfessionItem(int index) {
    setState(() {
      professions[index] = !professions[index];

      widget.episodeOfCare.professionsInvolved = professions
          .asMap()
          .entries
          .where((element) => element.value)
          .map((e) => Profession.values[e.key])
          .toList();

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  Widget _buildTobaccoUsage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: IconButton(
                  key: const Key('tobaccoUsage_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Tobacco Usage',
                      data: sectionO),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'In the past three months, how often have you used tobacco-based products?',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 38,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    key: const Key('tobaccoUsage'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: widget.episodeOfCare.tobaccoUsage,
                    items: TobaccoUsage.values
                        .map((e) => DropdownMenuItem(
                            key: Key('tobaccoUsage_${e.displayName}'),
                            value: e,
                            child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.episodeOfCare.tobaccoUsage = value;

                        if (widget.isEdit) {
                          widget.onChange!(widget.episodeOfCare);
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    icdCodeController.dispose();
    ctOtherController.dispose();
    cmController.dispose();
    ftController.dispose();
    inchController.dispose();
    weightController.dispose();
    cmFocusNode.removeListener(onCmFocusChange);
    ftFocusNode.removeListener(onFtFocusChange);
    inchFocusNode.removeListener(onInchFocusChange);
    weightFocusNode.removeListener(onWeightFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 46.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBodyMeasurements(),
              _buildTobaccoUsage(),
              _buildMaxEducation(),
              _buildMorbidities(),
              _buildProfessions(),
              _buildRehabServices(),
              if (rehabilitationServices[
                  RehabilitationServices.compressionTherapy.index])
                _buildCompressionTherapy(),
              _buildProstheticIntervention()
            ],
          ),
        ),
      ),
    );
  }
}
