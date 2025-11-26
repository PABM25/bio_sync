import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <--- IMPORTANTE
import '../../data/models/user.model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // <--- INSTANCIA

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

  // --- LOGIN CON GOOGLE (NUEVO) ---
  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Iniciar flujo interactivo
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return "Inicio de sesión cancelado";
      }

      // 2. Obtener detalles de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Crear credencial
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Entrar a Firebase
      await _auth.signInWithCredential(credential);

      // 5. Cargar perfil si existe
      await fetchUserProfile();

      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Error desconocido en Google Sign-In: $e";
    }
  }

  // Login con Email
  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await fetchUserProfile();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  // Registro con Email
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
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  // Guardar Perfil
  Future<void> saveUserProfile(UserProfile profile) async {
    if (_user == null) return;
    try {
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
      _userProfile = profileToSave;
      notifyListeners();
    } catch (e) {
      print("Error saving profile: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut(); // Cerrar también la sesión de Google
    await _auth.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }
}
