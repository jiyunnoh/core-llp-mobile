import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.dialogs.dart';
import '../../app/app.locator.dart';
import '../../constants/compass_lead_enum.dart';
import '../../constants/compass_lead_info.dart';
import '../../model/episode_of_care.dart';
import '../../model/socket_info.dart';
import '../common/ui_helpers.dart';

class SocketForm extends StatefulWidget {
  final dialogService = locator<DialogService>();

  final SocketInfo socketInfo;
  final bool isEdit;
  final EpisodeOfCare episodeOfCare;
  final Function(EpisodeOfCare)? onChange;

  SocketForm(
      {super.key,
      required this.socketInfo,
      required this.isEdit,
      required this.episodeOfCare,
      this.onChange});

  @override
  State<SocketForm> createState() => _SocketFormState();
}

class _SocketFormState extends State<SocketForm> {
  List<bool> socketTypes = List.filled(SocketType.values.length, false);
  List<bool> prostheticFootTypes =
      List.filled(ProstheticFootType.values.length, false);
  List<bool> prostheticKneeTypes =
      List.filled(ProstheticKneeType.values.length, false);
  List<bool> prostheticHipTypes =
      List.filled(ProstheticHipType.values.length, false);

  DateTime? pickedDate;

  TextEditingController dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  @override
  void initState() {
    super.initState();

    if (widget.socketInfo.dateOfDelivery != null) {
      dateController.text =
          DateFormat('yyyy-MM-dd').format(widget.socketInfo.dateOfDelivery!);
      pickedDate = widget.socketInfo.dateOfDelivery;
    }

    // every time widget is initialized, retrieve checkbox value
    widget.socketInfo.socketTypes
        .map((e) => socketTypes[e.index] = true)
        .toList();

    widget.socketInfo.prostheticFootTypes
        .map((e) => prostheticFootTypes[e.index] = true)
        .toList();

    widget.socketInfo.prostheticKneeTypes
        .map((e) => prostheticKneeTypes[e.index] = true)
        .toList();

    widget.socketInfo.prostheticHipTypes
        .map((e) => prostheticHipTypes[e.index] = true)
        .toList();
  }

