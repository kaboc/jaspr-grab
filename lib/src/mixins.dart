import 'package:jaspr/jaspr.dart';

import 'element.dart';
import 'errors.dart';
import 'types.dart';

/// A mixin used on [StatelessComponent] for making Grab available
/// in the component.
///
/// ```dart
/// class MyComponent extends StatelessComponent with StatelessGrabMixin {
///   ...
/// }
/// ```
///
/// You can use [Grab] instead of [StatelessGrabMixin]. It is just
/// a shorter alias.
///
/// {@template grab.alias.grab.example}
/// ```dart
/// class MyComponent extends StatelessComponent with Grab {
///   ...
/// }
/// ```
/// {@endtemplate}
///
/// {@template grab.mixin}
/// The [GrabMixinError] is thrown if either `grab()` or `grabAt()`
/// is used without this mixin.
/// {@endtemplate}
mixin StatelessGrabMixin on StatelessComponent {
  @override
  @nonVirtual
  StatelessElement createElement() => _StatelessElement(this);
}

class _StatelessElement extends StatelessElement with GrabElement {
  _StatelessElement(super.component);
}

/// A mixin used on a [StatefulComponent] for making Grab available
/// in the component.
///
/// ```dart
/// class MyComponent extends StatefulComponent with StatefulGrabMixin {
///   ...
/// }
/// ```
///
/// You can use [Grabful] instead of [StatefulGrabMixin]. It is just
/// a shorter alias.
///
/// {@template grab.alias.grabful.example}
/// ```dart
/// class MyComponent extends StatefulComponent with Grabful {
///   ...
/// }
/// ```
/// {@endtemplate}
///
/// {@macro grab.mixin}
mixin StatefulGrabMixin on StatefulComponent {
  @override
  @nonVirtual
  StatefulElement createElement() => _StatefulElement(this);
}

class _StatefulElement extends StatefulElement with GrabElement {
  _StatefulElement(super.component);
}
