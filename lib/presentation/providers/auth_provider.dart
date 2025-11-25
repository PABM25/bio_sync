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

  User? get user => _firebaseUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Escuchar cambios en la sesión (si cierra o abre la app)
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    if (firebaseUser != null) {
      // Si hay usuario, traemos sus datos de Firestore
      await _fetchUserProfile();
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  // Iniciar sesión con Email
  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // null significa éxito
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registrarse con Email
  Future<String?> register(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guardar datos del perfil (Peso, Altura, etc)
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _db.collection('users').doc(profile.id).set(profile.toMap());
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      print("Error guardando perfil: $e");
    }
  }

  // Leer datos del perfil
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
