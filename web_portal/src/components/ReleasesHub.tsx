import React, { useState } from 'react';
import { 
  Download, Smartphone, Check, Sparkles, Cpu, ShieldCheck
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { DeviceInfo } from '../lib/deviceDetector';

interface ReleasesHubProps {
  deviceInfo: DeviceInfo;
}

export const ReleasesHub: React.FC<ReleasesHubProps> = ({ deviceInfo }) => {
  const [copiedLink, setCopiedLink] = useState<string | null>(null);

  const triggerConfetti = () => {
    confetti({
      particleCount: 80,
      spread: 60,
      origin: { y: 0.8 },
      colors: ['#F59E0B', '#3551AE', '#10B981', '#ffffff']
    });
  };

  const handleDownload = (filename: string, e?: React.MouseEvent) => {
    triggerConfetti();
  };

  const copyUrl = (url: string) => {
    navigator.clipboard.writeText(url);
    setCopiedLink(url);
    setTimeout(() => setCopiedLink(null), 2500);
  };

  // Only the 3 official Android APK release artifacts
  const releases = [
    {
      id: 'android-universal',
      title: 'أندرويد - ملف APK الشامل (Universal)',
      desc: 'النسخة الموصى بها للجميع: تعمل مباشرة على جميع هواتف وأجهزة أندرويد بدون استثناء.',
      file: 'Arkan-1.0.0-universal.apk',
      size: '67.4 MB',
      recommended: true,
      platform: 'android',
      icon: Smartphone,
      accent: 'gold',
    },
    {
      id: 'android-arm64',
      title: 'أندرويد - الهواتف الحديثة (ARM64-v8a)',
      desc: 'حجم خفيف جداً وأداء فائق مخصص لمعظم الهواتف الحديثة (64-bit).',
      file: 'Arkan-1.0.0-arm64-v8a.apk',
      size: '26.9 MB',
      recommended: false,
      platform: 'android',
      icon: Cpu,
      accent: 'blue',
    },
    {
      id: 'android-armv7',
      title: 'أندرويد - الهواتف القديمة (ARMv7a)',
      desc: 'نسخة خفيفة متوافقة تماماً مع معالجات الهواتف الاقتصادية والقديمة (32-bit).',
      file: 'Arkan-1.0.0-armeabi-v7a.apk',
      size: '24.9 MB',
      recommended: false,
      platform: 'android',
      icon: Smartphone,
      accent: 'emerald',
    },
  ];

  return (
    <section id="releases" className="py-24 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
      
      {/* Section Header */}
      <div className="text-center max-w-3xl mx-auto mb-16 space-y-4">
        <span className="px-4 py-1.5 rounded-full text-xs font-bold bg-gold-500/10 text-gold-400 border border-gold-500/20 inline-block">
          مركز التنزيل المباشر 📦
        </span>
        <h2 className="text-3xl sm:text-4xl lg:text-5xl font-black tracking-tight text-white font-sans">
          حمّل الإصدار الرسمي <span className="gold-gradient-text">v1.0.0</span>
        </h2>
        <p className="text-slate-400 text-base sm:text-lg">
          روابط تنزيل مباشرة وسريعة خالية تماماً من الإعلانات ومن الروابط المختصرة.
        </p>
      </div>

      {/* Recommended Device Banner */}
      <div className="glass-card p-6 sm:p-8 rounded-3xl mb-12 border-2 border-gold-500/40 relative overflow-hidden bg-gradient-to-r from-gold-500/10 via-brand-500/10 to-transparent">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
          <div className="flex items-center gap-5 text-center sm:text-right">
            <div className="w-16 h-16 rounded-2xl bg-gold-500/20 border border-gold-500/30 flex items-center justify-center text-gold-400 shadow-neon-gold shrink-0">
              <Sparkles className="w-8 h-8" />
            </div>
            <div>
              <div className="flex items-center justify-center sm:justify-start gap-2 mb-1">
                <span className="text-xs font-bold px-2.5 py-0.5 rounded-full bg-gold-500 text-slate-950">
                  النسخة المقترحة لجهازك
                </span>
                <span className="text-sm font-semibold text-slate-300">نظام {deviceInfo.label}</span>
              </div>
              <h3 className="text-xl font-bold text-white">تطبيق أركان — {deviceInfo.badge}</h3>
              <p className="text-xs text-slate-400 mt-1">جاهز للتثبيت الفوري والاستخدام أوفلاين</p>
            </div>
          </div>

          <a
            href={`https://github.com/coach-nooreldean/arkan/releases/download/v1.0.0/${deviceInfo.recommendedFile}`}
            onClick={(e) => handleDownload(deviceInfo.recommendedFile, e)}
            className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl text-base font-extrabold bg-gradient-to-r from-gold-500 via-amber-500 to-gold-600 text-slate-950 hover:from-gold-400 hover:to-amber-400 shadow-neon-gold hover:scale-[1.02] active:scale-95 transition-all duration-200"
          >
            <Download className="w-5 h-5" />
            <span>تحميل {deviceInfo.recommendedFile}</span>
          </a>
        </div>
      </div>

      {/* Grid of all downloads */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {releases.map((rel) => {
          const Icon = rel.icon;
          const downloadUrl = `https://github.com/coach-nooreldean/arkan/releases/download/v1.0.0/${rel.file}`;
          
          return (
            <div 
              key={rel.id} 
              id={rel.id.startsWith('android') ? 'download-android' : rel.id === 'windows' ? 'download-windows' : rel.id === 'linux' ? 'download-linux' : 'web-version'}
              className={`glass-card p-6 rounded-3xl flex flex-col justify-between border transition-all ${
                rel.recommended 
                  ? 'border-gold-500/50 bg-gold-500/[0.03] shadow-neon-gold' 
                  : 'border-white/10 hover:border-white/20'
              }`}
            >
              <div>
                <div className="flex items-start justify-between mb-4">
                  <div className="w-12 h-12 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-slate-200">
                    <Icon className="w-6 h-6" />
                  </div>
                  <span className="text-xs font-mono font-bold text-slate-400 px-2.5 py-1 bg-white/5 rounded-lg border border-white/5">
                    {rel.size}
                  </span>
                </div>

                <h4 className="text-lg font-bold text-white mb-2">{rel.title}</h4>
                <p className="text-xs text-slate-400 leading-relaxed mb-4">{rel.desc}</p>
                
                <div className="p-2 rounded-lg bg-black/40 border border-white/5 text-[11px] font-mono text-slate-300 truncate mb-6">
                  {rel.file}
                </div>
              </div>

              <div className="space-y-2 pt-4 border-t border-white/10">
                <a
                  href={downloadUrl}
                  onClick={(e) => handleDownload(rel.file, e)}
                  className="w-full py-2.5 px-4 rounded-xl text-xs font-bold flex items-center justify-center gap-2 bg-white/10 hover:bg-gold-500 hover:text-slate-950 text-white transition-colors duration-200"
                >
                  <Download className="w-4 h-4" />
                  <span>تحميل الملف المباشر</span>
                </a>
                
                <button
                  onClick={() => copyUrl(downloadUrl)}
                  className="w-full py-2 px-4 rounded-xl text-[11px] font-semibold flex items-center justify-center gap-1.5 text-slate-400 hover:text-white transition-colors"
                >
                  {copiedLink === downloadUrl ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-emerald-400" />
                      <span className="text-emerald-400">تم نسخ الرابط!</span>
                    </>
                  ) : (
                    <span>نسخ رابط التحميل</span>
                  )}
                </button>
              </div>
            </div>
          );
        })}
      </div>

    </section>
  );
};
