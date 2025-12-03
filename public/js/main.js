// ============================================
// 冷蔵庫番 - ランディングページ JavaScript
// ============================================

// DOMContentLoaded
document.addEventListener('DOMContentLoaded', function() {
  // モバイルメニュートグル
  initMobileMenu();
  
  // スクロールアニメーション
  initScrollReveal();
  
  // FAQアコーディオン
  initFAQ();
  
  // ヘッダースクロール効果
  initHeaderScroll();
  
  // スムーズスクロール
  initSmoothScroll();
});

// ========== モバイルメニュートグル ==========
function initMobileMenu() {
  const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
  const nav = document.querySelector('.nav');
  
  if (mobileMenuBtn && nav) {
    mobileMenuBtn.addEventListener('click', function() {
      nav.classList.toggle('active');
      
      // アイコン切り替え (☰ ⇔ ✕)
      const icon = this.textContent;
      this.textContent = icon === '☰' ? '✕' : '☰';
    });
    
    // メニューリンククリック時にメニューを閉じる
    const navLinks = nav.querySelectorAll('a');
    navLinks.forEach(link => {
      link.addEventListener('click', function() {
        nav.classList.remove('active');
        mobileMenuBtn.textContent = '☰';
      });
    });
  }
}

// ========== スクロールアニメーション ==========
function initScrollReveal() {
  const revealElements = document.querySelectorAll('.scroll-reveal');
  
  if (revealElements.length === 0) return;
  
  // Intersection Observer の設定
  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  };
  
  const observer = new IntersectionObserver(function(entries, observer) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        // 一度表示したら監視を解除 (パフォーマンス向上)
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);
  
  revealElements.forEach(element => {
    observer.observe(element);
  });
}

// ========== FAQアコーディオン ==========
function initFAQ() {
  const faqQuestions = document.querySelectorAll('.faq-question');
  
  faqQuestions.forEach(question => {
    question.addEventListener('click', function() {
      const answer = this.nextElementSibling;
      const isActive = this.classList.contains('active');
      
      // 他のFAQを全て閉じる
      faqQuestions.forEach(q => {
        q.classList.remove('active');
        q.nextElementSibling.classList.remove('active');
      });
      
      // クリックしたFAQをトグル
      if (!isActive) {
        this.classList.add('active');
        answer.classList.add('active');
      }
    });
  });
}

// ========== ヘッダースクロール効果 ==========
function initHeaderScroll() {
  const header = document.querySelector('.header');
  let lastScroll = 0;
  
  if (!header) return;
  
  window.addEventListener('scroll', function() {
    const currentScroll = window.pageYOffset;
    
    // スクロール時にシャドウを追加
    if (currentScroll > 100) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
    
    lastScroll = currentScroll;
  });
}

// ========== スムーズスクロール ==========
function initSmoothScroll() {
  const links = document.querySelectorAll('a[href^="#"]');
  
  links.forEach(link => {
    link.addEventListener('click', function(e) {
      const href = this.getAttribute('href');
      
      // # のみの場合はスキップ
      if (href === '#') {
        e.preventDefault();
        return;
      }
      
      const target = document.querySelector(href);
      
      if (target) {
        e.preventDefault();
        
        // ヘッダーの高さを考慮
        const headerHeight = document.querySelector('.header')?.offsetHeight || 0;
        const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - headerHeight;
        
        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });
      }
    });
  });
}

// ========== デバッグ用 (開発時のみ使用) ==========
// コンソールにランディングページ情報を表示
console.log('🍎 冷蔵庫番 - ランディングページ読み込み完了');
console.log('📱 デバイス幅:', window.innerWidth + 'px');
console.log('🖥️ ビューポート高さ:', window.innerHeight + 'px');

// パフォーマンス測定
window.addEventListener('load', function() {
  if ('performance' in window) {
    const perfData = window.performance.timing;
    const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
    console.log('⚡ ページロード時間:', (pageLoadTime / 1000).toFixed(2) + '秒');
  }
});

// ========== アプリ起動関数 ==========
// 「無料で始める」「デモを見る」ボタンクリック時の処理
function launchApp(mode) {
  const appUrl = '/app/';  // Flutter アプリのパス
  
  if (mode === 'demo') {
    // デモモード: 匿名ログイン用のクエリパラメータを追加
    window.location.href = appUrl + '?demo=true';
    console.log('🎮 デモモードで起動:', appUrl + '?demo=true');
  } else {
    // 通常モード: アプリのトップページに遷移
    window.location.href = appUrl;
    console.log('🚀 アプリ起動:', appUrl);
  }
}

// グローバルに公開 (HTMLから呼び出せるようにする)
window.launchApp = launchApp;

// ========== アナリティクス (オプション) ==========
// Google Analytics や Vercel Analytics を使用する場合はここに追加
// 例: gtag('config', 'GA_MEASUREMENT_ID');

// ========== エラーハンドリング ==========
window.addEventListener('error', function(e) {
  console.error('❌ JavaScript エラー:', e.message);
  // エラーログをサーバーに送信する処理を追加可能
});

// ========== サービスワーカー (PWA化する場合) ==========
// if ('serviceWorker' in navigator) {
//   navigator.serviceWorker.register('/sw.js')
//     .then(reg => console.log('Service Worker 登録成功:', reg))
//     .catch(err => console.error('Service Worker 登録失敗:', err));
// }
