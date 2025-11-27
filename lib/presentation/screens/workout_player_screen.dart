import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/workout_model.dart';
import '../../data/datasources/exercise_assets.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final List<Ejercicio> rutina;
  const WorkoutPlayerScreen({super.key, required this.rutina});
  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  int _currentIndex = 0;
  late FlutterTts flutterTts;
  Timer? _timer;
  int _timeLeft = 0;
  bool _isResting = false;
  bool _isCompleted = false;
  bool _isPaused = false;
  late ConfettiController _confettiController;
  final Color _darkBg = const Color(0xFF0F172A);
  final Color _accentColor = const Color(0xFFFACC15);

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _initTTS();
    _startExercise();
  }

  void _initTTS() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(0.5);
  }

  void _speak(String text) async => await flutterTts.speak(text);

  void _startExercise() {
    final ex = widget.rutina[_currentIndex];
    _speak("Vamos con ${ex.nombre}");
    setState(() {
      _isResting = false;
      _timeLeft = ex.esPorTiempo
          ? (ex.duracionSegundos > 0 ? ex.duracionSegundos : 45)
          : 0;
      if (ex.esPorTiempo) _startTimer();
    });
  }

  void _startRest() {
    final ex = widget.rutina[_currentIndex];
    int descanso = int.tryParse(ex.descanso) ?? 30;
    HapticFeedback.mediumImpact();
    _speak("Descansa $descanso segundos.");
    setState(() {
      _isResting = true;
      _timeLeft = descanso;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        if (_isResting)
          _nextExercise();
        else
          _startRest();
      }
    });
  }

  void _nextExercise() {
    if (_currentIndex < widget.rutina.length - 1) {
      setState(() => _currentIndex++);
      _startExercise();
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    HapticFeedback.heavyImpact();
    setState(() => _isCompleted = true);
    _confettiController.play();
    _speak("¡Rutina completada!");
  }

  @override
  void dispose() {
    _timer?.cancel();
    flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) return _buildCompletionScreen();
    final ejercicio = widget.rutina[_currentIndex];
    final String assetPath = ExerciseAssets.getAssetFor(ejercicio.nombre);
    final bool isNetwork = ExerciseAssets.isNetwork(assetPath);

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          if (!_isResting)
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: isNetwork
                    ? Image.network(assetPath, fit: BoxFit.cover)
                    : Image.asset(assetPath, fit: BoxFit.cover),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "${_currentIndex + 1} / ${widget.rutina.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isResting
                            ? "DESCANSO"
                            : ejercicio.nombre.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isResting ? Colors.greenAccent : Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      CircularPercentIndicator(
                        radius: 100.0,
                        lineWidth: 12.0,
                        percent: 1.0,
                        center: Text(
                          _isResting || ejercicio.esPorTiempo
                              ? "$_timeLeft"
                              : "${ejercicio.getDetalleParaUsuario("30s")}",
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        progressColor: _isResting ? Colors.green : _accentColor,
                        backgroundColor: Colors.white24,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (ejercicio.esPorTiempo)
                        FloatingActionButton(
                          heroTag: "pause",
                          backgroundColor: Colors.white24,
                          onPressed: () =>
                              setState(() => _isPaused = !_isPaused),
                          child: Icon(
                            _isPaused ? Icons.play_arrow : Icons.pause,
                          ),
                        ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _timer?.cancel();
                            if (_isResting)
                              _nextExercise();
                            else
                              _startRest();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            _isResting ? "¡A DARLE!" : "LISTO",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _darkBg,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  "¡ENTRENAMIENTO FINALIZADO!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("VOLVER AL MENU"),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
          ),
        ),
      ],
    );
  }
}
