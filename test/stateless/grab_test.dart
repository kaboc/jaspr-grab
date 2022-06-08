import 'package:jaspr_test/jaspr_test.dart';

import '../common/notifiers.dart';
import '../common/stateless_components.dart';

void main() {
  late ComponentTester tester;
  late TestChangeNotifier changeNotifier;
  late TestValueNotifier valueNotifier;

  setUpAll(() => tester = ComponentTester.setUp());
  tearDownAll(ComponentTester.tearDown);

  setUp(() {
    changeNotifier = TestChangeNotifier();
    valueNotifier = TestValueNotifier();
  });
  tearDown(() {
    changeNotifier.dispose();
    valueNotifier.dispose();
  });

  group('grab', () {
    test(
      'With non-ValueListenable, listenable itself is returned',
      () async {
        Object? value;
        await tester.pumpComponent(
          GrabStateless(
            listenable: changeNotifier,
            onBuild: (Object v) => value = v,
          ),
        );
        expect(value, equals(changeNotifier));
      },
    );

    test(
      'With ValueListenable, its value is returned',
      () async {
        Object? value;
        await tester.pumpComponent(
          GrabStateless(
            listenable: valueNotifier,
            onBuild: (Object v) => value = v,
          ),
        );
        expect(value, equals(valueNotifier.value));
      },
    );

    test(
      'Rebuilds widget whenever non-ValueListenable notifies',
      () async {
        var intValue = 0;
        var stringValue = '';

        await tester.pumpComponent(
          GrabStateless(
            listenable: changeNotifier,
            onBuild: (_) {
              intValue = changeNotifier.intValue;
              stringValue = changeNotifier.stringValue;
            },
          ),
        );

        changeNotifier.updateIntValue(10);
        await tester.pump();
        expect(intValue, equals(10));
        expect(stringValue, equals(''));

        intValue = 0;

        changeNotifier.updateStringValue('abc');
        await tester.pump();
        expect(intValue, equals(10));
        expect(stringValue, equals('abc'));
      },
    );

    test(
      'Rebuilds widget when any property of ValueListenable value is updated',
      () async {
        var state = const TestState();

        await tester.pumpComponent(
          GrabStateless(
            listenable: valueNotifier,
            onBuild: (Object v) => state = v as TestState,
          ),
        );

        valueNotifier.updateIntValue(10);
        await tester.pump();
        expect(state.intValue, equals(10));
        expect(state.stringValue, isEmpty);

        state = const TestState();

        valueNotifier.updateStringValue('abc');
        await tester.pump();
        expect(state.intValue, equals(10));
        expect(state.stringValue, equals('abc'));
      },
    );
  });
}
