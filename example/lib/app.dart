import 'package:jaspr/jaspr.dart';
import 'package:jaspr_grab/grab.dart';

final ValueNotifier<int> _notifier = ValueNotifier(0);

class App extends StatefulComponent {
  const App();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return fragment([
      p(const [
        _Counter(),
        _SlowCounter(),
      ]),
      button(
        [text('Click!')],
        events: {'click': (_) => _notifier.value++},
      ),
    ]);
  }
}

class _Counter extends StatelessComponent with Grab {
  const _Counter();

  @override
  Component build(BuildContext context) {
    // With grab(), the widget is rebuilt every time
    // the value of the notifier is updated.
    final count = _notifier.grab(context);

    return span([text('$count')]);
  }
}

class _SlowCounter extends StatelessComponent with Grab {
  const _SlowCounter();

  @override
  Component build(BuildContext context) {
    // This count increases at one third the pace of the value
    // of the notifier, like 0, 0, 0, 1, 1, 1, 2, 2, 2...
    // Updating the value of the notifier doesn't trigger rebuilds
    // while the result of grabAt() here remains the same.
    final count = _notifier.grabAt(context, (v) => v ~/ 3);

    return span([text('$count')]);
  }
}
