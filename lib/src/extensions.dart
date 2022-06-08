import 'package:jaspr/jaspr.dart';

import 'element.dart';
import 'errors.dart';
import 'mixins.dart';
import 'types.dart';

/// Extensions on [BuildContext] used for Grab.
///
/// The BuildContext that the extension methods are used on has to be
/// a [GrabElement], meaning a Grab mixin must not be missing on the
/// component that the BuildContext belongs to.
///
/// {@template grab.extension}
/// ```dart
/// class Counter extends StatelessComponent with Grab {
///   @override
///   Iterable<Component> build(BuildContext context) sync* {
///     final count = context.grab<int>(counterNotifier);
///     yield DomComponent(
///       tag: 'span',
///       child: Text('$count'),
///     );
///   }
/// }
/// ```
///
/// [Grab] in the above example is an alias of [StatelessGrabMixin].
/// Similarly, [StatefulGrabMixin] has a shorter alias [Grabful] for
/// convenience.
///
/// ```dart
/// class Counter extends StatefulComponent with Grabful {
///   @override
///   State<Counter> createState() => _CounterState();
/// }
///
/// class _CounterState extends State<Counter> {
///   ...
/// }
/// ```
/// {@endtemplate}
extension GrabBuildContext on BuildContext {
  /// Returns an object of type [S], which is the [listenable] itself,
  /// or its value if the Listenable is a [ValueListenable].
  ///
  /// This method listens to the Listenable, and rebuilds the component
  /// that the [BuildContext] this method is used on belongs to,
  /// every time it is updated.
  ///
  /// {@macro grab.extension}
  S grab<S>(Listenable listenable) {
    return grabAt(
      listenable,
      (listenable) =>
          (listenable is ValueListenable ? listenable.value : listenable) as S,
    );
  }

  /// Returns an object of type [S] chosen with the [selector].
  ///
  /// This method listens to the [listenable], and rebuilds the component
  /// that the [BuildContext] this method is used on belongs to, every
  /// time there is a change in the value returned by the [selector].
  ///
  /// The callback of the selector receives an object of type [R].
  /// If the Listenable is a [ValueListenable], the object is its value.
  /// Otherwise, it is the Listenable itself.
  ///
  /// ```dart
  /// final notifier = ValueNotifier(
  ///   Item(name: 'Milk', quantity: 3),
  /// );
  /// ```
  ///
  /// ```dart
  /// class InventoryItem extends StatelessComponent with Grab {
  ///   @override
  ///   Iterable<Component> build(BuildContext context) sync* {
  ///     final name = context.grabAt(notifier, (Item item) => item.name);
  ///     yield DomComponent(
  ///       tag: 'span',
  ///       child: Text(name),
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// Instead of writing the concrete type of [R] in the parameter of
  /// the selector, the types of the Listenable and the object passed
  /// to the selector can be specified as below:
  ///
  /// ```dart
  /// context.grabAt<Item, String>(notifier, (item) => item.name);
  /// ```
  ///
  /// Note that the value to select can be anything as long as it is
  /// possible to evaluate its equality with the previous value with
  /// the `==` operator.
  ///
  /// ```dart
  /// final bool isEnough = context.grabAt(
  ///   notifier,
  ///   (Item item) => item.quantity > 5,
  /// );
  /// ```
  ///
  /// Supposing that the quantity was 3 in the previous build, if it
  /// is changed to 2, the component is not going to be rebuilt because
  /// `isEnough` remains false.
  S grabAt<R, S>(
    Listenable listenable,
    GrabSelector<R, S> selector,
  ) {
    final element = this;
    if (element is GrabElement) {
      return element.listen<R, S>(listenable: listenable, selector: selector);
    }

    throw GrabMixinError();
  }
}
