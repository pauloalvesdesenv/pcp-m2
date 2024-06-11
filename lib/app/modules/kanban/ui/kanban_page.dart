import 'package:aco_plus/app/core/client/firestore/firestore_client.dart';
import 'package:aco_plus/app/core/components/app_drawer.dart';
import 'package:aco_plus/app/core/components/app_scaffold.dart';
import 'package:aco_plus/app/core/components/stream_out.dart';
import 'package:aco_plus/app/modules/kanban/kanban_controller.dart';
import 'package:aco_plus/app/modules/kanban/ui/components/kanban/kanban_body_widget.dart';
import 'package:aco_plus/app/modules/kanban/ui/components/kanban/kanban_top_bar_widget.dart';
import 'package:flutter/material.dart';

class KanbanPage extends StatefulWidget {
  const KanbanPage({super.key});

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  @override
  void initState() {
    kanbanCtrl.onInit().then((_) {
      FirestoreClient.pedidos.dataStream.controller.listen((e) {
        kanbanCtrl.onMount();
      });
      FirestoreClient.steps.dataStream.controller.listen((e) {
        kanbanCtrl.onMount();
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      drawer: const AppDrawer(),
      appBar: const KanbanTopBarWidget(),
      body: StreamOut(
        loading: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/images/kanban_background.png'),
        fit: BoxFit.cover,
      )),
        ),
        stream: kanbanCtrl.utilsStream.listen,
        builder: (context, utils) => KanbanBodyWidget(utils),
      ),
    );
  }
}
