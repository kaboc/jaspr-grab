import 'package:jaspr_test/jaspr_test.dart';

import 'package:jaspr_grab/grab.dart';

import '../common/notifiers.dart';
import '../common/widgets.dart';

void main() {
  late final ComponentTester tester;
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
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              value = changeNotifier.grab(context);
            },
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
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              value = valueNotifier.grab(context);
            },
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
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              changeNotifier.grab(context);
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
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              state = valueNotifier.grab(context);
            },
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
