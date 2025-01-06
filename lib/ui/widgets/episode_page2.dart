import 'package:biot/model/episode_of_care.dart';
import 'package:biot/ui/widgets/socket_form.dart';
import 'package:flutter/material.dart';

class Page2 extends StatefulWidget {
  final EpisodeOfCare episodeOfCare;
  final bool isEdit;
  final Function(EpisodeOfCare)? onChange;

  const Page2(
      {super.key,
      required this.episodeOfCare,
      required this.isEdit,
      this.onChange});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 46.0, 8.0),
          child: DefaultTabController(
            length: widget.episodeOfCare.socketInfoList.length,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: TabBar(
                    tabs: widget.episodeOfCare.socketInfoList
                        .map((e) => Tab(
                              key: Key("${e.side?.displayName}_tab"),
                              text:
                                  "${e.side?.displayName} Prosthesis Description",
                            ))
                        .toList(),
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.normal),
                    unselectedLabelColor: Colors.grey,
                    padding: const EdgeInsets.only(bottom: 16),
                  ),
                )
              ],
              body: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: TabBarView(
                    children: widget.episodeOfCare.socketInfoList
                        .map((e) => SocketForm(
                              key: Key("${e.side?.displayName}_tabBarView"),
                              socketInfo: e,
                              isEdit: widget.isEdit,
                              episodeOfCare: widget.episodeOfCare,
                              onChange: widget.onChange,
                            ))
                        .toList()),
              ),
            ),
          )),
    );
  }
}
