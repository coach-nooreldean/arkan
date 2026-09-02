import React from 'react';
import { Heart, Github, Share2, Sparkles } from 'lucide-react';

export const Footer: React.FC = () => {
  const handleShare = () => {
    if (navigator.share) {
      navigator.share({
        title: 'تطبيق أركان الإسلامي',
        text: 'حمّل تطبيق أركان الإسلامي المجاني للقرآن ومواقيت الصلاة والأذكار بدون إنترنت:',
        url: window.location.href,
      }).catch(() => {});
    } else {
      navigator.clipboard.writeText(window.location.href);
      alert('تم نسخ رابط الموقع للمشاركة!');
    }
  };

  return (
    <footer className="border-t border-white/10 bg-obsidian-950/90 py-16 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-8 text-center md:text-right">
        
        {/* Brand & Slogan */}
        <div className="flex items-center gap-4">
          <img src="/logo.png" alt="أركان" className="w-12 h-12 rounded-2xl object-cover shadow-neon-blue" />
          <div>
            <div className="flex items-center justify-center md:justify-start gap-2">
              <span className="text-xl font-black text-white">أركان</span>
              <span className="text-xs text-gold-400 bg-gold-500/10 px-2 py-0.5 rounded-full border border-gold-500/20 font-bold">صدقة جارية</span>
            </div>
            <p className="text-xs text-slate-400 mt-1">تطبيق إسلامي خالص لوجه الله تعالى — صدقة جارية</p>
          </div>
        </div>

        {/* Share & Open Source links */}
        <div className="flex items-center gap-4">
          <button
            onClick={handleShare}
            className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-white/5 hover:bg-white/10 text-slate-300 border border-white/10 transition-colors"
          >
            <Share2 className="w-4 h-4 text-gold-400" />
            <span>انشر ولك الأجر والدال على الخير كفاعله</span>
          </button>

          <a
            href="https://github.com/coach-nooreldean/arkan"
            target="_blank"
            rel="noreferrer"
            className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-white/5 hover:bg-white/10 text-slate-300 border border-white/10 transition-colors"
          >
            <Github className="w-4 h-4" />
            <span>كود المشروع</span>
          </a>
        </div>

      </div>

      <div className="max-w-7xl mx-auto mt-12 pt-6 border-t border-white/5 text-center text-xs text-slate-500 flex flex-col sm:flex-row items-center justify-between gap-4">
        <p>© {new Date().getFullYear()} تطبيق أركان. وقف إسلامي مجاني لجميع المسلمين حول العالم.</p>
        <p className="flex items-center gap-1">
          صُنع بـ <Heart className="w-3.5 h-3.5 text-rose-500 fill-rose-500" /> لخدمة كتاب الله وسنة رسوله ﷺ
        </p>
      </div>
    </footer>
  );
};
