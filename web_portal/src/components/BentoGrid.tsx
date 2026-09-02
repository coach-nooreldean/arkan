import React from 'react';
import { 
  Clock, BookOpen, Sparkles, Shield, Coins, Compass, 
  Volume2, WifiOff, Smartphone, HeartHandshake, CheckCircle2 
} from 'lucide-react';

export const BentoGrid: React.FC = () => {
  return (
    <section id="features" className="py-24 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
      
      {/* Section Header */}
      <div className="text-center max-w-3xl mx-auto mb-16 space-y-4">
        <span className="px-4 py-1.5 rounded-full text-xs font-bold bg-brand-500/10 text-brand-400 border border-brand-500/20 inline-block">
          أركان الطاعة بين يديك 🌟
        </span>
        <h2 className="text-3xl sm:text-4xl lg:text-5xl font-black tracking-tight text-white font-sans">
          تطبيق إسلامي مصمم <span className="gold-gradient-text">بإتقان فائق</span> لراحتك
        </h2>
        <p className="text-base sm:text-lg text-slate-400 leading-relaxed">
          جميع ما يحتاجه المسلم في يومه وليلتة داخل تطبيق واحد أنيق، خفيف وسريع، يعمل بدون إنترنت ويحترم خصوصيتك بالكامل.
        </p>
      </div>

      {/* Bento Layout */}
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
        
        {/* Card 1: Prayer & Adhan (Large 2 Cols) */}
        <div className="md:col-span-2 glass-card p-8 rounded-3xl relative overflow-hidden flex flex-col justify-between group">
          <div className="absolute top-0 right-0 w-64 h-64 bg-brand-500/10 rounded-full blur-3xl -z-10 group-hover:bg-brand-500/20 transition-all duration-500"></div>
          <div>
            <div className="w-14 h-14 rounded-2xl bg-brand-500/20 border border-brand-500/30 flex items-center justify-center text-brand-400 mb-6 shadow-neon-blue">
              <Clock className="w-7 h-7" />
            </div>
            <h3 className="text-2xl font-bold text-white mb-3">مواقيت الصلاة والأذان الدقيق</h3>
            <p className="text-slate-400 text-sm leading-relaxed mb-6">
              حساب فلكي دقيق بـ 8 طرق حساب عالمية تشمل الهيئة المصرية للمساحة، أم القرى، ورابطة العالم الإسلامي. مع 4 أصوات أذان كاملة عالية النقاوة (مصر، المدينة المنورة، مكة المكرمة، وتكبيرات العيد).
            </p>
          </div>
          <div className="flex flex-wrap gap-2 pt-4 border-t border-white/10 text-xs font-semibold text-slate-300">
            <span className="px-3 py-1 bg-white/5 rounded-lg">تنبيهات في الموعد المحدد</span>
            <span className="px-3 py-1 bg-white/5 rounded-lg">دعم المدن و GPS</span>
            <span className="px-3 py-1 bg-white/5 rounded-lg">حساب أوقات الإقامة</span>
          </div>
        </div>

        {/* Card 2: Madani Quran (Large 2 Cols) */}
        <div className="md:col-span-2 glass-card p-8 rounded-3xl relative overflow-hidden flex flex-col justify-between group">
          <div className="absolute top-0 left-0 w-64 h-64 bg-gold-500/10 rounded-full blur-3xl -z-10 group-hover:bg-gold-500/20 transition-all duration-500"></div>
          <div>
            <div className="w-14 h-14 rounded-2xl bg-gold-500/20 border border-gold-500/30 flex items-center justify-center text-gold-400 mb-6 shadow-neon-gold">
              <BookOpen className="w-7 h-7" />
            </div>
            <h3 className="text-2xl font-bold text-white mb-3">المصحف الشريف المرتل</h3>
            <p className="text-slate-400 text-sm leading-relaxed mb-6">
              صفحات مصحف المدينة المنورة بجودة فائقة و3 أوضاع قراءة (عادي، داكن مريح للعين، وورق قديم). استمع لكبار القراء مع تظليل الآية المتزامنة تلقائياً، وتفسير ميسر وأسباب النزول.
            </p>
          </div>
          <div className="flex flex-wrap gap-2 pt-4 border-t border-white/10 text-xs font-semibold text-slate-300">
            <span className="px-3 py-1 bg-white/5 rounded-lg">الورد والختمات المتعددة</span>
            <span className="px-3 py-1 bg-white/5 rounded-lg">تلاوات صوتية كبار القراء</span>
            <span className="px-3 py-1 bg-white/5 rounded-lg">تدوين الملاحظات والتدبر</span>
          </div>
        </div>

        {/* Card 3: Offline & Privacy (1 Col) */}
        <div className="glass-card p-6 rounded-3xl flex flex-col justify-between">
          <div>
            <div className="w-12 h-12 rounded-xl bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center text-emerald-400 mb-4">
              <WifiOff className="w-6 h-6" />
            </div>
            <h4 className="text-lg font-bold text-white mb-2">أوفلاين وبلا إنترنت</h4>
            <p className="text-xs text-slate-400 leading-relaxed">
              كل الأحاديث والأذكار والأصوات ومواقيت الصلاة مدمجة محلياً 100% داخل التطبيق.
            </p>
          </div>
          <span className="text-xs font-semibold text-emerald-400 mt-4 flex items-center gap-1">
            <CheckCircle2 className="w-3.5 h-3.5" /> يعمل في أي مكان
          </span>
        </div>

        {/* Card 4: Smart Tasbih (1 Col) */}
        <div className="glass-card p-6 rounded-3xl flex flex-col justify-between">
          <div>
            <div className="w-12 h-12 rounded-xl bg-amber-500/20 border border-amber-500/30 flex items-center justify-center text-amber-400 mb-4">
              <Sparkles className="w-6 h-6" />
            </div>
            <h4 className="text-lg font-bold text-white mb-2">المسبحة الذكية</h4>
            <p className="text-xs text-slate-400 leading-relaxed">
              تسبيح تفاعلي باللمس مع خرز ثلاثي الأبعاد واهتزاز haptics وتحديد أهداف مخصصة.
            </p>
          </div>
          <span className="text-xs font-semibold text-amber-400 mt-4 flex items-center gap-1">
            <CheckCircle2 className="w-3.5 h-3.5" /> إحصائيات يومية
          </span>
        </div>

        {/* Card 5: Coins & Rewards (1 Col) */}
        <div className="glass-card p-6 rounded-3xl flex flex-col justify-between">
          <div>
            <div className="w-12 h-12 rounded-xl bg-yellow-500/20 border border-yellow-500/30 flex items-center justify-center text-yellow-400 mb-4">
              <Coins className="w-6 h-6" />
            </div>
            <h4 className="text-lg font-bold text-white mb-2">محفظة كوينز الطاعات</h4>
            <p className="text-xs text-slate-400 leading-relaxed">
              تحفيز روحاني لكسب كوينز عند الصلاة في وقتها، قراءة الورد، وإتمام الأذكار اليومية.
            </p>
          </div>
          <span className="text-xs font-semibold text-yellow-400 mt-4 flex items-center gap-1">
            <CheckCircle2 className="w-3.5 h-3.5" /> شارات ورتب إيمانية
          </span>
        </div>

        {/* Card 6: Zero Ads / Free Forever (1 Col) */}
        <div className="glass-card p-6 rounded-3xl flex flex-col justify-between">
          <div>
            <div className="w-12 h-12 rounded-xl bg-rose-500/20 border border-rose-500/30 flex items-center justify-center text-rose-400 mb-4">
              <Shield className="w-6 h-6" />
            </div>
            <h4 className="text-lg font-bold text-white mb-2">بدون إعلانات تماماً</h4>
            <p className="text-xs text-slate-400 leading-relaxed">
              تطبيق لوجه الله تعالى خالصاً، خالٍ من أي إعلانات مزعجة أو تعقب للخصوصية نهائياً.
            </p>
          </div>
          <span className="text-xs font-semibold text-rose-400 mt-4 flex items-center gap-1">
            <CheckCircle2 className="w-3.5 h-3.5" /> صدقة جارية
          </span>
        </div>

      </div>

    </section>
  );
};
