import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../main.dart'; // AnimalData

// ─── Shared state ─────────────────────────────────────────────────────────────
class ARState {
  bool objectPlaced = false;
  ARNode? animalNode;
  ARPlaneAnchor? animalAnchor;
  ARObjectManager? objectManager;
  ARAnchorManager? anchorManager;
  double modelScale = 0.2;
  bool _isUpdating = false;

  VoidCallback? onPlaced;
  VoidCallback? onNodeTapped;
  VoidCallback? onPlaneDetected;

  Future<void> updateScale(double newScale) async {
    if (animalNode == null || objectManager == null || animalAnchor == null)
      return;
    if (_isUpdating) return;
    _isUpdating = true;
    modelScale = newScale.clamp(0.05, 1.5);
    try {
      await objectManager!.removeNode(animalNode!);
      animalNode!.scale = Vector3.all(modelScale);
      await objectManager!.addNode(animalNode!, planeAnchor: animalAnchor!);
    } catch (e) {
      debugPrint('Error updating scale: $e');
    } finally {
      _isUpdating = false;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AR SCENE PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class ARScenePage extends StatefulWidget {
  final AnimalData animal;
  const ARScenePage({super.key, required this.animal});
  @override
  State<ARScenePage> createState() => _ARScenePageState();
}

class _ARScenePageState extends State<ARScenePage>
    with SingleTickerProviderStateMixin {
  final ARState _arState = ARState();
  bool _objectPlaced = false;
  bool _showInfoCard = false;
  bool _planeDetected = false;
  bool _showInstructions = true;
  double _baseScale = 0.2; // overridden per-animal on placement

  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    _arState.onPlaced = () {
      if (mounted)
        setState(() {
          _objectPlaced = true;
          _showInstructions = false;
        });
    };
    _arState.onNodeTapped = () {
      if (mounted) {
        setState(() => _showInfoCard = true);
        _cardController.forward(from: 0);
      }
    };
    _arState.onPlaneDetected = () {
      if (mounted && !_planeDetected) {
        setState(() => _planeDetected = true);
        HapticFeedback.lightImpact();
      }
    };

    // Hide instructions after 5 seconds if not interacted
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showInstructions && !_objectPlaced) {
        setState(() => _showInstructions = false);
      }
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _zoom(double delta) {
    if (!_objectPlaced) return;
    final newScale = (_arState.modelScale + delta).clamp(0.05, 1.5);
    _arState.updateScale(newScale);
    _baseScale = newScale;
    HapticFeedback.selectionClick();
  }

  void _resetScene() {
    HapticFeedback.selectionClick();
    if (_arState.animalNode != null) {
      _arState.objectManager?.removeNode(_arState.animalNode!);
      _arState.animalNode = null;
    }
    _arState.objectPlaced = false;
    _arState.animalAnchor = null;
    _arState.modelScale = widget.animal.initialScale;
    _baseScale = widget.animal.initialScale;
    setState(() {
      _objectPlaced = false;
      _showInfoCard = false;
      _showInstructions = true;
      _planeDetected = false;
    });
    _cardController.reset();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: widget.animal.color),
            const SizedBox(width: 12),
            const Text('AR Instructions',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _instructionItem(
                '📱', 'Move phone slowly', 'Scan the floor or table'),
            const SizedBox(height: 12),
            _instructionItem(
                '🎯', 'Look for dots', 'White dots = surface detected'),
            const SizedBox(height: 12),
            _instructionItem('👆', 'Tap to place', 'Tap anywhere on the dots'),
            const SizedBox(height: 12),
            _instructionItem(
                '🤏', 'Pinch to resize', 'Use two fingers to scale'),
            const SizedBox(height: 12),
            _instructionItem('ℹ️', 'Tap for info', 'Tap the animal to learn'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.animal.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.animal.color.withOpacity(0.3)),
              ),
              child: Text(
                '💡 Tip: Works best on plain, well-lit surfaces',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(
                color: widget.animal.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionItem(String emoji, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── AR view ────────────────────────────────────────────────
          RepaintBoundary(
            child: _ARViewWidget(
              key: ValueKey(
                  animal.name), // ← forces full rebuild on animal change
              arState: _arState,
              animal: animal,
            ),
          ),

          // ── Pinch zoom gesture layer ───────────────────────────────
          if (_objectPlaced)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onScaleStart: (_) => _baseScale = _arState.modelScale,
                onScaleUpdate: (details) {
                  if (details.pointerCount < 2) return;
                  _arState.updateScale(_baseScale * details.scale);
                },
                child: const SizedBox.expand(),
              ),
            ),

          // ── Top gradient ───────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Top bar ────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _glassButton(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: animal.color.withOpacity(0.5)),
                    ),
                    child: Row(children: [
                      Text(animal.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(animal.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          )),
                    ]),
                  ),
                  const Spacer(),
                  _glassButton(
                    onTap: _showHelpDialog,
                    child: const Icon(Icons.help_outline,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  _glassButton(
                    onTap: _resetScene,
                    child: const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // ── Instruction overlay (when no object placed) ────────────
          if (_showInstructions && !_objectPlaced)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => setState(() => _showInstructions = false),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: animal.color.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: animal.color.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: animal.color, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          _planeDetected
                              ? 'Perfect! Now tap to place ${animal.name}'
                              : 'Move your phone slowly\nto find a flat surface',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _planeDetected
                              ? 'Look for the white dots'
                              : 'Point at floor or table',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to dismiss',
                          style: TextStyle(
                            color: animal.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Scanner animation ──────────────────────────────────────
          if (!_objectPlaced && !_planeDetected)
            _ScannerOverlay(color: animal.color),

          // ── Placement indicator (when plane detected) ──────────────
          if (!_objectPlaced && _planeDetected)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: animal.color,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: animal.color.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text(
                        'Tap on the dots to place',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Zoom +/- buttons ───────────────────────────────────────
          if (_objectPlaced)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _zoomBtn(Icons.add, animal.color, () => _zoom(0.05)),
                    const SizedBox(height: 8),
                    Container(
                      width: 44,
                      height: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 8),
                    _zoomBtn(Icons.remove, animal.color, () => _zoom(-0.05)),
                  ],
                ),
              ),
            ),

          // ── Control hints (when object placed) ─────────────────────
          if (_objectPlaced && !_showInfoCard)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _hintChip('🤏 Pinch to resize', animal.color),
                  const SizedBox(width: 12),
                  _hintChip('👆 Tap for info', animal.color),
                ],
              ),
            ),

          // ── Bottom gradient ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xDD000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Info card (when tapped) ────────────────────────────────
          if (_showInfoCard)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(_cardAnimation),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(28),
                        border:
                            Border.all(color: animal.color.withOpacity(0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: animal.color.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: animal.color.withOpacity(0.15),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: animal.color.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(animal.emoji,
                                      style: const TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(animal.name,
                                          style: TextStyle(
                                            color: animal.color,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text(animal.scientificName,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          )),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _showInfoCard = false),
                                  icon: Icon(Icons.close_rounded,
                                      color: animal.color),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fun Facts',
                                    style: TextStyle(
                                      color: animal.color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                                const SizedBox(height: 10),
                                ...animal.facts.map((f) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 6),
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: animal.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(f,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  height: 1.4,
                                                )),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: animal.conservationStatusColor
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _PulsingDot(
                                      color: animal.conservationStatusColor),
                                  const SizedBox(width: 10),
                                  Text('Conservation Status: ',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      )),
                                  Text(animal.conservationStatus,
                                      style: TextStyle(
                                        color: animal.conservationStatusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _glassButton({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _zoomBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _hintChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AR VIEW WIDGET
// ═══════════════════════════════════════════════════════════════════════════════
class _ARViewWidget extends StatefulWidget {
  final ARState arState;
  final AnimalData animal;
  const _ARViewWidget({super.key, required this.arState, required this.animal});

  @override
  State<_ARViewWidget> createState() => _ARViewWidgetState();
}

class _ARViewWidgetState extends State<_ARViewWidget> {
  ARSessionManager? _sessionManager;
  ARObjectManager? _objectManager;

  @override
  void dispose() {
    _sessionManager?.dispose();
    // Clear stale manager refs so the new session starts clean
    widget.arState.objectManager = null;
    widget.arState.anchorManager = null;
    widget.arState.animalNode = null;
    widget.arState.animalAnchor = null;
    widget.arState.objectPlaced = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ARView(
      onARViewCreated: _onARViewCreated,
      planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
    );
  }

  void _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    _sessionManager = sessionManager;
    _objectManager = objectManager;

    widget.arState.objectManager = objectManager;
    widget.arState.anchorManager = anchorManager;

    try {
      sessionManager.onInitialize(
        showFeaturePoints: false,
        showPlanes: true,
        handleTaps: true,
      );
      objectManager.onInitialize();

      sessionManager.onPlaneOrPointTap = _onPlaneTapped;
      _objectManager!.onNodeTap = _onNodeTapped;

      // Trigger plane detected callback after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        widget.arState.onPlaneDetected?.call();
      });

      debugPrint('✅ AR Session initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing AR session: $e');
    }
  }

  Future<void> _onPlaneTapped(List<ARHitTestResult> hits) async {
    final arState = widget.arState;
    if (arState.objectPlaced || hits.isEmpty) return;

    debugPrint('🎯 Plane tapped with ${hits.length} hits');
    arState.objectPlaced = true;

    final hit = hits.firstWhere(
      (h) => h.type == ARHitTestResultType.plane,
      orElse: () => hits.first,
    );

    final anchor = ARPlaneAnchor(transformation: hit.worldTransform);
    final anchorAdded = await arState.anchorManager?.addAnchor(anchor);

    if (anchorAdded == true) {
      debugPrint('⚓ Anchor added, loading model: ${widget.animal.glbPath}');

      // Use per-animal initial scale so every model appears at a similar size
      arState.modelScale = widget.animal.initialScale;

      final node = ARNode(
        type: NodeType.localGLTF2,
        uri: widget.animal.glbPath,
        scale: Vector3.all(arState.modelScale),
        position: Vector3(0.0, 0.0, 0.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      );

      try {
        final nodeAdded =
            await _objectManager!.addNode(node, planeAnchor: anchor);

        if (nodeAdded == true) {
          debugPrint('✅ Node added successfully');
          arState.animalNode = node;
          arState.animalAnchor = anchor;
          HapticFeedback.mediumImpact();
          arState.onPlaced?.call();
        } else {
          debugPrint('❌ Failed to add node');
          arState.objectPlaced = false;
        }
      } catch (e) {
        debugPrint('❌ Error adding node: $e');
        arState.objectPlaced = false;
      }
    } else {
      debugPrint('❌ Failed to add anchor');
      arState.objectPlaced = false;
    }
  }

  void _onNodeTapped(List<String> nodeNames) {
    final arState = widget.arState;
    debugPrint('🖱️ Node tapped: $nodeNames');

    if (arState.animalNode != null && nodeNames.isNotEmpty) {
      HapticFeedback.lightImpact();
      arState.onNodeTapped?.call();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCANNER OVERLAY
// ═══════════════════════════════════════════════════════════════════════════════
class _ScannerOverlay extends StatefulWidget {
  final Color color;
  const _ScannerOverlay({required this.color});
  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          size: const Size(200, 200),
          painter: _ScannerPainter(_ctrl.value, widget.color),
        ),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ScannerPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    final bp = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const cs = 20.0;
    final corners = [
      Offset(center.dx - radius + 10, center.dy - radius + 10),
      Offset(center.dx + radius - 10, center.dy - radius + 10),
      Offset(center.dx - radius + 10, center.dy + radius - 10),
      Offset(center.dx + radius - 10, center.dy + radius - 10),
    ];
    for (int i = 0; i < corners.length; i++) {
      final c = corners[i];
      final xd = (i % 2 == 0) ? 1.0 : -1.0;
      final yd = (i < 2) ? 1.0 : -1.0;
      canvas.drawLine(c, Offset(c.dx + xd * cs, c.dy), bp);
      canvas.drawLine(c, Offset(c.dx, c.dy + yd * cs), bp);
    }

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = SweepGradient(
            colors: [Colors.transparent, color],
            transform: GradientRotation(progress * 2 * 3.14159),
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_ScannerPainter o) =>
      o.progress != progress || o.color != color;
}

// ── Pulsing Dot ───────────────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_anim.value),
        ),
      ),
    );
  }
}
