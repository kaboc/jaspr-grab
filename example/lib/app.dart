import 'package:jaspr/jaspr.dart';
import 'package:jaspr_grab/grab.dart';

final _notifier = ValueNotifier(0);

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
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      children: [
        _Counter(),
        _SlowCounter(),
      ],
    );
    yield DomComponent(
      tag: 'button',
      events: {
        'click': (Object? e) => _notifier.value++,
      },
      child: Text('Click!'),
    );
  }
}

class _Counter extends StatelessComponent with Grab {
  const _Counter();

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // With context.grab(), the widget is rebuilt every time
    // the value of the notifier is updated.
    final count = context.grab<int>(_notifier);

    yield DomComponent(
      tag: 'span',
      child: Text('$count'),
    );
  }
}

class _SlowCounter extends StatelessComponent with Grab {
  const _SlowCounter();

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // This count increases at one third the pace of the value
    // of the notifier, like 0, 0, 0, 1, 1, 1, 2, 2, 2...
    // Updating the value of the notifier doesn't trigger rebuilds
    // while the result of grabAt() here remains the same.
    final count = context.grabAt(_notifier, (int v) => v ~/ 3);

    yield DomComponent(
      tag: 'span',
      child: Text('$count'),
    );
  }
}
