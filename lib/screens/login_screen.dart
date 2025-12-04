import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/supabase_auth_service.dart';
import 'signup_screen.dart';

// Web専用: URLクエリパラメータ取得用
import 'dart:html' as html show window;

/// ログイン画面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  /// デモモードチェックフラグをリセット（ログアウト時に呼び出す）
  static void resetDemoModeFlag() {
    _LoginScreenState._hasCheckedDemoModeGlobal = false;
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SupabaseAuthService _authService = SupabaseAuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  // デモモードチェックのためのstatic変数（Widget再構築でもリセットされない）
  static bool _hasCheckedDemoModeGlobal = false;

  @override
  void initState() {
    super.initState();
    _checkDemoMode();
  }

  /// デモモード検出と自動ログイン
  /// 
  /// ?demo=true の場合、デモ専用アカウントで自動ログイン
  /// デモアカウントにはサンプルデータがあらかじめ登録されています
  /// ログアウト後の再ログインを防ぐため、セッション中1回だけチェック
  Future<void> _checkDemoMode() async {
    // 既にチェック済みの場合はスキップ（ログアウト後の再実行防止）
    // static変数なのでWidget再構築でもリセットされない
    if (_hasCheckedDemoModeGlobal) {
      print('🔍 デモモードチェック: 既にチェック済み（スキップ）');
      return;
    }
    
    if (!kIsWeb) {
      print('🔍 デモモードチェック: Web以外のプラットフォーム');
      return;  // Web以外では実行しない
    }
    
    try {
      final currentUrl = html.window.location.href;
      print('🔍 現在のURL: $currentUrl');
      
      final uri = Uri.parse(currentUrl);
      print('🔍 クエリパラメータ: ${uri.queryParameters}');
      print('🔍 クエリ文字列: ${uri.query}');
      
      // 厳密なチェック: demo=true パラメータが存在する場合のみ
      final isDemoMode = uri.queryParameters['demo'] == 'true';
      print('🔍 デモモード判定: $isDemoMode');
      
      // チェック済みフラグを立てる（static変数で永続化）
      _hasCheckedDemoModeGlobal = true;
      
      // 既にログイン済みの場合は自動ログインしない（ログアウト対策）
      final isAlreadyLoggedIn = _authService.currentUser != null;
      print('🔍 ログイン状態: ${isAlreadyLoggedIn ? "ログイン済み" : "未ログイン"}');
      
      if (isDemoMode && !isAlreadyLoggedIn) {
        print('✅ デモモード検出！デモアカウントで自動ログイン開始...');
        // デモモードフラグが検出されたら自動的にデモアカウントでログイン実行
        await Future.delayed(const Duration(milliseconds: 800));  // UI表示待機
        if (mounted) {
          print('🚀 デモアカウントログイン実行中...');
          await _handleDemoLogin();
        }
      } else if (isDemoMode && isAlreadyLoggedIn) {
        print('ℹ️ デモモードだが既にログイン済み（再ログイン防止）');
      } else {
        print('ℹ️ 通常モード（デモモードではない）');
      }
    } catch (e) {
      // URLパラメータ取得エラー（モバイルビルドでは発生する可能性あり）
      print('❌ URLパラメータ取得エラー: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // ログイン成功 - AuthStateChangesで自動的にメイン画面に遷移
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // デモアカウントログイン処理
  Future<void> _handleDemoLogin() async {
    print('📝 デモアカウントログイン処理開始');
    setState(() => _isLoading = true);

    try {
      // デモ専用アカウントの認証情報
      const demoEmail = 'demo@reizoukoban.app';
      const demoPassword = 'DemoReizoukoban2024!';
      
      print('🔐 デモアカウント認証を実行...');
      await _authService.signInWithEmail(
        email: demoEmail,
        password: demoPassword,
      );
      print('✅ デモアカウントログイン成功！');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('デモモードでログインしました'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ デモアカウントログインエラー: $e');
      print('📧 試行したEmail: demo@reizoukoban.app');
      print('🔑 エラーの種類: ${e.runtimeType}');
      print('📝 エラーの詳細: ${e.toString()}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('デモモードのログインに失敗しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 匿名ログイン処理（通常のテスト用）
  Future<void> _handleAnonymousLogin() async {
    print('📝 匿名ログイン処理開始');
    setState(() => _isLoading = true);

    try {
      print('🔐 Supabase匿名認証を実行...');
      await _authService.signInAnonymously();
      print('✅ 匿名ログイン成功！');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('匿名ログインしました（テスト用）'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ 匿名ログインエラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // アプリアイコン画像
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 104,
                          height: 104,
                          fit: BoxFit.contain,  // contain に変更して全体を表示
                          errorBuilder: (context, error, stackTrace) {
                            // 画像読み込みエラー時はフォールバック絵文字
                            return const Center(
                              child: Text('🧊', style: TextStyle(fontSize: 60)),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // タイトル
                  const Text(
                    '冷蔵庫番',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '食材とストックの管理',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // メールアドレス入力
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'メールアドレス',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'メールアドレスを入力してください';
                      }
                      if (!value.contains('@')) {
                        return 'メールアドレスの形式が正しくありません';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // パスワード入力
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'パスワード',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'パスワードを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ログインボタン
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'ログイン',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // デモアカウントでログインボタン
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleDemoLogin,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text(
                        'デモを試す',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 新規登録リンク
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'アカウントをお持ちでない方',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '新規登録',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // TOPページに戻るリンク
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // TOPページに遷移
                        if (kIsWeb) {
                          html.window.location.href = 'https://reizoukoban.ideandtity.com/';
                        }
                      },
                      icon: const Icon(Icons.home_outlined, size: 18),
                      label: const Text(
                        'TOPページに戻る',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
