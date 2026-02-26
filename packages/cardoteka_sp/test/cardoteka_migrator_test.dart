// import 'package:cardoteka/cardoteka.dart';
// import 'package:flutter/material.dart' hide Card;
// import 'package:flutter_test/flutter_test.dart';
//
// import '../init_sp.dart';
// import '../utils/test_tools.dart';
//
// // ignore: unreachable_from_main
// const config = CardotekaConfig(
//   name: 'user_settings',
//   cards: [/*...*/],
// );
//
// enum TestKey {
//   fsm('fsm_vapid_key', 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu'),
//   memory('platform_available_memory_mb', 2119.3),
//   theme('theme_mode_index', 1),
//   isPremium('user_settings.isPremium', true),
//   userName('user_settings.userName', 'Ivan'),
//   ;
//
//   const TestKey(this.key, this.value);
//
//   final String key;
//   final Object value;
// }
//
// final constDataInOldStorage = {
//   for (final e in [TestKey.fsm, TestKey.memory, TestKey.theme]) e.key: e.value
// };
//
// final constDataInNewStorage = {
//   for (final e in [TestKey.isPremium, TestKey.userName]) e.key: e.value
// };
//
// extension SharedPreferencesX on SharedPreferences {
//   Map<String, Object?> getAll() => {for (final key in getKeys()) key: get(key)};
// }
//
Future<void> main() async {
//   initMockNewSP();
//
//   late SharedPreferences spOld;
//   late SharedPreferencesAsync spNew;
//
//   Future<void> setUpAction() async {
//     SharedPreferences.setMockInitialValues(constDataInOldStorage);
//     spOld = await SharedPreferences.getInstance();
//
//     spNew = SharedPreferencesAsync();
//     await spNew.setBool('user_settings.isPremium', true);
//     await spNew.setString('user_settings.userName', 'Ivan');
//   }
//
//   Future<void> tearDownAction() async {
//     await spOld.clear();
//     await spNew.clear();
//   }
//
//   await testWith(
//     '$CardotekaMigrator.migrate (v1 to v2)--> default',
//     setUp: setUpAction,
//     tearDown: tearDownAction,
//     () async {
//       await CardotekaMigrator.migrate();
//
//       final Map dataInOld = spOld.getAll();
//       expect(
//         dataInOld,
//         isEmpty,
//         reason: 'The OLD storage should be empty',
//       );
//
//       final Map dataInNew = await spNew.getAll();
//       expect(
//         dataInNew,
//         equals({
//           ...constDataInOldStorage,
//           ...constDataInNewStorage,
//           CardotekaMigrator.didMigrateV2key: true,
//         }),
//         reason: 'Data from OLD storage should be added to NEW storage',
//       );
//     },
//   );
//
//   await testWith(
//     '$CardotekaMigrator.migrate (v1 to v2)--> toV2Handler=null',
//     setUp: setUpAction,
//     tearDown: tearDownAction,
//     () async {
//       await CardotekaMigrator.migrate(toV2Handler: null);
//
//       final Map dataInOld = spOld.getAll();
//       expect(
//         dataInOld,
//         equals(constDataInOldStorage),
//         reason: 'The OLD storage must be filled with original data',
//       );
//
//       final Map dataInNew = await spNew.getAll();
//       expect(
//         dataInNew,
//         equals(constDataInNewStorage),
//         reason: 'The NEW storage must be filled with original data',
//       );
//     },
//   );
//
//   await testWith(
//     '$CardotekaMigrator.migrate (v1 to v2)--> removeOld=false,ignore=false',
//     setUp: setUpAction,
//     tearDown: tearDownAction,
//     () async {
//       await CardotekaMigrator.migrate(
//         toV2Handler: (key, value) =>
//             (key, value, removeOld: false, ignore: false),
//       );
//
//       final Map dataInOld = spOld.getAll();
//       expect(
//         dataInOld,
//         equals(constDataInOldStorage),
//         reason: 'The OLD storage must be filled with original data',
//       );
//
//       final Map dataInNew = await spNew.getAll();
//       expect(
//         dataInNew,
//         equals({
//           ...constDataInOldStorage,
//           ...constDataInNewStorage,
//           CardotekaMigrator.didMigrateV2key: true,
//         }),
//         reason:
//             'Data from OLD storage should be added to NEW storage with didMigrateV2key=true',
//       );
//     },
//   );
//
//   await testWith(
//     '$CardotekaMigrator.migrate (v1 to v2)--> removeOld=true,ignore=true',
//     setUp: setUpAction,
//     tearDown: tearDownAction,
//     () async {
//       await CardotekaMigrator.migrate(
//         toV2Handler: (key, value) =>
//             (key, value, removeOld: true, ignore: true),
//       );
//
//       final Map dataInOld = spOld.getAll();
//       expect(
//         dataInOld,
//         isEmpty,
//         reason: 'The OLD storage must be empty',
//       );
//
//       final Map dataInNew = await spNew.getAll();
//       expect(
//         dataInNew,
//         equals({
//           ...constDataInNewStorage,
//           CardotekaMigrator.didMigrateV2key: true,
//         }),
//         reason:
//             'The NEW storage must be filled with original data with didMigrateV2key=true',
//       );
//     },
//   );
//
//   await testWith(
//     '$CardotekaMigrator.migrate (v1 to v2)--> removeOld=false,ignore=true',
//     setUp: setUpAction,
//     tearDown: tearDownAction,
//     () async {
//       await CardotekaMigrator.migrate(
//         toV2Handler: (key, value) =>
//             (key, value, removeOld: false, ignore: true),
//       );
//
//       final Map dataInOld = spOld.getAll();
//       expect(
//         dataInOld,
//         equals(constDataInOldStorage),
//         reason: 'The OLD storage must be filled with original data',
//       );
//
//       final Map dataInNew = await spNew.getAll();
//       expect(
//         dataInNew,
//         equals({
//           ...constDataInNewStorage,
//           CardotekaMigrator.didMigrateV2key: true,
//         }),
//         reason:
//             'The NEW storage must be filled with original data with didMigrateV2key=true',
//       );
//     },
//   );
//
//   // It was before migration in old storage:
//   // {
//   //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
//   //   'platform_available_memory_mb': 2119.3,
//   //   'theme_mode_index': 1,
//   // };
//   // and at the same time in new storage:
//   // {
//   //   'user_settings.isPremium': true,
//   //   'user_settings.userName': 'Ivan',
//   // };
//   //
//   //
//   // Now after migration in old storage:
//   // {
//   //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
//   //   'platform_available_memory_mb': 2119.3,
//   // };
//   // and in new storage:
//   // {
//   //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
//   //   'user_settings.themeModeApp': 'light',
//   //   'user_settings.isPremium': true,
//   //   'user_settings.userName': 'Ivan',
//   //   '_cardoteka_package_did_migrate_v2': true,
//   // };
//
//   await testWith(
//     '$CardotekaMigrator.migrate (v1 to v2)--> 1 way',
//     setUp: setUpAction,
//     tearDown: tearDownAction,
//     () async {
//       await CardotekaMigrator.migrate(
//         toV2Handler: (key, value) => switch (key) {
//           'fsm_vapid_key' => (key, value, removeOld: false, ignore: false),
//           'platform_available_memory_mb' => (
//               key,
//               value,
//               removeOld: false,
//               ignore: true
//             ),
//           'theme_mode_index' => (
//               '${config.name}.themeModeApp',
//               switch (value) {
//                 1 => ThemeMode.light,
//                 2 => ThemeMode.dark,
//                 _ => ThemeMode.system,
//               }
//                   .name,
//               removeOld: true,
//               ignore: false,
//             ),
//           _ => (key, value, removeOld: true, ignore: false),
//         },
//       );
//
//       final Map dataInOld = spOld.getAll();
//       expect(
//         dataInOld,
//         equals({
//           TestKey.fsm.key: TestKey.fsm.value,
//           TestKey.memory.key: TestKey.memory.value,
//         }),
//         reason: 'As planned',
//       );
//
//       final Map dataInNew = await spNew.getAll();
//       expect(
//         dataInNew,
//         equals({
//           TestKey.fsm.key: TestKey.fsm.value,
//           TestKey.isPremium.key: TestKey.isPremium.value,
//           TestKey.userName.key: TestKey.userName.value,
//           '${config.name}.themeModeApp': 'light',
//           CardotekaMigrator.didMigrateV2key: true,
//         }),
//         reason: 'As planned',
//       );
//     },
//   );
//
//   await testWith(
//     '$CardotekaMigrator.migrate (v1 to v2)--> 2 way',
//     setUp: setUpAction,
//     tearDown: tearDownAction,
//     () async {
//       await CardotekaMigrator.migrate(
//         toV2Handler: (key, value) => (
//           switch (key) {
//             'theme_mode_index' => '${config.name}.themeModeApp',
//             _ => key
//           },
//           switch (key) {
//             'theme_mode_index' => switch (value) {
//                 1 => ThemeMode.light,
//                 2 => ThemeMode.dark,
//                 _ => ThemeMode.system,
//               }
//                   .name,
//             _ => value,
//           },
//           removeOld: key != TestKey.memory.key && key != TestKey.fsm.key,
//           ignore: key == TestKey.memory.key,
//         ),
//       );
//
//       final Map dataInOld = spOld.getAll();
//       expect(
//         dataInOld,
//         equals({
//           TestKey.fsm.key: TestKey.fsm.value,
//           TestKey.memory.key: TestKey.memory.value,
//         }),
//         reason: 'As planned',
//       );
//
//       final Map dataInNew = await spNew.getAll();
//       expect(
//         dataInNew,
//         equals({
//           TestKey.fsm.key: TestKey.fsm.value,
//           TestKey.isPremium.key: TestKey.isPremium.value,
//           TestKey.userName.key: TestKey.userName.value,
//           '${config.name}.themeModeApp': 'light',
//           CardotekaMigrator.didMigrateV2key: true,
//         }),
//         reason: 'As planned',
//       );
//     },
//   );
}
