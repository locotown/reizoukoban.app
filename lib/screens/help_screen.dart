import 'package:flutter/material.dart';

/// 使い方マニュアル画面
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text(
              '使い方ガイド',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アプリ紹介
            _buildIntroSection(),
            const SizedBox(height: 24),
            
            // 基本的な使い方
            _buildSectionTitle('📱 基本的な使い方'),
            const SizedBox(height: 12),
            _buildHelpCard(
              icon: '🏠',
              title: 'ホーム画面',
              description: '登録した食材の一覧と賞味期限の状況を確認できます。',
              steps: [
                '🚨 赤色: 期限切れの食材',
                '⚠️ オレンジ: 3日以内に期限が切れる食材',
                '✅ 緑色: まだ余裕のある食材',
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpCard(
              icon: '📝',
              title: '登録画面',
              description: '新しい食材を登録する画面です。',
              steps: [
                '1. 上部のタブで保存場所を選択（冷蔵/冷凍/常温）',
                '2. 種類を選択（肉類、野菜、フルーツなど）',
                '3. ワンタップで食材を追加',
              ],
            ),
            const SizedBox(height: 24),

            // 食材の追加方法
            _buildSectionTitle('➕ 食材の追加方法'),
            const SizedBox(height: 12),
            _buildHelpCard(
              icon: '⚡',
              title: 'ワンタップ追加',
              description: 'テンプレートから素早く食材を追加できます。',
              steps: [
                '1. 登録画面で種類を選択',
                '2. 表示されたテンプレートをタップ',
                '3. 自動的にデフォルト期限で追加されます',
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpCard(
              icon: '🆕',
              title: '新しいテンプレートを作成',
              description: 'よく使う食材をテンプレートとして登録できます。',
              steps: [
                '1. 種類を選択後「＋追加」ボタンをタップ',
                '2. アイコン、食材名、保存期限を設定',
                '3.「テンプレ登録して追加」をタップ',
                '→ テンプレートに保存され、食材も追加されます',
              ],
            ),
            const SizedBox(height: 24),

            // 食材の編集・削除
            _buildSectionTitle('✏️ 食材の編集・削除'),
            const SizedBox(height: 12),
            _buildHelpCard(
              icon: '📅',
              title: '賞味期限・名前の変更',
              description: '登録した食材の情報を編集できます。',
              steps: [
                '1. 食材カードをタップ',
                '2. 名前や賞味期限を変更',
                '3.「保存」をタップ',
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpCard(
              icon: '🗑️',
              title: '食材の削除',
              description: '使い切った食材や不要な食材を削除できます。',
              steps: [
                '食材カードを左にスワイプ → 削除',
              ],
            ),
            const SizedBox(height: 24),

            // テンプレート管理
            _buildSectionTitle('📁 テンプレート管理'),
            const SizedBox(height: 12),
            _buildHelpCard(
              icon: '🔖',
              title: 'マイテンプレート',
              description: '自分で作成したテンプレートを管理できます。',
              steps: [
                '1. ワンタップ追加エリアの「マイ(件数)」をタップ',
                '2. 一覧から編集・削除が可能',
                '※ テンプレートを長押しでも編集・削除メニューが表示されます',
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpCard(
              icon: '✨',
              title: 'カスタムテンプレートの見分け方',
              description: '自分で作成したテンプレートには目印がつきます。',
              steps: [
                '🔖 ブックマークアイコン付き',
                'オレンジの枠線で表示',
              ],
            ),
            const SizedBox(height: 24),

            // ステータスの見方
            _buildSectionTitle('📊 ステータスの見方'),
            const SizedBox(height: 12),
            _buildStatusGuide(),
            const SizedBox(height: 24),

            // Tips
            _buildSectionTitle('💡 便利なTips'),
            const SizedBox(height: 12),
            _buildTipsSection(),
            const SizedBox(height: 32),

            // バージョン情報
            _buildVersionInfo(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '冷蔵庫番',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '食品の賞味期限を簡単管理',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '冷蔵庫の中身を登録して、賞味期限を管理しましょう。\n期限が近づくと色で教えてくれるので、食品ロスを防げます。',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildHelpCard({
    required String icon,
    required String title,
    required String description,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.map((step) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  step,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    height: 1.4,
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusRow(
            color: const Color(0xFFE53935),
            icon: Icons.error,
            label: '期限切れ',
            description: '賞味期限を過ぎた食材です',
          ),
          const Divider(height: 24),
          _buildStatusRow(
            color: const Color(0xFFFF9800),
            icon: Icons.warning,
            label: 'もうすぐ期限',
            description: '3日以内に期限が切れます',
          ),
          const Divider(height: 24),
          _buildStatusRow(
            color: const Color(0xFF4CAF50),
            icon: Icons.check_circle,
            label: '余裕あり',
            description: '4日以上の余裕があります',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required Color color,
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    final tips = [
      {'icon': '🛒', 'tip': '買い物前にアプリをチェックして、必要なものを確認しましょう'},
      {'icon': '📸', 'tip': '買い物から帰ったら、すぐに食材を登録する習慣をつけましょう'},
      {'icon': '🔔', 'tip': 'ホーム画面で期限切れ（🚨）や警告（⚠️）の数を確認しましょう'},
      {'icon': '♻️', 'tip': '期限が近い食材から優先的に使って、食品ロスを防ぎましょう'},
      {'icon': '📁', 'tip': 'よく買う食材はテンプレート登録すると、次回から簡単に追加できます'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: tips.map((tip) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tip['icon']!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip['tip']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            '冷蔵庫番 v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