  void onFootTypeChanged(int index) {
    setState(() {
      prostheticFootTypes[index] = !prostheticFootTypes[index];

      // hard rubber bare foot design cannot be checked with other options.
      if (index == ProstheticFootType.hardRubberBareFootDesign.index) {
        for (int i = 0; i < prostheticFootTypes.length; i++) {
          // It's necessary to use an if statement to toggle this checkbox. Without it, the bool value will be masked, and the checkbox will always be true.
          if (i != index) {
            prostheticFootTypes[i] = i == index;
          }
        }
      } else {
        prostheticFootTypes[ProstheticFootType.hardRubberBareFootDesign.index] =
            false;
      }

      // SACH cannot be checked with other options.
      if (index == ProstheticFootType.sach.index) {
        for (int i = 0; i < prostheticFootTypes.length; i++) {
          // It's necessary to use an if statement to toggle this checkbox. Without it, the bool value will be masked, and the checkbox will always be true.
          if (i != index) {
            prostheticFootTypes[i] = i == index;
          }
        }
      } else {
        prostheticFootTypes[ProstheticFootType.sach.index] = false;
      }

      // single axis cannot be checked with multi axial
      if (index == ProstheticFootType.singleAxis.index) {
        prostheticFootTypes[ProstheticFootType.multiaxial.index] = false;
      }
      if (index == ProstheticFootType.multiaxial.index) {
        prostheticFootTypes[ProstheticFootType.singleAxis.index] = false;
      }

      // pneumatic cannot be checked with hydraulic
      if (index == ProstheticFootType.pneumatic.index) {
        prostheticFootTypes[ProstheticFootType.hydraulic.index] = false;
      }
      if (index == ProstheticFootType.hydraulic.index) {
        prostheticFootTypes[ProstheticFootType.pneumatic.index] = false;
      }

      // Map list of bool to list of foot type selection
      widget.socketInfo.prostheticFootTypes = prostheticFootTypes
          .asMap()
          .entries
          .where((element) => element.value)
          .map((e) => ProstheticFootType.values[e.key])
          .toList();

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  void onKneeTypeChanged(int index) {
    setState(() {
      prostheticKneeTypes[index] = !prostheticKneeTypes[index];

      // single axis cannot be checked with multi axial
      if (index == ProstheticKneeType.singleAxis.index) {
        prostheticKneeTypes[ProstheticKneeType.multiaxial.index] = false;
      }
      if (index == ProstheticKneeType.multiaxial.index) {
        prostheticKneeTypes[ProstheticKneeType.singleAxis.index] = false;
      }

      // pneumatic cannot be checked with hydraulic
      if (index == ProstheticKneeType.pneumatic.index) {
        prostheticKneeTypes[ProstheticKneeType.hydraulic.index] = false;
      }
      if (index == ProstheticKneeType.hydraulic.index) {
        prostheticKneeTypes[ProstheticKneeType.pneumatic.index] = false;
      }

      // Map list of bool to list of knee type selection
      widget.socketInfo.prostheticKneeTypes = prostheticKneeTypes
          .asMap()
          .entries
          .where((element) => element.value)
          .map((e) => ProstheticKneeType.values[e.key])
          .toList();

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  void onHipTypeChanged(int index) {
    setState(() {
      prostheticHipTypes[index] = !prostheticHipTypes[index];

      // single axis cannot be checked with multi axial
      if (index == ProstheticHipType.singleAxis.index) {
        prostheticHipTypes[ProstheticHipType.multiaxial.index] = false;
      }
      if (index == ProstheticHipType.multiaxial.index) {
        prostheticHipTypes[ProstheticHipType.singleAxis.index] = false;
      }

      // pneumatic cannot be checked with hydraulic
      if (index == ProstheticHipType.pneumatic.index) {
        prostheticHipTypes[ProstheticHipType.hydraulic.index] = false;
      }
      if (index == ProstheticHipType.hydraulic.index) {
        prostheticHipTypes[ProstheticHipType.pneumatic.index] = false;
      }

      // Map list of bool to list of knee type selection
      widget.socketInfo.prostheticHipTypes = prostheticHipTypes
          .asMap()
          .entries
          .where((element) => element.value)
          .map((e) => ProstheticHipType.values[e.key])
          .toList();

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  void onSocketTypeChanged(int index) {
    setState(() {
      socketTypes[index] = !socketTypes[index];

      widget.socketInfo.socketTypes = socketTypes
          .asMap()
          .entries
          .where((element) => element.value)
          .map((e) => SocketType.values[e.key])
          .toList();

      if (widget.isEdit) {
        widget.onChange!(widget.episodeOfCare);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? designWidget;
    switch (widget.socketInfo.socket) {
      case Socket.partialFoot:
        designWidget = _buildPartialFootDesign(widget.socketInfo);
      case Socket.ankleDisarticulation:
        designWidget = _buildAnkleDisarticulationDesign(widget.socketInfo);
      case Socket.transTibial:
        designWidget = _buildTransTibialDesign(widget.socketInfo);
      case Socket.kneeDisarticulation:
        designWidget = _buildKneeDisarticulationDesign(widget.socketInfo);
      case Socket.transfemoral:
        designWidget = _buildTransfemoralDesign(widget.socketInfo);
      case Socket.hipDisarticulation:
      case Socket.hemiPelvectomy:
      case Socket.hemicorporectomy:
      case null:
        designWidget = null;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDateOfDelivery(context, widget.socketInfo),
          _buildSocket(widget.socketInfo),
          if (widget.socketInfo.socket != null &&
              !widget.socketInfo.socket!.isHip)
            designWidget!,
          _buildSocketType(widget.socketInfo),
          _buildLinerType(widget.socketInfo),
          _buildSuspension(widget.socketInfo),
          if (widget.socketInfo.socket != null)
            _buildProstheticFootType(widget.socketInfo),
          if (widget.socketInfo.socket != null &&
              widget.socketInfo.socket!.isAboveKnee)
            _buildProstheticKneeType(widget.socketInfo),
          if (widget.socketInfo.socket != null &&
              widget.socketInfo.socket!.isHip)
            _buildProstheticHipType(widget.socketInfo)
        ],
      ),
    );
  }

  Widget _buildDateOfDelivery(BuildContext context, SocketInfo socketInfo) {
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
                  key: const Key('dateOfDelivery_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Date of Delivery',
                      data: sectionK_1),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                  child: Text(
                'Date of socket delivery',
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
                child: TextFormField(
                  key: const Key('dateOfDelivery'),
                  onTap: () async =>
                      await onTapDateOfDelivery(context, socketInfo),
                  readOnly: true,
                  controller: dateController,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    filled: true,
                    hintText: 'Date of delivery',
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                    key: const Key('dateOfDelivery'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async =>
                        await onTapDateOfDelivery(context, socketInfo),
                    icon: const Icon(Icons.date_range_rounded)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> onTapDateOfDelivery(
      BuildContext context, SocketInfo socketInfo) async {
    pickedDate = await _showDatePicker(context);
    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate!);
        socketInfo.dateOfDelivery = pickedDate;

        if (widget.isEdit) {
          widget.onChange!(widget.episodeOfCare);
        }
      });
    }
  }

  Widget _buildSocket(SocketInfo socketInfo) {
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
                'Socket',
                style: episodeHeaderTextStyle,
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
                    key: const Key('socket'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: socketInfo.socket,
                    items: Socket.values
                        .map((e) => DropdownMenuItem(
                      key: Key('socket_${e.displayName}'),
                            value: e, child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        if (socketInfo.socket != value) {
                          // reset Design model
                          socketInfo.partialFootDesign = null;
                          socketInfo.ankleDisarticulationDesign = null;
                          socketInfo.transTibialDesign = null;
                          socketInfo.kneeDisarticulationDesign = null;
                          socketInfo.transfemoralDesign = null;

                          // reset model
                          socketInfo.prostheticFootTypes = [];
                          socketInfo.prostheticKneeTypes = [];
                          socketInfo.prostheticHipTypes = [];

                          // reset UI
                          for (int i = 0; i < prostheticFootTypes.length; i++) {
                            prostheticFootTypes[i] = false;
                          }
                          for (int i = 0; i < prostheticKneeTypes.length; i++) {
                            prostheticKneeTypes[i] = false;
                          }
                          for (int i = 0; i < prostheticHipTypes.length; i++) {
                            prostheticHipTypes[i] = false;
                          }
                        }

                        socketInfo.socket = value;

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

  Widget _buildSocketType(SocketInfo socketInfo) {
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
                  key: const Key('socketType_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Socket Type',
                      data: sectionK_2),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Text(
                'Type',
                style: episodeHeaderTextStyle,
              ),
            ],
          ),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: SocketType.values.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => onSocketTypeChanged(index),
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
                            SocketType.values[index].displayName,
                            style: episodeOptionsTextStyle,
                          ),
                          Checkbox(
                              key: Key('socketType_$index'),
                              value: socketTypes[index],
                              onChanged: (bool? value) =>
                                  onSocketTypeChanged(index))
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

  Widget _buildLinerType(SocketInfo socketInfo) {
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
                'Liner',
                style: episodeHeaderTextStyle,
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
                    key: const Key('liner'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: socketInfo.liner,
                    items: Liner.values
                        .map((e) => DropdownMenuItem(
                      key: Key('liner_${e.displayName}'),
                            value: e, child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        socketInfo.liner = value;

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

  Widget _buildSuspension(SocketInfo socketInfo) {
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
                'Suspension',
                style: episodeHeaderTextStyle,
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
                    key: const Key('suspension'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: socketInfo.suspension,
                    items: Suspension.values
                        .map((e) => DropdownMenuItem(
                      key: Key('suspension_${e.displayName}'),
                            value: e, child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        socketInfo.suspension = value;

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

  Widget _buildProstheticFootType(SocketInfo socketInfo) {
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
                  key: const Key('footType_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Prosthetic Foot/Ankle',
                      data: sectionL),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(
                child: Text(
                  'Select all that apply to the foot on this prosthesis, and multiple categories in the case of crossover foot ankle combinations.',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          ListView.separated(
            key: const Key('prostheticFoot'),
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ProstheticFootType.values.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => onFootTypeChanged(index),
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
                            ProstheticFootType.values[index].displayName,
                            style: episodeOptionsTextStyle,
                          ),
                          Checkbox(
                              key: Key('prostheticFoot_$index'),
                              value: prostheticFootTypes[index],
                              onChanged: (bool? value) =>
                                  onFootTypeChanged(index))
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

  Widget _buildProstheticKneeType(SocketInfo socketInfo) {
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
              Expanded(
                child: Text(
                  key: const Key('prostheticKneeType'),
                  'Select all that apply to the knee on this prosthesis, multiple categories allowed where the knee has multiple properties on this list.',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          ListView.separated(
            key: const Key('prostheticKnee'),
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ProstheticKneeType.values.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => onKneeTypeChanged(index),
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
                            ProstheticKneeType.values[index].displayName,
                            style: episodeOptionsTextStyle,
                          ),
                          Checkbox(
                              key: Key('prostheticKnee_$index'),
                              value: prostheticKneeTypes[index],
                              onChanged: (bool? value) =>
                                  onKneeTypeChanged(index))
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

  Widget _buildProstheticHipType(SocketInfo socketInfo) {
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
              Expanded(
                child: Text(
                  key: const Key('prostheticHipType'),
                  'Select all that apply to the hip on this prosthesis, multiple categories allowed where the hip has multiple properties on this list.',
                  style: episodeHeaderTextStyle,
                ),
              ),
            ],
          ),
          ListView.separated(
            key: const Key('prostheticHip'),
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ProstheticHipType.values.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => onHipTypeChanged(index),
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
                            ProstheticHipType.values[index].displayName,
                            style: episodeOptionsTextStyle,
                          ),
                          Checkbox(
                              key: Key('prostheticHip_$index'),
                              value: prostheticHipTypes[index],
                              onChanged: (bool? value) =>
                                  onHipTypeChanged(index))
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

  Widget _buildTransfemoralDesign(SocketInfo socketInfo) {
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
                  key: const Key('transfemoral_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Transfemoral',
                      data: sectionKTransfemoral),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Text(
                'Design',
                style: episodeHeaderTextStyle,
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
                    key: const Key('transfemoral_design'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: socketInfo.transfemoralDesign,
                    items: TransfemoralDesign.values
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        socketInfo.transfemoralDesign = value;

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

  Widget _buildKneeDisarticulationDesign(SocketInfo socketInfo) {
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
                'Design',
                style: episodeHeaderTextStyle,
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
                    key: const Key('kneeDisarticulation_design'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: socketInfo.kneeDisarticulationDesign,
                    items: KneeDisarticulationDesign.values
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        socketInfo.kneeDisarticulationDesign = value;

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

  Widget _buildTransTibialDesign(SocketInfo socketInfo) {
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
                  key: const Key('transtibial_info'),
                  onPressed: () => widget.dialogService.showCustomDialog(
                      barrierDismissible: true,
                      variant: DialogType.infoAlert,
                      title: 'Transtibial',
                      data: sectionKTransTibial),
                  icon: const Icon(Icons.info_outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Text(
                'Design',
                style: episodeHeaderTextStyle,
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
                    key: const Key('transTibial_design'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: socketInfo.transTibialDesign,
                    items: TransTibialDesign.values
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        socketInfo.transTibialDesign = value;

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

  Widget _buildAnkleDisarticulationDesign(SocketInfo socketInfo) {
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
                'Design',
                style: episodeHeaderTextStyle,
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
                    key: const Key('ankleDisarticulation_design'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: socketInfo.ankleDisarticulationDesign,
                    items: AnkleDisarticulationDesign.values
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        socketInfo.ankleDisarticulationDesign = value;

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

  Widget _buildPartialFootDesign(SocketInfo socketInfo) {
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
                'Design',
                style: episodeHeaderTextStyle,
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
                    key: const Key('partialFoot_design'),
                    hint: const Text('Not Selected'),
                    disabledHint: null,
                    value: socketInfo.partialFootDesign,
                    items: PartialFootDesign.values
                        .map((e) => DropdownMenuItem(
                      key: Key('partialFoot_design_${e.displayName}'),
                            value: e, child: Text(e.displayName)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        socketInfo.partialFootDesign = value;

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

  Future<DateTime?> _showDatePicker(BuildContext context) {
    DateTime now = DateTime.now();
    return showDatePicker(
        context: context,
        keyboardType: TextInputType.text,
        initialDate: pickedDate == null ? now : pickedDate!,
        firstDate: DateTime(DateTime.now().year - 120),
        lastDate: now,
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      onSurface: Colors.black),
                  textButtonTheme: TextButtonThemeData(
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.black))),
              child: child!);
        });
  }
}
