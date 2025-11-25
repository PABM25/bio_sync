import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user.model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = true;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  // Verifica si debemos mostrar Onboarding o Main
  bool get hasCompletedOnboarding => _userProfile != null;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        // Si hay usuario, intentamos bajar su perfil de Firestore
        await fetchUserProfile();
      } else {
        _userProfile = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // Obtener datos de Firestore
  Future<void> fetchUserProfile() async {
    if (_user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
      } else {
        _userProfile =
            null; // Usuario existe en Auth pero no tiene datos (Nuevo)
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await fetchUserProfile(); // Cargar datos al entrar
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  // Registro
  Future<String?> register(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Al registrarse, _userProfile será null, lo que forzará el Onboarding
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  // Guardar Perfil (Se llama al finalizar el Onboarding o editar perfil)
  Future<void> saveUserProfile(UserProfile profile) async {
    if (_user == null) return;
    try {
      // Asegurar que el ID sea el del usuario actual
      final profileToSave = UserProfile(
        id: _user!.uid,
        email: _user!.email ?? '',
        name: profile.name,
        age: profile.age,
        weight: profile.weight,
        height: profile.height,
        gender: profile.gender,
        goal: profile.goal,
        level: profile.level,
      );

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .set(profileToSave.toMap());
      _userProfile = profileToSave; // Actualizar localmente
      notifyListeners();
    } catch (e) {
      print("Error saving profile: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }
}
