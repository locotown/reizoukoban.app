import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication管理サービス
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 現在のユーザー
  User? get currentUser => _auth.currentUser;

  /// 認証状態の変更を監視
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ユーザーIDを取得
  String? get userId => _auth.currentUser?.uid;

  /// 匿名ログイン（テスト用）
  Future<UserCredential?> signInAnonymously() async {
    try {
      if (kDebugMode) {
        print('🔐 匿名ログイン開始...');
      }
      final UserCredential userCredential = await _auth.signInAnonymously();
      if (kDebugMode) {
        print('✅ 匿名ログイン成功: ${userCredential.user?.uid}');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 予期しないエラー: $e');
      }
      throw 'エラーが発生しました: $e';
    }
  }

  /// メールアドレスでユーザー登録
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'エラーが発生しました: $e';
    }
  }

  /// メールアドレスでログイン
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'エラーが発生しました: $e';
    }
  }

  /// ログアウト
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'ログアウトに失敗しました: $e';
    }
  }

  /// パスワードリセットメール送信
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'エラーが発生しました: $e';
    }
  }

  /// Firebase Auth エラーハンドリング
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'パスワードが弱すぎます。6文字以上にしてください';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています';
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません';
      case 'user-not-found':
        return 'ユーザーが見つかりません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'user-disabled':
        return 'このアカウントは無効化されています';
      case 'too-many-requests':
        return 'リクエストが多すぎます。しばらくしてから再試行してください';
      case 'operation-not-allowed':
        return 'この操作は許可されていません';
      case 'invalid-credential':
        return 'メールアドレスまたはパスワードが間違っています';
      default:
        return 'エラーが発生しました: ${e.message}';
    }
  }
}
