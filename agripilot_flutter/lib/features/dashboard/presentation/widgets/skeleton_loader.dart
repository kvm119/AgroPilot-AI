import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reusable skeleton loader for loading states
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _colorAnimation = ColorTween(
      begin: theme.colorScheme.surfaceContainerHighest,
      end: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Generic wrapper to handle AsyncValue states uniformly across cards
class CardStateWrapper<T> extends StatelessWidget {
  final AsyncValue<T> state;
  final Widget Function(T data) dataBuilder;
  final Widget loadingBuilder;
  final String cardTitle;

  const CardStateWrapper({
    super.key,
    required this.state,
    required this.dataBuilder,
    required this.loadingBuilder,
    required this.cardTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.when(
          data: dataBuilder,
          loading: () => loadingBuilder,
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 32),
                  const SizedBox(height: 8),
                  Text('Failed to load $cardTitle', style: TextStyle(color: theme.colorScheme.error)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
