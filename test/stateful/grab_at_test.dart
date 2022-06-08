import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../common/notifiers.dart';
import '../common/stateful_components.dart';

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

  group('grabAt', () {
    test(
      'With non-ValueListenable, listenable itself is passed to selector',
      () async {
        Object? selectorValue;
        await tester.pumpComponent(
          GrabAtStateful(
            listenable: changeNotifier,
            selector: (value) => selectorValue = value,
          ),
        );
        expect(selectorValue, equals(changeNotifier));
      },
    );

    test(
      'With ValueListenable, its value is passed to selector',
      () async {
        valueNotifier.updateIntValue(10);

        Object? selectorValue;
        await tester.pumpComponent(
          GrabAtStateful(
            listenable: valueNotifier,
            selector: (value) => selectorValue = value,
          ),
        );
        expect(selectorValue, equals(valueNotifier.value));
      },
    );

    test(
      'Returns selected value',
      () async {
        valueNotifier.updateIntValue(10);

        int? value;
        await tester.pumpComponent(
          GrabAtStateful(
            listenable: valueNotifier,
            selector: (TestState state) => state.intValue,
            onBuild: (int? v) => value = v,
          ),
        );
        expect(value, equals(10));
      },
    );

    test(
      'Rebuilds widget and returns latest value when listenable is updated',
      () async {
        valueNotifier.updateIntValue(10);

        int? value;
        await tester.pumpComponent(
          GrabAtStateful(
            listenable: valueNotifier,
            selector: (TestState state) => state.intValue,
            onBuild: (int? v) => value = v,
          ),
        );

        valueNotifier.updateIntValue(20);
        await tester.pump();
        expect(value, equals(20));
      },
    );

    test(
      'Rebuilds widget only when listenable is non-ValueListenable and '
      'property chosen by selector is updated',
      () async {
        int? value1;
        String? value2;
        var buildCount1 = 0;
        var buildCount2 = 0;

        await tester.pumpComponent(
          MultiGrabAtsStateful(
            listenable: changeNotifier,
            selector1: (TestChangeNotifier notifier) => notifier.intValue,
            selector2: (TestChangeNotifier notifier) => notifier.stringValue,
            onBuild1: (int? v) {
              value1 = v;
              buildCount1++;
            },
            onBuild2: (String? v) {
              value2 = v;
              buildCount2++;
            },
          ),
        );

        changeNotifier.updateIntValue(10);
        await tester.pump();
        expect(value1, equals(10));
        expect(value2, equals(''));
        expect(buildCount1, equals(2));
        expect(buildCount2, equals(1));

        changeNotifier.updateStringValue('abc');
        await tester.pump();
        expect(value1, equals(10));
        expect(value2, equals('abc'));
        expect(buildCount1, equals(2));
        expect(buildCount2, equals(2));

        changeNotifier.updateIntValue(20);
        await tester.pump();
        expect(value1, equals(20));
        expect(value2, equals('abc'));
        expect(buildCount1, equals(3));
        expect(buildCount2, equals(2));
      },
    );

    test(
      'Rebuilds widget only when listenable is ValueListenable and '
      'property chosen by selector is updated',
      () async {
        int? value1;
        String? value2;
        var buildCount1 = 0;
        var buildCount2 = 0;

        await tester.pumpComponent(
          MultiGrabAtsStateful(
            listenable: valueNotifier,
            selector1: (TestState state) => state.intValue,
            selector2: (TestState state) => state.stringValue,
            onBuild1: (int? v) {
              value1 = v;
              buildCount1++;
            },
            onBuild2: (String? v) {
              value2 = v;
              buildCount2++;
            },
          ),
        );

        valueNotifier.updateIntValue(10);
        await tester.pump();
        expect(value1, equals(10));
        expect(value2, equals(''));
        expect(buildCount1, equals(2));
        expect(buildCount2, equals(1));

        valueNotifier.updateStringValue('abc');
        await tester.pump();
        expect(value1, equals(10));
        expect(value2, equals('abc'));
        expect(buildCount1, equals(2));
        expect(buildCount2, equals(2));

        valueNotifier.updateIntValue(20);
        await tester.pump();
        expect(value1, equals(20));
        expect(value2, equals('abc'));
        expect(buildCount1, equals(3));
        expect(buildCount2, equals(2));
      },
    );

    test(
      'Rebuilds widget whenever listenable notifies '
      'if listenable itself is returned from selector',
      () async {
        int? value1;
        String? value2;
        var buildCount1 = 0;
        var buildCount2 = 0;

        await tester.pumpComponent(
          MultiGrabAtsStateful(
            listenable: changeNotifier,
            selector1: (TestChangeNotifier notifier) => notifier,
            selector2: (TestChangeNotifier notifier) => notifier,
            onBuild1: (TestChangeNotifier notifier) {
              value1 = notifier.intValue;
              buildCount1++;
            },
            onBuild2: (TestChangeNotifier notifier) {
              value2 = notifier.stringValue;
              buildCount2++;
            },
          ),
        );

        changeNotifier.updateIntValue(10);
        await tester.pump();
        expect(value1, equals(10));
        expect(value2, equals(''));
        expect(buildCount1, equals(2));
        expect(buildCount2, equals(2));

        changeNotifier.updateStringValue('abc');
        await tester.pump();
        expect(value1, equals(10));
        expect(value2, equals('abc'));
        expect(buildCount1, equals(3));
        expect(buildCount2, equals(3));
      },
    );

    test(
      'Returns new value on rebuilt by other causes than listenable update too',
      () async {
        valueNotifier.updateIntValue(10);
        var multiplier = 2;

        int? value;
        await tester.pumpComponent(
          StatefulBuilder(
            builder: (_, setState) sync* {
              yield GrabAtStateful(
                listenable: valueNotifier,
                selector: (TestState state) => state.intValue * multiplier,
                onBuild: (int? v) => value = v,
              );
              yield DomComponent(
                tag: 'button',
                events: {
                  'click': (Object? _) => setState(() => multiplier = 3),
                },
                child: const Text('test'),
              );
            },
          ),
        );
        expect(value, equals(20));

        final buttonFinder = find.tag('button').first;
        await tester.click(buttonFinder);
        await tester.pump();
        expect(value, equals(30));
      },
    );
  });
}
