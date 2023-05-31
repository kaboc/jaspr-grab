import 'package:jaspr/components.dart';
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

  group('grabAt', () {
    test(
      'With non-ValueListenable, listenable itself is passed to selector',
      () async {
        Object? selectorValue;
        await tester.pumpComponent(
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              context.grabAt(
                changeNotifier,
                (TestChangeNotifier n) => selectorValue = n,
              );
            },
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
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              context.grabAt(
                valueNotifier,
                (TestState s) => selectorValue = s,
              );
            },
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
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              value = context.grabAt(
                valueNotifier,
                (TestState s) => s.intValue,
              );
            },
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
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              value = context.grabAt(
                valueNotifier,
                (TestState s) => s.intValue,
              );
            },
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
          Column(
            children: [
              StatefulWithMixin(
                funcCalledInBuild: (context) {
                  value1 = context.grabAt(
                    changeNotifier,
                    (TestChangeNotifier n) => n.intValue,
                  );
                  buildCount1++;
                },
              ),
              StatefulWithMixin(
                funcCalledInBuild: (context) {
                  value2 = context.grabAt(
                    changeNotifier,
                    (TestChangeNotifier n) => n.stringValue,
                  );
                  buildCount2++;
                },
              ),
            ],
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
          Column(
            children: [
              StatefulWithMixin(
                funcCalledInBuild: (context) {
                  value1 = context.grabAt(
                    valueNotifier,
                    (TestState s) => s.intValue,
                  );
                  buildCount1++;
                },
              ),
              StatefulWithMixin(
                funcCalledInBuild: (context) {
                  value2 = context.grabAt(
                    valueNotifier,
                    (TestState s) => s.stringValue,
                  );
                  buildCount2++;
                },
              ),
            ],
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
          Column(
            children: [
              StatefulWithMixin(
                funcCalledInBuild: (context) {
                  final notifier = context.grabAt(
                    changeNotifier,
                    (TestChangeNotifier n) => n,
                  );
                  value1 = notifier.intValue;
                  buildCount1++;
                },
              ),
              StatefulWithMixin(
                funcCalledInBuild: (context) {
                  final notifier = context.grabAt(
                    changeNotifier,
                    (TestChangeNotifier n) => n,
                  );
                  value2 = notifier.stringValue;
                  buildCount2++;
                },
              ),
            ],
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
              yield StatefulWithMixin(
                funcCalledInBuild: (context) {
                  value = context.grabAt(
                    valueNotifier,
                    (TestState s) => s.intValue * multiplier,
                  );
                },
              );
              yield DomComponent(
                tag: 'button',
                events: {
                  'click': (_) => setState(() => multiplier = 3),
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
