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
          StatefulWithMixin(
            funcCalledInBuild: (context) {
              value1 = changeNotifier.grabAt(
                context,
                (TestChangeNotifier n) => n.intValue,
              );
              value2 = valueNotifier.grabAt(context, (s) => s.intValue);
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
        var isSwapped = false;
        var buildCount = 0;

        await tester.pumpComponent(
          StatefulBuilder(
            builder: (_, setState) sync* {
              yield StatefulWithMixin(
                funcCalledInBuild: isSwapped
                    ? (context) {
                        value2 =
                            valueNotifier.grabAt(context, (s) => s.stringValue);
                        value1 =
                            valueNotifier.grabAt(context, (s) => s.intValue);
                        isSwapped = true;
                        buildCount++;
                      }
                    : (context) {
                        value1 =
                            valueNotifier.grabAt(context, (s) => s.intValue);
                        value2 =
                            valueNotifier.grabAt(context, (s) => s.stringValue);
                        isSwapped = false;
                        buildCount++;
                      },
              );
              yield DomComponent(
                tag: 'button',
                events: {
                  'click': (_) => setState(() => isSwapped = !isSwapped),
                },
                child: const Text('test'),
              );
            },
          ),
        );

        final buttonFinder = find.tag('button').first;

        expect(value1, equals(10));
        expect(value2, equals('abc'));
        expect(isSwapped, isFalse);
        expect(buildCount, 1);

        valueNotifier.updateIntValue(20);
        await tester.click(buttonFinder);
        await tester.pump();

        expect(value1, equals(20));
        expect(value2, equals('abc'));
        expect(isSwapped, isTrue);
        expect(buildCount, 2);

        valueNotifier.updateStringValue('def');
        await tester.click(buttonFinder);
        await tester.pump();

        expect(value1, equals(20));
        expect(value2, equals('def'));
        expect(isSwapped, isFalse);
        expect(buildCount, 3);
      },
    );
  });
}
