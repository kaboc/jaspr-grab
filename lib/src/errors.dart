import 'extensions.dart';
import 'mixins.dart';
import 'types.dart';

/// Error thrown when `grab()` or `grabAt()` is used without a mixin,
/// either [StatelessGrabMixin] / [Grab] in a StatelessComponent or
/// [StatefulGrabMixin] / [Grabful] in a StatefulComponent.
class GrabMixinError extends Error {
  @override
  String toString() =>
      'GrabMixinError: `grab()` and `grabAt()` are only available '
      'in a StatelessComponent with the `StatelessGrabMixin`, or in the '
      'State of a StatefulComponent with the `StatefulGrabMixin`.\n'
      'Alternatively, you can use an alias for each: `Grab` for '
      'StatelessGrabMixin, and `Grabful` for StatefulGrabMixin.';
}
