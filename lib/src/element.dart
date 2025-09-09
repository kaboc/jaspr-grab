import 'package:jaspr/jaspr.dart';

import 'types.dart';

extension on Listenable {
  R listenableOrValue<R>() {
    final listenable = this;
    return (listenable is ValueListenable ? listenable.value : listenable) as R;
  }
}

class _Handler {
  const _Handler({
    required this.listenerRemover,
    required this.rebuildDeciders,
  });

  final VoidCallback listenerRemover;
  final List<ValueGetter<bool>> rebuildDeciders;

  void dispose() {
    listenerRemover();
    rebuildDeciders.clear();
  }
}

mixin GrabElement on BuildableElement {
  final Map<Listenable, _Handler> _handlers = {};

  @override
  void unmount() {
    _reset();
    super.unmount();
  }

  @override
  void performRebuild() {
    // Properties need to be cleared before every rebuild.
    // Note that resetting at the timing of markNeedsBuild() in
    // _listener() instead of here is not enough because _listener()
    // is not triggered by causes other than update of listenable value.
    _reset();

    // This must be after _reset(). Don't change the order.
    super.performRebuild();
  }

  void _reset() {
    _handlers
      ..forEach((_, handler) => handler.dispose())
      ..clear();
  }

  bool _shouldRebuild<R, S>(
    Listenable listenable,
    GrabSelector<R, S> selector,
    // The value as of the last rebuild.
    S? oldValue,
  ) {
    final newValue = selector(listenable.listenableOrValue());

    // If the selected value is the Listenable itself, it means
    // the user has chosen to make the component get rebuilt whenever
    // the listenable notifies, so true is returned in that case.
    return newValue == listenable || newValue != oldValue;
  }

  void _listener(Listenable listenable) {
    if (dirty) {
      return;
    }

    final rebuildDeciders = _handlers[listenable]?.rebuildDeciders ?? [];

    for (final shouldRebuild in rebuildDeciders) {
      if (shouldRebuild()) {
        markNeedsBuild();
        break;
      }
    }
  }

  S listen<R, S>({
    required Listenable listenable,
    required GrabSelector<R, S> selector,
  }) {
    _handlers.putIfAbsent(listenable, () {
      void listener() => _listener(listenable);
      listenable.addListener(listener);
      return _Handler(
        listenerRemover: () => listenable.removeListener(listener),
        rebuildDeciders: [],
      );
    });

    final value = selector(listenable.listenableOrValue());

    // There is no need to check whether the same function is
    // already in the list because it is cleared on every build.
    _handlers[listenable]?.rebuildDeciders.add(
      () => _shouldRebuild(listenable, selector, value),
    );

    return value;
  }
}
