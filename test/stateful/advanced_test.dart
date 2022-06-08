import 'dart:async';

import 'package:jaspr_test/jaspr_test.dart';

import '../common/notifiers.dart';
import '../common/stateful_components.dart';

void main() {
  late ComponentTester tester;
  late TestChangeNotifier changeNotifier;
  late TestValueNotifier valueNotifier;
  late StreamController<bool> flagController;

  setUpAll(() => tester = ComponentTester.setUp());
  tearDownAll(ComponentTester.tearDown);

  setUp(() {
    changeNotifier = TestChangeNotifier();
    valueNotifier = TestValueNotifier();
    flagController = StreamController<bool>();
  });
  tearDown(() {
    changeNotifier.dispose();
    valueNotifier.dispose();
    flagController.close();
  });

  group('Advanced', () {
    test(
      'Updating multiple Listenables in a frame triggers a single rebuild',
      () async {
        changeNotifier.updateIntValue(10);
        valueNotifier.updateIntValue(20);

        int? value1;
        int? value2;
        var buildCount = 0;

        await tester.pumpComponent(
          MultiListenablesStateful(
            listenable1: changeNotifier,
            listenable2: valueNotifier,
            selector1: (TestChangeNotifier notifier) => notifier.intValue,
            selector2: (TestState state) => state.intValue,
            onBuild: (int? v1, int? v2) {
              value1 = v1;
              value2 = v2;
              buildCount++;
            },
          ),
        );

        expect(value1, equals(10));
        expect(value2, equals(20));
        expect(buildCount, equals(1));

        changeNotifier.updateIntValue(11);
        valueNotifier.updateIntValue(12);
        await tester.pump();
        expect(value1, equals(11));
        expect(value2, equals(12));
        expect(buildCount, equals(2));
      },
    );

    test(
      "Switching order of grabAt's doesn't affect behaviour",
      () async {
        valueNotifier
          ..updateIntValue(10)
          ..updateStringValue('abc');

        int? value1;
        String? value2;
        bool? flag;

        await tester.pumpComponent(
          ExtOrderSwitchStateful(
            flagStream: flagController.stream,
            listenable: valueNotifier,
            selector1: (TestState state) => state.intValue,
            selector2: (TestState state) => state.stringValue,
            onBuild: (int? v1, String? v2, bool f) {
              value1 = v1;
              value2 = v2;
              flag = f;
            },
          ),
        );

        expect(value1, equals(10));
        expect(value2, equals('abc'));
        expect(flag, isFalse);

        valueNotifier.updateIntValue(20);
        flagController.sink.add(true);
        await tester.pump();
        expect(value1, equals(20));
        expect(value2, equals('abc'));
        expect(flag, isTrue);

        valueNotifier.updateStringValue('def');
        flagController.sink.add(false);
        await tester.pump();
        expect(value1, equals(20));
        expect(value2, equals('def'));
        expect(flag, isFalse);
      },
    );
  });
}
