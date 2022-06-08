import 'package:jaspr/jaspr.dart';

import 'package:jaspr_grab/grab.dart';

class GrabStateful extends StatefulComponent with Grabful {
  const GrabStateful({
    required this.listenable,
    required this.onBuild,
  });

  final Listenable listenable;
  final ValueChanged<Object> onBuild;

  @override
  State<GrabStateful> createState() => _GrabState();
}

class _GrabState extends State<GrabStateful> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    final value = context.grab<Object>(component.listenable);
    component.onBuild(value);
  }
}

class GrabAtStateful<R, S> extends StatefulComponent with Grabful {
  const GrabAtStateful({
    required this.listenable,
    required this.selector,
    this.onBuild,
  });

  final Listenable listenable;
  final GrabSelector<R, S> selector;
  final ValueChanged<S>? onBuild;

  @override
  State<GrabAtStateful<R, S>> createState() => _GrabAtState<R, S>();
}

class _GrabAtState<R, S> extends State<GrabAtStateful<R, S>> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    final value = context.grabAt(component.listenable, component.selector);
    component.onBuild?.call(value);
  }
}

class MultiGrabAtsStateful<R, S1, S2> extends StatefulComponent {
  const MultiGrabAtsStateful({
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
  State<MultiGrabAtsStateful<R, S1, S2>> createState() =>
      _MultiGrabAtsState<R, S1, S2>();
}

class _MultiGrabAtsState<R, S1, S2>
    extends State<MultiGrabAtsStateful<R, S1, S2>> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield GrabAtStateful(
      listenable: component.listenable,
      selector: component.selector1,
      onBuild: component.onBuild1,
    );
    yield GrabAtStateful(
      listenable: component.listenable,
      selector: component.selector2,
      onBuild: component.onBuild2,
    );
  }
}

class MultiListenablesStateful<R1, R2, S1, S2> extends StatefulComponent
    with Grabful {
  const MultiListenablesStateful({
    required this.listenable1,
    required this.listenable2,
    required this.selector1,
    required this.selector2,
    required this.onBuild,
  });

  final Listenable listenable1;
  final Listenable listenable2;
  final GrabSelector<R1, S1> selector1;
  final GrabSelector<R2, S2> selector2;
  final void Function(S1, S2) onBuild;

  @override
  State<MultiListenablesStateful<R1, R2, S1, S2>> createState() =>
      _MultiListenablesState<R1, R2, S1, S2>();
}

class _MultiListenablesState<R1, R2, S1, S2>
    extends State<MultiListenablesStateful<R1, R2, S1, S2>> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    final value1 = context.grabAt(component.listenable1, component.selector1);
    final value2 = context.grabAt(component.listenable2, component.selector2);
    component.onBuild.call(value1, value2);
  }
}

class ExtOrderSwitchStateful<R, S1, S2> extends StatefulComponent with Grabful {
  const ExtOrderSwitchStateful({
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
  State<ExtOrderSwitchStateful<R, S1, S2>> createState() =>
      _ExtOrderSwitchState<R, S1, S2>();
}

class _ExtOrderSwitchState<R, S1, S2>
    extends State<ExtOrderSwitchStateful<R, S1, S2>> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield StreamBuilder<bool>(
      stream: component.flagStream,
      initialData: false,
      builder: (_, snapshot) sync* {
        final flag = snapshot.data!;
        late final S1 value1;
        late final S2 value2;

        if (flag) {
          value1 = context.grabAt(component.listenable, component.selector1);
          value2 = context.grabAt(component.listenable, component.selector2);
        } else {
          value2 = context.grabAt(component.listenable, component.selector2);
          value1 = context.grabAt(component.listenable, component.selector1);
        }
        component.onBuild.call(value1, value2, flag);
      },
    );
  }
}
