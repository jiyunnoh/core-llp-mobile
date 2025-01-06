import 'package:biot/ui/common/ui_helpers.dart';
import 'package:biot/ui/views/add_lead_dialog/add_lead_dialog_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stacked/stacked.dart';

import '../../../model/patient.dart';
import 'patient_viewmodel.dart';

class PatientView extends StackedView<PatientViewModel> {
  const PatientView({super.key});

  Widget _buildPatientList(BuildContext context, PatientViewModel viewModel,
      List<Patient> patients) {
    return RefreshIndicator(
      onRefresh: viewModel.onPullRefresh,
      child: (patients.isEmpty)
          ? const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error),
                      Text('There is no client.'),
                    ],
                  ),
                )
              ],
            )
          : SlidableAutoCloseBehavior(
              child: ListView.separated(
                key: const Key('patientsListView'),
                itemCount: patients.length,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                    groupTag: 0,
                    endActionPane: ActionPane(
                      extentRatio: 0.25,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            showDialog(
                                    context: context,
                                    builder: (context) => AddLeadDialogView(
                                        viewModel.editPatient,
                                        isEdit: true,
                                        patient: patients[index]));
                          },
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        // SlidableAction(
                        //   onPressed: (context) => {
                        //     _confirmDelete(context, viewModel, patients[index])
                        //   },
                        //   backgroundColor: Colors.red,
                        //   foregroundColor: Colors.white,
                        //   icon: Icons.delete,
                        //   label: 'Delete',
                        // ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      leading: const Icon(Icons.person),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      title: Text(patients[index].id),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                  'Year of Birth: ${patients[index].dob!.year} • Sex: ${patients[index].sexAtBirth.displayName} • '),
                              Image.asset(
                                'assets/images/icon-stethoscope.png',
                                width: 10,
                              ),
                              horizontalSpaceTiny,
                              Text(patients[index].caregiverName != null
                                  ? patients[index].caregiverName!
                                  : "Not Assigned"),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        viewModel.onPatientTapped(patients[index]);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(height: 0);
                },
              ),
            ),
    );
  }

  @override
  Widget builder(
    BuildContext context,
    PatientViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Clients')),
      body: ValueListenableBuilder<Box<Patient>>(
        valueListenable: viewModel.patientBox.listenable(),
        builder: (context, box, _) {
          // TODO: patients = patients.isSetToDelete == false
          final patients = box.values.toList().cast<Patient>();
          if(patients.isNotEmpty){
            patients.sort((a, b) => b.creationTime!.compareTo(a.creationTime!));
          }
          return _buildPatientList(context, viewModel, patients);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add patient",
        onPressed: () async {
          showDialog(
                  context: context,
                  builder: (context) => AddLeadDialogView(viewModel.addPatient));
        },
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }

  @override
  PatientViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PatientViewModel();
}
