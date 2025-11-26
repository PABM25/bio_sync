import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/workout_model.dart';

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
  late ConfettiController _confettiController;

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

  void _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _startExercise() {
    final ex = widget.rutina[_currentIndex];
    _speak("Próximo ejercicio: ${ex.nombre}. ¡Vamos!");
    setState(() {
      _isResting = false;
      if (ex.esPorTiempo) {
        _timeLeft = ex.duracionSegundos > 0
            ? ex.duracionSegundos
            : 45; // Default
        _startTimer();
      } else {
        _timeLeft = 0;
      }
    });
  }

  void _startRest() {
    final ex = widget.rutina[_currentIndex];
    int descanso = int.tryParse(ex.descanso) ?? 30;
    _speak("Descansa por $descanso segundos.");
    setState(() {
      _isResting = true;
      _timeLeft = descanso;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        if (_isResting) {
          _nextExercise();
        } else {
          // Si era ejercicio por tiempo, pasamos a descanso automático
          _startRest();
        }
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
    setState(() => _isCompleted = true);
    _confettiController.play();
    _speak("¡Felicidades! Has completado tu entrenamiento de hoy.");
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
    final totalTime = _isResting
        ? (int.tryParse(ejercicio.descanso) ?? 30)
        : (ejercicio.duracionSegundos > 0 ? ejercicio.duracionSegundos : 45);

    double progress = _timeLeft > 0 ? _timeLeft / totalTime : 0.0;

    return Scaffold(
      backgroundColor: _isResting ? Colors.blueGrey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: _isResting ? Colors.transparent : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: _isResting ? Colors.white : Colors.black,
        ),
        title: Text(
          _isResting
              ? "DESCANSO"
              : "EJERCICIO ${_currentIndex + 1}/${widget.rutina.length}",
          style: TextStyle(
            color: _isResting ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Imagen o Animación
          if (!_isResting)
            Container(
              height: 250,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                // Aquí iría: image: NetworkImage(ejercicio.imageUrl ?? "")
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
            ),

          // Nombre y Detalles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              _isResting
                  ? "Siguiente: ${widget.rutina[_currentIndex + 1 < widget.rutina.length ? _currentIndex + 1 : _currentIndex].nombre}"
                  : ejercicio.nombre,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _isResting ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Timer Circular
          if (_isResting || ejercicio.esPorTiempo)
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              percent: progress.clamp(0.0, 1.0),
              center: Text(
                "$_timeLeft",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: _isResting ? Colors.white : Colors.black,
                ),
              ),
              progressColor: _isResting
                  ? Colors.greenAccent
                  : const Color(0xFF8B5CF6),
              backgroundColor: Colors.grey.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),

          // Botón de Acción
          Padding(
            padding: const EdgeInsets.all(30),
            child: ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                if (_isResting) {
                  _nextExercise();
                } else {
                  _startRest();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _isResting ? "OMITIR DESCANSO" : "TERMINADO",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  "¡Entrenamiento Terminado!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Volver al Inicio"),
                ),
              ],
            ),
          ),
        ),
        // CORRECCIÓN AQUÍ: Usamos 'alignment' en lugar de 'top'
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
