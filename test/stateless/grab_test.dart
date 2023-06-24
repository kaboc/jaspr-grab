import 'package:jaspr_test/jaspr_test.dart';

import 'package:jaspr_grab/grab.dart';

import '../common/notifiers.dart';
import '../common/widgets.dart';

void main() {
  late TestChangeNotifier changeNotifier;
  late TestValueNotifier valueNotifier;

  setUp(() {
    changeNotifier = TestChangeNotifier();
    valueNotifier = TestValueNotifier();
  });
  tearDown(() {
    changeNotifier.dispose();
    valueNotifier.dispose();
  });

  group('grab', () {
    testComponents(
      'With non-ValueListenable, listenable itself is returned',
      (tester) async {
        Object? value;
        await tester.pumpComponent(
          StatelessWithMixin(
            funcCalledInBuild: (context) {
              value = changeNotifier.grab(context);
            },
          ),
        );
        expect(value, equals(changeNotifier));
      },
    );

    testComponents(
      'With ValueListenable, its value is returned',
      (tester) async {
        Object? value;
        await tester.pumpComponent(
          StatelessWithMixin(
            funcCalledInBuild: (context) {
              value = valueNotifier.grab(context);
            },
          ),
        );
        expect(value, equals(valueNotifier.value));
      },
    );

    testComponents(
      'Rebuilds widget whenever non-ValueListenable notifies',
      (tester) async {
        var intValue = 0;
        var stringValue = '';

        await tester.pumpComponent(
          StatelessWithMixin(
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

    testComponents(
      'Rebuilds widget when any property of ValueListenable value is updated',
      (tester) async {
        var state = const TestState();

        await tester.pumpComponent(
          StatelessWithMixin(
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
