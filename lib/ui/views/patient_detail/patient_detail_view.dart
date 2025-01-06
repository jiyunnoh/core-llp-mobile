import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/amputation.dart';
import 'package:biot/ui/common/ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../model/encounter.dart';
import 'patient_detail_viewmodel.dart';

class PatientDetailView extends StackedView<PatientDetailViewModel> {
  const PatientDetailView({super.key});

  Widget _buildAmputationInfo(PatientDetailViewModel viewModel) {
    if (viewModel.currentPatient.amputations.isNotEmpty) {
      return Container(
          color: Colors.white,
          child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Amputation amp = viewModel.currentPatient.amputations[index];
                return ListTile(
                    title: Text(amp.side!.displayName),
                    trailing: Text(amp.level!.displayName));
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 1,
                  indent: 20,
                );
              },
              itemCount: viewModel.currentPatient.amputations.length));
    } else {
      return Container(
          color: Colors.white,
          width: double.infinity,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0),
            child: Center(
                child: Text(
                    'Enter Amputation information by starting an Episode below')),
          ));
    }
  }

  @override
  Widget builder(
    BuildContext context,
    PatientDetailViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Client')),
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 30),
                    horizontalSpaceTiny,
                    Text(viewModel.currentPatient.id,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 26)),
                  ],
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ListTile(
                          title: const Text('Year of Birth'),
                          trailing:
                              Text('${viewModel.currentPatient.dob!.year}')),
                      const Divider(
                        height: 1,
                        indent: 20,
                      ),
                      ListTile(
                          title: const Text('Sex'),
                          trailing: Text(
                              viewModel.currentPatient.sexAtBirth.displayName))
                    ],
                  ),
                )
              ],
            ),
            verticalSpaceMedium,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amputation',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    if (viewModel.currentPatient.amputations.isNotEmpty)
                      GestureDetector(
                          onTap: viewModel.onTapAmputation,
                          child: ElevatedButton(
                              onPressed: viewModel.onTapAmputation,
                              child: const Text('Detail')))
                  ],
                ),
                _buildAmputationInfo(viewModel)
              ],
            ),
            verticalSpaceMedium,
            if (!viewModel.isBusy) _buildEpisodes(viewModel),
            verticalSpaceMedium,
            if (!viewModel.isBusy) _buildEncounters(viewModel)
          ],
        ),
      ),
    );
  }

  Column _buildEpisodes(PatientDetailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Episodes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Container(
            color: Colors.white,
            width: double.infinity,
            child: viewModel.isBusy
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (viewModel.encounterCollection.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () => viewModel.onStartPreEpisode(),
                              child: const Text('Start Episode')),
                        ),
                      if (viewModel.encounterCollection.isNotEmpty)
                        Column(
                          children: [
                            ListTile(
                                title: Text(EpisodePrefix.pre.displayName),
                                trailing: viewModel.encounterCollection
                                            .preEncounter ==
                                        null
                                    ? const Text('Locally Stored')
                                    : Text(
                                        'Completed on ${DateFormat('yyyy-MM-dd, HH:mm:ss').format(viewModel.encounterCollection.episodes.first.encounterCreatedTime!)}')),
                          ],
                        ),
                      if (viewModel.encounterCollection.episodes.length == 1)
                        Column(
                          children: [
                            const Divider(
                              height: 1,
                              indent: 20,
                            ),
                            viewModel.encounterCollection.episodes.first
                                        .prefix ==
                                    EpisodePrefix.post
                                ? ListTile(
                                    title: Text(EpisodePrefix.post.displayName),
                                    trailing: Text(
                                        'Completed on ${DateFormat('yyyy-MM-dd, HH:mm:ss').format(viewModel.encounterCollection.episodes.first.encounterCreatedTime!)}'))
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                        onPressed: () =>
                                            viewModel.onStartPostEpisode(),
                                        child:
                                            const Text('Start Post Episode')),
                                  ),
                          ],
                        ),
                      if (viewModel.encounterCollection.episodes.length == 2)
                        Column(
                          children: [
                            const Divider(
                              height: 1,
                              indent: 20,
                            ),
                            ListTile(
                                title: Text(EpisodePrefix.post.displayName),
                                trailing: Text(
                                    'Completed on ${DateFormat('yyyy-MM-dd, HH:mm:ss').format(viewModel.encounterCollection.episodes.last.encounterCreatedTime!)}'))
                          ],
                        ),
                    ],
                  )),
        if (viewModel.encounterCollection.isEmpty)
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: viewModel.onPostEpisodeButtonTapped,
                  child: const Text('Post Episode >')))
      ],
    );
  }

  Widget _buildEncounters(PatientDetailViewModel viewModel) {
    if (viewModel.encounterCollection.nonEpisodes.isNotEmpty || viewModel.encounterCollection.canAddFirstNonEpisodeEncounter) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Encounters',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                if (viewModel.encounterCollection.nonEpisodes.isNotEmpty)
                  ElevatedButton(
                      onPressed: () => viewModel.onStartEncounter(),
                      child: const Text('+ Add'))
              ],
            ),
            Expanded(
                child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (viewModel
                            .encounterCollection.nonEpisodes.isNotEmpty)
                          Expanded(
                            child: ListView.separated(
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  Encounter encounter = viewModel
                                      .encounterCollection.nonEpisodes[index];
                                  return ListTile(
                                      title:
                                          Text(encounter.prefix!.displayName),
                                      trailing: Text(
                                          'Completed on ${DateFormat('yyyy-MM-dd, HH:mm:ss').format(encounter.encounterCreatedTime!)}'));
                                },
                                separatorBuilder: (context, index) {
                                  return const Divider(
                                    height: 1,
                                    indent: 20,
                                  );
                                },
                                itemCount: viewModel
                                    .encounterCollection.nonEpisodes.length),
                          ),
                        if (viewModel
                            .encounterCollection.canAddFirstNonEpisodeEncounter)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () => viewModel.onStartEncounter(),
                                child: const Text('Add Encounter')),
                          ),
                      ],
                    )))
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void onViewModelReady(PatientDetailViewModel viewModel) {
    viewModel.getEncounters();
  }

  @override
  PatientDetailViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PatientDetailViewModel();
}
