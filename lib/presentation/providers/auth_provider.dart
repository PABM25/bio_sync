import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user.model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage; // Nueva variable para guardar errores

  User? get user => _firebaseUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; // Getter que buscaba la pantalla

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    if (firebaseUser != null) {
      await _fetchUserProfile();
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  // MODIFICADO: Ahora devuelve Future<bool>
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null; // Limpiamos errores previos
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Si no da error, asumimos éxito
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "Error desconocido";
      return false; // Falló
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MODIFICADO: Ahora devuelve Future<bool>
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "Error al registrarse";
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _db.collection('users').doc(profile.id).set(profile.toMap());
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      print("Error guardando perfil: $e");
    }
  }

  Future<void> _fetchUserProfile() async {
    if (_firebaseUser == null) return;
    try {
      final doc = await _db.collection('users').doc(_firebaseUser!.uid).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      print("Error leyendo perfil: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
