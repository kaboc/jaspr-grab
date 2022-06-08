import 'package:jaspr/jaspr.dart';

import 'package:jaspr_grab/grab.dart';

class GrabStateless extends StatelessComponent with Grab {
  const GrabStateless({
    required this.listenable,
    required this.onBuild,
  });

  final Listenable listenable;
  final ValueChanged<Object> onBuild;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final value = context.grab<Object>(listenable);
    onBuild(value);
  }
}

class GrabAtStateless<R, S> extends StatelessComponent with Grab {
  const GrabAtStateless({
    required this.listenable,
    required this.selector,
    this.onBuild,
  });

  final Listenable listenable;
  final GrabSelector<R, S> selector;
  final ValueChanged<S>? onBuild;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final value = context.grabAt(listenable, selector);
    onBuild?.call(value);
  }
}

class MultiGrabAtsStateless<R, S1, S2> extends StatelessComponent {
  const MultiGrabAtsStateless({
    required this.listenable,
    required this.selector1,
    required this.selector2,
    required this.onBuild1,
    required this.onBuild2,
  });

  final Listenable listenable;
  final GrabSelector<R, S1> selector1;
  final GrabSelector<R, S2> selector2;
  final ValueChanged<S1> onBuild1;
  final ValueChanged<S2> onBuild2;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield GrabAtStateless(
      listenable: listenable,
      selector: selector1,
      onBuild: onBuild1,
    );
    yield GrabAtStateless(
      listenable: listenable,
      selector: selector2,
      onBuild: onBuild2,
    );
  }
}

class MultiListenablesStateless<R1, R2, S1, S2> extends StatelessComponent
    with Grab {
  const MultiListenablesStateless({
    required this.listenable1,
    required this.listenable2,
    required this.selector1,
    required this.selector2,
    this.onBuild,
  });

  final Listenable listenable1;
  final Listenable listenable2;
  final GrabSelector<R1, S1> selector1;
  final GrabSelector<R2, S2> selector2;
  final void Function(S1, S2)? onBuild;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final value1 = context.grabAt(listenable1, selector1);
    final value2 = context.grabAt(listenable2, selector2);
    onBuild?.call(value1, value2);
  }
}

class ExtOrderSwitchStateless<R, S1, S2> extends StatelessComponent with Grab {
  const ExtOrderSwitchStateless({
    required this.flagStream,
    required this.listenable,
    required this.selector1,
    required this.selector2,
    required this.onBuild,
  });

  final Stream<bool> flagStream;
  final Listenable listenable;
  final GrabSelector<R, S1> selector1;
  final GrabSelector<R, S2> selector2;
  final void Function(S1, S2, bool) onBuild;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield StreamBuilder<bool>(
      stream: flagStream,
      initialData: false,
      builder: (_, snapshot) sync* {
        final flag = snapshot.data!;
        late final S1 value1;
        late final S2 value2;

        if (flag) {
          value1 = context.grabAt(listenable, selector1);
          value2 = context.grabAt(listenable, selector2);
        } else {
          value2 = context.grabAt(listenable, selector2);
          value1 = context.grabAt(listenable, selector1);
        }
        onBuild.call(value1, value2, flag);
      },
    );
  }
}
