import React from 'react';
import { Download, ShieldCheck, CheckCircle2, AlertTriangle, ArrowLeft } from 'lucide-react';

export const InstallGuide: React.FC = () => {
  const steps = [
    {
      num: '01',
      title: 'تحميل ملف الـ APK المباشر',
      desc: 'انقر على زر التحميل بالأعلى لتنزيل ملف Arkan-1.0.0-universal.apk على هاتفك.',
      badge: 'الخطوة الأولى',
    },
    {
      num: '02',
      title: 'الموافقة على التثبيت',
      desc: 'إذا ظهرت لك رسالة أمان النظام "قد يكون الملف ضاراً"، اختر "تنزيل على أي حال" ثم فعّل خيار "السماح من هذا المصدر" في إعدادات المتصفح.',
      badge: 'إجراء طبيعي',
      note: 'نظام أندرويد يعرض هذا التنبيه دائماً لأي تطبيق يتم تثبيته خارج متجر جوجل بلاي.',
    },
    {
      num: '03',
      title: 'فتح التطبيق وبدء الاستخدام',
      desc: 'اضغط على "تثبيت (Install)" وافتح التطبيق فوراً. سيطلب منك التطبيق فقط إذن الموقع لتحديد مواقيت الصلاة واتجاه القبلة بدقة.',
      badge: 'جاهز للاستخدام',
    },
  ];

  return (
    <section id="install-guide" className="py-24 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
      
      <div className="glass-card p-8 sm:p-12 rounded-3xl border border-white/10 relative overflow-hidden">
        <div className="max-w-3xl mb-12">
          <span className="px-3.5 py-1 rounded-full text-xs font-bold bg-brand-500/10 text-brand-400 border border-brand-500/20 inline-block mb-3">
            دليل التثبيت السريع 📲
          </span>
          <h2 className="text-2xl sm:text-3xl lg:text-4xl font-black text-white">
            كيف تقوم بتثبيت التطبيق على هاتفك الأندرويد؟
          </h2>
          <p className="text-slate-400 text-sm sm:text-base mt-2">
            خطوات بسيطة جداً تستغرق أقل من دقيقة واحدة لتثبيت التطبيق وتشغيله بنجاح:
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {steps.map((s, idx) => (
            <div key={idx} className="relative p-6 rounded-2xl bg-white/[0.03] border border-white/5 flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between mb-4">
                  <span className="text-3xl font-black text-gold-500/40 font-mono">{s.num}</span>
                  <span className="text-[11px] font-bold text-slate-400 bg-white/5 px-2.5 py-1 rounded-full">
                    {s.badge}
                  </span>
                </div>
                <h4 className="text-base font-bold text-white mb-2">{s.title}</h4>
                <p className="text-xs text-slate-400 leading-relaxed">{s.desc}</p>
              </div>

              {s.note && (
                <div className="mt-4 p-2.5 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-start gap-2 text-[11px] text-amber-200/90">
                  <AlertTriangle className="w-4 h-4 shrink-0 text-amber-400 mt-0.5" />
                  <span>{s.note}</span>
                </div>
              )}
            </div>
          ))}
        </div>

        <div className="mt-10 pt-6 border-t border-white/10 flex flex-wrap items-center justify-between gap-4 text-xs text-slate-400">
          <span className="flex items-center gap-2 text-emerald-400 font-semibold">
            <ShieldCheck className="w-4 h-4" /> تطبيق آمن 100% وخالٍ من الفيروسات وأكواد التجسس
          </span>
          <a href="#releases" className="text-gold-400 hover:text-gold-300 font-bold flex items-center gap-1">
            الانتقال لروابط التنزيل <ArrowLeft className="w-3.5 h-3.5" />
          </a>
        </div>
      </div>

    </section>
  );
};
