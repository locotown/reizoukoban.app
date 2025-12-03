import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';
import 'storage_service.dart';

/// Supabase Authentication管理サービス
class SupabaseAuthService {
  /// 現在のユーザー
  User? get currentUser => supabase.auth.currentUser;

  /// 認証状態の変更を監視
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// ユーザーIDを取得
  String? get userId => supabase.auth.currentUser?.id;

  /// 匿名ログイン
  Future<AuthResponse> signInAnonymously() async {
    try {
      if (kDebugMode) {
        print('🔐 匿名ログイン開始...');
      }
      final response = await supabase.auth.signInAnonymously();
      if (kDebugMode) {
        print('✅ 匿名ログイン成功: ${response.user?.id}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 匿名ログインエラー: $e');
      }
      rethrow;
    }
  }

  /// メールアドレスでユーザー登録
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 ユーザー登録開始: $email');
      }
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print('✅ ユーザー登録成功: ${response.user?.id}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ユーザー登録エラー: $e');
      }
      throw _handleAuthException(e);
    }
  }

  /// メールアドレスでログイン
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 ログイン開始: $email');
      }
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print('✅ ログイン成功: ${response.user?.id}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ログインエラー: $e');
      }
      throw _handleAuthException(e);
    }
  }

  /// ログアウト
  Future<void> signOut() async {
    try {
      // ローカルストレージをクリア（ユーザーデータ分離のため）
      try {
        StorageService.clearUserData();
        if (kDebugMode) {
          print('🗑️ ローカルストレージをクリアしました');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ ローカルストレージクリア警告: $e');
        }
      }

      await supabase.auth.signOut();
      if (kDebugMode) {
        print('✅ ログアウト成功');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ログアウトエラー: $e');
      }
      throw 'ログアウトに失敗しました: $e';
    }
  }

  /// Supabase エラーハンドリング
  String _handleAuthException(dynamic e) {
    final errorMessage = e.toString().toLowerCase();
    
    if (errorMessage.contains('invalid login credentials') ||
        errorMessage.contains('invalid_credentials')) {
      return 'メールアドレスまたはパスワードが間違っています';
    } else if (errorMessage.contains('user already registered') ||
               errorMessage.contains('already_registered')) {
      return 'このメールアドレスは既に使用されています';
    } else if (errorMessage.contains('invalid email') ||
               errorMessage.contains('invalid_email')) {
      return 'メールアドレスの形式が正しくありません';
    } else if (errorMessage.contains('password is too short') ||
               errorMessage.contains('weak_password')) {
      return 'パスワードが短すぎます。6文字以上にしてください';
    } else if (errorMessage.contains('email not confirmed')) {
      return 'メールアドレスが確認されていません';
    } else if (errorMessage.contains('network')) {
      return 'ネットワークエラーが発生しました';
    }
    
    return 'エラーが発生しました: $e';
  }
}
