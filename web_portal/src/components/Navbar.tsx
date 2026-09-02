import React, { useState } from 'react';
import { Download, Sparkles, Menu, X, ShieldCheck, Heart } from 'lucide-react';

export const Navbar: React.FC = () => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 glass-panel border-b border-white/10 bg-obsidian-950/80 backdrop-blur-xl">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          
          {/* Logo & App Brand */}
          <a href="#" className="flex items-center gap-3.5 group">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-brand-600 via-brand-500 to-gold-500 p-0.5 shadow-neon-blue group-hover:scale-105 transition-transform duration-300">
              <img 
                src="/logo.png" 
                alt="أركان" 
                className="w-full h-full object-cover rounded-[14px]"
              />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-2xl font-black tracking-tight text-white font-sans">أركان</span>
                <span className="px-2 py-0.5 text-[11px] font-bold bg-gold-500/20 text-gold-400 border border-gold-500/30 rounded-full">v1.0.0</span>
              </div>
              <p className="text-xs text-slate-400 font-medium">رفيقك اليومي للعبادات</p>
            </div>
          </a>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center gap-8 text-sm font-semibold text-slate-300">
            <a href="#features" className="hover:text-gold-400 transition-colors">المميزات</a>
            <a href="#simulator" className="hover:text-gold-400 transition-colors">معاينة التطبيق</a>
            <a href="#releases" className="hover:text-gold-400 transition-colors">مركز التحميل</a>
            <a href="#install-guide" className="hover:text-gold-400 transition-colors">طريقة التثبيت</a>
            <a href="#faq" className="hover:text-gold-400 transition-colors">الأسئلة الشائعة</a>
          </nav>

          {/* Action CTA */}
          <div className="hidden md:flex items-center gap-4">
            <span className="flex items-center gap-1.5 text-xs text-emerald-400 font-medium bg-emerald-500/10 px-3 py-1.5 rounded-full border border-emerald-500/20">
              <ShieldCheck className="w-4 h-4" />
              مجاني 100% وبدون إعلانات
            </span>
            <a
              href="#releases"
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-bold bg-gradient-to-r from-gold-500 to-amber-600 text-slate-950 hover:from-gold-400 hover:to-amber-500 shadow-neon-gold hover:shadow-gold-500/50 transform hover:-translate-y-0.5 transition-all duration-200"
            >
              <Download className="w-4 h-4" />
              <span>تحميل الآن</span>
            </a>
          </div>

          {/* Mobile menu toggle */}
          <div className="flex md:hidden items-center gap-3">
            <a
              href="#releases"
              className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg text-xs font-bold bg-gold-500 text-slate-950 shadow-md"
            >
              <Download className="w-3.5 h-3.5" />
              <span>تحميل</span>
            </a>
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 text-slate-400 hover:text-white rounded-lg focus:outline-none"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>

        {/* Mobile menu drawer */}
        {mobileMenuOpen && (
          <div className="md:hidden py-4 border-t border-white/10 space-y-3">
            <a 
              href="#features" 
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-white/5"
            >
              المميزات
            </a>
            <a 
              href="#simulator" 
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-white/5"
            >
              معاينة التطبيق
            </a>
            <a 
              href="#releases" 
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-white/5"
            >
              مركز التحميل
            </a>
            <a 
              href="#install-guide" 
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-white/5"
            >
              طريقة التثبيت
            </a>
            <a 
              href="#faq" 
              onClick={() => setMobileMenuOpen(false)}
              className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-white/5"
            >
              الأسئلة الشائعة
            </a>
          </div>
        )}
      </div>
    </header>
  );
};
