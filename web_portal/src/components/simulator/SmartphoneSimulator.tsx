import React, { useState } from 'react';
import { 
  Clock, BookOpen, Compass, Shield, Sparkles, Coins, CheckCircle2, 
  Volume2, Play, ChevronLeft, ChevronRight, Bookmark, Award
} from 'lucide-react';

export const SmartphoneSimulator: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'prayer' | 'quran' | 'azkar' | 'rewards'>('prayer');
  const [tasbihCount, setTasbihCount] = useState(33);

  return (
    <div className="relative mx-auto w-full max-w-[340px] sm:max-w-[360px] aspect-[9/19] rounded-[48px] bg-slate-900 border-[10px] border-slate-800/90 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9),0_0_40px_rgba(53,81,174,0.3)] overflow-hidden flex flex-col select-none">
      
      {/* Top Dynamic Island / Speaker Notch */}
      <div className="absolute top-2.5 left-1/2 -translate-x-1/2 w-28 h-4.5 bg-black rounded-full z-30 flex items-center justify-center">
        <div className="w-2.5 h-2.5 rounded-full bg-slate-800/80 mr-3"></div>
        <div className="w-2 h-2 rounded-full bg-blue-950/60"></div>
      </div>

      {/* Screen Frame Content */}
      <div className="flex-1 bg-[#0b0f19] text-white flex flex-col pt-8 pb-3 px-3 overflow-hidden font-sans">
        
        {/* In-app Top Bar */}
        <div className="flex items-center justify-between pb-3 border-b border-white/5">
          <div className="flex items-center gap-2">
            <img src="/logo.png" alt="أركان" className="w-7 h-7 rounded-lg object-cover" />
            <span className="font-bold text-sm text-white">أركان</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1 px-2.5 py-1 rounded-full bg-gold-500/10 border border-gold-500/20 text-gold-400 text-xs font-bold">
              <span>🪙</span>
              <span>125</span>
            </div>
          </div>
        </div>

        {/* Screen Dynamic Body */}
        <div className="flex-1 overflow-y-auto py-3 space-y-3 no-scrollbar text-xs">
          
          {/* TAB 1: PRAYER & HOME */}
          {activeTab === 'prayer' && (
            <div className="space-y-3 animate-fadeIn">
              {/* Countdown Card */}
              <div className="rounded-2xl p-3.5 bg-gradient-to-br from-brand-600/40 via-brand-700/20 to-transparent border border-brand-500/30 relative overflow-hidden">
                <div className="flex justify-between items-start">
                  <div>
                    <span className="text-[10px] text-slate-300">الصلاة القادمة</span>
                    <h4 className="text-base font-extrabold text-white mt-0.5">صلاة المغرب</h4>
                    <p className="text-[11px] text-gold-400 font-semibold mt-1">متبقي 01:24:15</p>
                  </div>
                  <span className="text-2xl">🌅</span>
                </div>
                <div className="mt-3 flex items-center justify-between pt-2 border-t border-white/10 text-[10px] text-slate-400">
                  <span>الأذان: 06:12 م</span>
                  <span className="text-emerald-400 flex items-center gap-1 font-medium">
                    <CheckCircle2 className="w-3 h-3" /> تم تسجيل العصر
                  </span>
                </div>
              </div>

              {/* Today Prayers List */}
              <div className="space-y-1.5">
                {[
                  { name: 'الفجر', time: '04:18 ص', done: true, onTime: true },
                  { name: 'الظهر', time: '11:58 ص', done: true, onTime: true },
                  { name: 'العصر', time: '03:25 م', done: true, onTime: true },
                  { name: 'المغرب', time: '06:12 م', done: false, current: true },
                  { name: 'العشاء', time: '07:35 م', done: false },
                ].map((p, i) => (
                  <div 
                    key={i} 
                    className={`flex items-center justify-between p-2.5 rounded-xl border ${
                      p.current 
                        ? 'bg-brand-500/20 border-brand-500/50' 
                        : 'bg-white/[0.03] border-white/5'
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      <div className={`w-2 h-2 rounded-full ${p.done ? 'bg-emerald-400' : p.current ? 'bg-gold-400 animate-ping' : 'bg-slate-600'}`}></div>
                      <span className="font-semibold text-slate-200">{p.name}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-slate-400">{p.time}</span>
                      {p.done && <span className="text-[10px] text-emerald-400 font-bold">+5 كوينز</span>}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* TAB 2: QURAN */}
          {activeTab === 'quran' && (
            <div className="space-y-3 animate-fadeIn">
              <div className="p-3 rounded-2xl bg-amber-950/20 border border-amber-500/20">
                <div className="flex justify-between items-center mb-2">
                  <span className="font-bold text-slate-200">سورة الكهف</span>
                  <span className="text-[10px] text-gold-400 bg-gold-500/10 px-2 py-0.5 rounded-full">الجزء ١٥</span>
                </div>
                <div className="p-3 bg-amber-50/5 rounded-xl text-center font-quran text-sm leading-relaxed text-amber-100/90 border border-amber-400/10">
                  ٱلْحَمْدُ لِلَّهِ ٱلَّذِىٓ أَنزَلَ عَلَىٰ عَبْدِهِ ٱلْكِتَـٰبَ وَلَمْ يَجْعَل لَّهُۥ عِوَجَا ۜ ﴿١﴾
                </div>
                <div className="mt-2 flex items-center justify-between text-[11px] text-slate-400">
                  <span className="flex items-center gap-1 text-gold-400">
                    <Volume2 className="w-3.5 h-3.5" /> مشاري العفاسي
                  </span>
                  <span className="text-[10px] bg-white/10 px-2 py-0.5 rounded">الورد اليومي</span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div className="p-2.5 rounded-xl bg-white/[0.04] border border-white/5 flex flex-col justify-between">
                  <span className="text-slate-400 text-[10px]">الختمة الحالية</span>
                  <span className="font-extrabold text-sm text-white mt-1">ختمة رمضان</span>
                  <div className="w-full bg-slate-800 h-1.5 rounded-full mt-2 overflow-hidden">
                    <div className="bg-gold-500 h-full w-[45%]"></div>
                  </div>
                  <span className="text-[9px] text-slate-400 mt-1">صفحة 270 من 604</span>
                </div>

                <div className="p-2.5 rounded-xl bg-white/[0.04] border border-white/5 flex flex-col justify-between">
                  <span className="text-slate-400 text-[10px]">الملاحظات والتدبر</span>
                  <span className="font-extrabold text-sm text-white mt-1">12 خاطرة</span>
                  <span className="text-[9px] text-emerald-400 mt-2 flex items-center gap-1">
                    <Bookmark className="w-3 h-3" /> تم الحفظ محلياً
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* TAB 3: AZKAR & TASBIH */}
          {activeTab === 'azkar' && (
            <div className="space-y-3 animate-fadeIn text-center">
              <div className="p-4 rounded-2xl bg-gradient-to-b from-brand-600/20 to-transparent border border-brand-500/20">
                <span className="text-[10px] text-slate-400">المسبحة الإلكترونية الذكية</span>
                <h4 className="text-sm font-bold text-white mt-1">سُبْحَانَ اللَّهِ وَبِحَمْدِهِ</h4>
                
                {/* Interactive Bead */}
                <div 
                  onClick={() => setTasbihCount(c => c + 1)}
                  className="my-3 mx-auto w-20 h-20 rounded-full bg-gradient-to-tr from-gold-600 via-gold-400 to-amber-200 p-1 shadow-neon-gold active:scale-95 transition-transform cursor-pointer flex items-center justify-center text-slate-950 font-black text-xl"
                >
                  <div className="w-full h-full rounded-full bg-gradient-to-b from-amber-500 to-gold-600 flex items-center justify-center text-white text-2xl font-black shadow-inner">
                    {tasbihCount}
                  </div>
                </div>

                <span className="text-[10px] text-slate-400">انقر على الخرزة للتسبيح 📿</span>
              </div>

              <div className="grid grid-cols-2 gap-2 text-right">
                <div className="p-2.5 rounded-xl bg-white/[0.04] border border-white/5">
                  <span className="text-[10px] text-gold-400 font-bold">أذكار الصباح</span>
                  <p className="text-[9px] text-slate-400 mt-0.5">24 ذكراً مأثوراً</p>
                </div>
                <div className="p-2.5 rounded-xl bg-white/[0.04] border border-white/5">
                  <span className="text-[10px] text-gold-400 font-bold">أذكار المساء</span>
                  <p className="text-[9px] text-slate-400 mt-0.5">28 ذكراً مأثوراً</p>
                </div>
              </div>
            </div>
          )}

          {/* TAB 4: REWARDS */}
          {activeTab === 'rewards' && (
            <div className="space-y-3 animate-fadeIn">
              <div className="p-3.5 rounded-2xl bg-gradient-to-br from-gold-600/30 via-amber-700/20 to-transparent border border-gold-500/30">
                <div className="flex justify-between items-center">
                  <div>
                    <span className="text-[10px] text-gold-300">الرتبة الإيمانية</span>
                    <h4 className="text-sm font-black text-white mt-0.5">حريص على الطاعات 🕌</h4>
                  </div>
                  <div className="text-right">
                    <span className="text-[10px] text-slate-400">الرصيد الكلي</span>
                    <p className="text-base font-extrabold text-gold-400">125 كوينز</p>
                  </div>
                </div>
              </div>

              <div className="space-y-1.5">
                <span className="text-[10px] font-bold text-slate-400 px-1">الشارات المفتوحة</span>
                {[
                  { title: 'فجر الأبرار 🌅', desc: 'صلاة الفجر في وقتها 7 مرات', unlocked: true },
                  { title: 'حصن المسلم 🛡️', desc: 'إتمام 10 أقسام من الأذكار', unlocked: true },
                  { title: 'خاتم القرآن 👑', desc: 'ختمة كاملة للمصحف', unlocked: false },
                ].map((b, i) => (
                  <div key={i} className="flex items-center justify-between p-2 rounded-xl bg-white/[0.03] border border-white/5">
                    <div>
                      <span className="font-semibold text-slate-200 text-[11px]">{b.title}</span>
                      <p className="text-[9px] text-slate-400">{b.desc}</p>
                    </div>
                    {b.unlocked ? (
                      <span className="text-emerald-400 text-[10px] font-bold">مكتملة ✨</span>
                    ) : (
                      <span className="text-slate-500 text-[10px]">قيد التقدم</span>
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}

        </div>

        {/* Bottom Interactive Navigation Bar */}
        <div className="pt-2 border-t border-white/10 grid grid-cols-4 gap-1 text-center">
          {[
            { id: 'prayer', label: 'الرئيسية', icon: Clock },
            { id: 'quran', label: 'المصحف', icon: BookOpen },
            { id: 'azkar', label: 'الأذكار', icon: Shield },
            { id: 'rewards', label: 'المكافآت', icon: Award },
          ].map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`py-1.5 flex flex-col items-center gap-1 rounded-xl transition-all ${
                  isActive ? 'text-gold-400 bg-white/5 font-bold' : 'text-slate-500 hover:text-slate-300'
                }`}
              >
                <Icon className="w-4 h-4" />
                <span className="text-[9px]">{tab.label}</span>
              </button>
            );
          })}
        </div>

      </div>

      {/* Home Indicator Bar */}
      <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 w-32 h-1 bg-white/20 rounded-full"></div>
    </div>
  );
};
