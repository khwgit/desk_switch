import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KvmDisplay {
  final String id;
  final String name;
  Offset position;
  final Size size;

  KvmDisplay({
    required this.id,
    required this.name,
    required this.position,
    required this.size,
  });

  KvmDisplay copyWith({Offset? position}) => KvmDisplay(
    id: id,
    name: name,
    position: position ?? this.position,
    size: size,
  );

  Rect get rect =>
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}

class KvmDisplayArrangement {
  final List<KvmDisplay> displays;

  KvmDisplayArrangement({required this.displays});

  KvmDisplayArrangement updateDisplay(String id, Offset newPosition) {
    return KvmDisplayArrangement(
      displays: displays
          .map((d) => d.id == id ? d.copyWith(position: newPosition) : d)
          .toList(),
    );
  }
}

class ArrangeDisplaysDialog extends HookConsumerWidget {
  final KvmDisplayArrangement initialArrangement;
  final void Function(KvmDisplayArrangement) onArrangementChanged;

  const ArrangeDisplaysDialog({
    required this.initialArrangement,
    required this.onArrangementChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State management with hooks
    final arrangement = useState(initialArrangement);
    final draggingId = useState<String?>(null);
    final dragStartPosition = useState<Offset?>(null);
    final displayStartPosition = useState<Offset?>(null);
    final touchingDisplays = useState<List<KvmDisplay>>([]);

    void onDragStart(String id, DragStartDetails details) {
      draggingId.value = id;
      dragStartPosition.value = details.localPosition;
      displayStartPosition.value = arrangement.value.displays
          .firstWhere((d) => d.id == id)
          .position;
      touchingDisplays.value = [];
    }

    double clampX(
      KvmDisplay touchDisplay,
      KvmDisplay draggedDisplay,
      double desiredX,
    ) {
      final minX = touchDisplay.position.dx - draggedDisplay.size.width + 1;
      final maxX = touchDisplay.position.dx + touchDisplay.size.width - 1;
      return desiredX.clamp(minX, maxX);
    }

    double clampY(
      KvmDisplay touchDisplay,
      KvmDisplay draggedDisplay,
      double desiredY,
    ) {
      final minY = touchDisplay.position.dy - draggedDisplay.size.height + 1;
      final maxY = touchDisplay.position.dy + touchDisplay.size.height - 1;
      return desiredY.clamp(minY, maxY);
    }

    void onDragUpdate(String id, DragUpdateDetails details) {
      if (draggingId.value != id ||
          dragStartPosition.value == null ||
          displayStartPosition.value == null) {
        return;
      }

      final draggedDisplay = arrangement.value.displays.firstWhere(
        (d) => d.id == id,
      );
      final otherDisplays = arrangement.value.displays
          .where((d) => d.id != id)
          .toList();

      // Calculate the desired position based on drag
      final desiredPosition =
          displayStartPosition.value! +
          (details.localPosition - dragStartPosition.value!);

      // Find all displays that would be touched by the dragged display at desired position
      final desiredRect = Rect.fromLTWH(
        desiredPosition.dx,
        desiredPosition.dy,
        draggedDisplay.size.width,
        draggedDisplay.size.height,
      );

      final touching = <KvmDisplay>[];
      for (final display in otherDisplays) {
        if (desiredRect.overlaps(display.rect)) {
          touching.add(display);
        }
      }

      touchingDisplays.value = touching;

      // If no touching displays, don't allow floating - keep original position
      if (touching.isEmpty) {
        return;
      }

      // Find the best position that touches at least one display without overlapping
      Offset bestPosition = draggedDisplay.position;
      double bestScore = double.infinity;

      for (final touchDisplay in touching) {
        // Try positioning on each edge of the touching display
        final edges = [
          // Left edge
          Offset(
            touchDisplay.position.dx - draggedDisplay.size.width,
            clampY(touchDisplay, draggedDisplay, desiredPosition.dy),
          ),
          // Right edge
          Offset(
            touchDisplay.position.dx + touchDisplay.size.width,
            clampY(touchDisplay, draggedDisplay, desiredPosition.dy),
          ),
          // Top edge
          Offset(
            clampX(touchDisplay, draggedDisplay, desiredPosition.dx),
            touchDisplay.position.dy - draggedDisplay.size.height,
          ),
          // Bottom edge
          Offset(
            clampX(touchDisplay, draggedDisplay, desiredPosition.dx),
            touchDisplay.position.dy + touchDisplay.size.height,
          ),
        ];

        for (final edgePosition in edges) {
          final edgeRect = Rect.fromLTWH(
            edgePosition.dx,
            edgePosition.dy,
            draggedDisplay.size.width,
            draggedDisplay.size.height,
          );

          // Check if this position overlaps with any other display
          bool overlaps = otherDisplays.any((d) => edgeRect.overlaps(d.rect));
          if (overlaps) continue;

          // Calculate distance score (closer to desired position is better)
          final distance = (edgePosition - desiredPosition).distance;
          if (distance < bestScore) {
            bestScore = distance;
            bestPosition = edgePosition;
          }
        }
      }

      // Update position if we found a valid one
      if (bestPosition != draggedDisplay.position) {
        arrangement.value = arrangement.value.updateDisplay(id, bestPosition);
        onArrangementChanged(arrangement.value);
      }
    }

    void onDragEnd(String id, DragEndDetails details) {
      draggingId.value = null;
      dragStartPosition.value = null;
      displayStartPosition.value = null;
      touchingDisplays.value = [];
    }

    return AlertDialog(
      title: const Text('Arrange Displays'),
      content: SizedBox(
        width: 500,
        height: 300,
        child: Stack(
          children: arrangement.value.displays.map((display) {
            final isDragging = display.id == draggingId.value;
            final isTouching = touchingDisplays.value.any(
              (d) => d.id == display.id,
            );

            return Positioned(
              left: display.position.dx,
              top: display.position.dy,
              child: GestureDetector(
                onPanStart: (details) => onDragStart(display.id, details),
                onPanUpdate: (details) => onDragUpdate(display.id, details),
                onPanEnd: (details) => onDragEnd(display.id, details),
                child: Container(
                  width: display.size.width,
                  height: display.size.height,
                  decoration: BoxDecoration(
                    color: isDragging
                        ? Colors.red
                        : isTouching
                        ? Colors.orange
                        : Colors.blueAccent,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(
                      color: isDragging ? Colors.red : Colors.grey,
                      width: isDragging ? 3 : 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    display.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
