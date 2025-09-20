import 'package:jaspr/ui.dart';

import 'package:jaspr_grab/grab.dart';

class StatelessWithoutMixin extends StatelessComponent {
  const StatelessWithoutMixin({required this.funcCalledInBuild});

  final void Function(BuildContext) funcCalledInBuild;

  @override
  Component build(BuildContext context) {
    funcCalledInBuild(context);
    return const Component.empty();
  }
}

class StatefulWithoutMixin extends StatefulComponent {
  const StatefulWithoutMixin({required this.funcCalledInBuild});

  final void Function(BuildContext) funcCalledInBuild;

  @override
  State<StatefulWithoutMixin> createState() => _StatefulWithoutMixinState();
}

class _StatefulWithoutMixinState extends State<StatefulWithoutMixin> {
  @override
  Component build(BuildContext context) {
    component.funcCalledInBuild(context);
    return const Component.empty();
  }
}

class StatelessWithMixin extends StatelessComponent with Grab {
  const StatelessWithMixin({required this.funcCalledInBuild});

  final void Function(BuildContext) funcCalledInBuild;

  @override
  Component build(BuildContext context) {
    funcCalledInBuild(context);
    return const Component.empty();
  }
}

class StatefulWithMixin extends StatefulComponent with Grabful {
  const StatefulWithMixin({required this.funcCalledInBuild});

  final void Function(BuildContext) funcCalledInBuild;

  @override
  State<StatefulWithMixin> createState() => _StatefulWithMixinState();
}

class _StatefulWithMixinState extends State<StatefulWithMixin> {
  @override
  Component build(BuildContext context) {
    component.funcCalledInBuild(context);
    return const Component.empty();
  }
}
