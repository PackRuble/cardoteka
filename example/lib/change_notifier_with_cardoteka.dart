import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart';

import 'app_cardoteka.dart';

// I created an instance of Cardoteka and cards earlier, and here I'm just
// showing you their types and uses
final AppCardoteka cardoteka = appCardoteka;
const AppSettings<List<String>> card = AppSettings.recentActivityList;

/// An example of using [Cardoteka] with the [WatcherImpl] and
/// [DetacherChangeNotifier] mixins for the [ChangeNotifier] state class.
class ActivityNotifier with ChangeNotifier, DetacherChangeNotifier {
  ActivityNotifier() {
    cardoteka.attach(
      card,
      (value) {
        recentActivity = value;
        notifyListeners();
      },
      onRemove: () {
        recentActivity.clear();
        notifyListeners();
      },
      detacher: onDetach,
      fireImmediately: true,
    );
  }

  List<String> recentActivity = [];

  void addActivity(String text) =>
      cardoteka.set(card, [...recentActivity, text]);

  void removeActivities() => cardoteka.remove(card);
}

Future<void> main() async {
  await Cardoteka.init();
  runApp(const RecentActivityApp());
}

class RecentActivityApp extends StatefulWidget {
  const RecentActivityApp({super.key});

  @override
  State<RecentActivityApp> createState() => _RecentActivityAppState();
}

class _RecentActivityAppState extends State<RecentActivityApp> {
  final _activityNR = ActivityNotifier();
  final _textCR = TextEditingController();

  @override
  void dispose() {
    _activityNR.dispose();
    _textCR.dispose();
    super.dispose();
  }

  void addRecord() {
    _activityNR.addActivity(_textCR.text);
    _textCR.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: _activityNR,
                builder: (context, child) => ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    for (final activity in _activityNR.recentActivity.reversed)
                      Text(
                        activity,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: _activityNR.removeActivities,
                  child: const Text('Delete all records'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCR,
                      minLines: 2,
                      maxLines: 2,
                      onEditingComplete: addRecord,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton.filledTonal(
                    onPressed: addRecord,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
