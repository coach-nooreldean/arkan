import React, { useState, useEffect } from 'react';
import { 
  Download, Sparkles, Smartphone, ShieldCheck, WifiOff, 
  ArrowLeft, Star, Heart, CheckCircle2, Play
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { detectDevice, DeviceInfo } from '../lib/deviceDetector';
import { Navbar } from '../components/Navbar';
import { SmartphoneSimulator } from '../components/simulator/SmartphoneSimulator';
import { BentoGrid } from '../components/BentoGrid';
import { ReleasesHub } from '../components/ReleasesHub';
import { InstallGuide } from '../components/InstallGuide';
import { FaqSection } from '../components/FaqSection';
import { Footer } from '../components/Footer';

export const HomePage: React.FC = () => {
  const [deviceInfo, setDeviceInfo] = useState<DeviceInfo>({
    platform: 'android',
    label: 'أندرويد',
    badge: 'APK مباشر',
    recommendedFile: 'Arkan-1.0.0-universal.apk',
    downloadUrl: '#releases',
    isMobile: true,
  });

  useEffect(() => {
    setDeviceInfo(detectDevice());
  }, []);

  const handleHeroDownload = () => {
    confetti({
      particleCount: 100,
      spread: 70,
      origin: { y: 0.6 },
      colors: ['#F59E0B', '#3551AE', '#10B981']
    });
  };

  return (
    <div className="min-h-screen flex flex-col bg-[#0b0f19] text-slate-100 font-sans selection:bg-brand-500 selection:text-white">
      
      {/* Top Navbar */}
      <Navbar />

      {/* Hero Section */}
      <section className="relative pt-12 pb-24 lg:pt-20 lg:pb-32 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto w-full overflow-hidden">
        
        {/* Glow ambient backgrounds */}
        <div className="absolute top-1/4 right-1/2 translate-x-1/2 -translate-y-1/2 w-[550px] h-[550px] bg-brand-600/15 rounded-full blur-[140px] pointer-events-none -z-10"></div>
        <div className="absolute top-1/3 left-10 w-[400px] h-[400px] bg-gold-500/10 rounded-full blur-[120px] pointer-events-none -z-10"></div>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          {/* Left / Main Text (7 Cols on desktop) */}
          <div className="lg:col-span-7 space-y-8 text-center lg:text-right">
            
            {/* Pill Badge */}
            <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full glass-panel border border-gold-500/30 bg-gold-500/5 shadow-neon-gold">
              <span className="flex h-2 w-2 rounded-full bg-gold-400 animate-pulse"></span>
              <span className="text-xs sm:text-sm font-bold text-gold-300">
                الإصدار الرسمي v1.0.0 متاح الآن للتحميل المباشر
              </span>
            </div>

            {/* Main Headline */}
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black tracking-tight text-white leading-[1.25] font-sans">
              تطبيق <span className="gold-gradient-text">أركان</span> الإسلامي
              <br />
              <span className="text-slate-200 text-3xl sm:text-4xl lg:text-5xl">رفيقك اليومي للعبادات</span>
            </h1>

            {/* Sub-headline */}
            <p className="text-slate-300 text-base sm:text-lg lg:text-xl leading-relaxed max-w-2xl mx-auto lg:mx-0 font-normal">
              المصحف الشريف المرتل، مواقيت الصلاة والأذان الدقيقة، وحصن المسلم، والمسبحة الذكية، ومحفظة كوينز الطاعات — <strong className="text-white font-bold">يعمل محلياً 100% بدون إنترنت، وبلا أي إعلانات نهائياً</strong>.
            </p>

            {/* Smart Download CTAs */}
            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-2">
              <a
                href={`https://github.com/coach-nooreldean/arkan/releases/download/v1.0.0/${deviceInfo.recommendedFile}`}
                onClick={handleHeroDownload}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl text-base font-extrabold bg-gradient-to-r from-gold-500 via-amber-500 to-gold-600 text-slate-950 hover:from-gold-400 hover:to-amber-400 shadow-neon-gold hover:scale-[1.02] active:scale-95 transition-all duration-200"
              >
                <Download className="w-5 h-5" />
                <span>تحميل {deviceInfo.label} ({deviceInfo.badge})</span>
              </a>

              <a
                href="#simulator"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-6 py-4 rounded-2xl text-base font-bold bg-white/5 hover:bg-white/10 text-white border border-white/10 hover:border-white/20 transition-all duration-200"
              >
                <Smartphone className="w-5 h-5 text-gold-400" />
                <span>جرّب التطبيق مباشرة</span>
              </a>
            </div>

            {/* Trust Indicators */}
            <div className="pt-6 border-t border-white/10 grid grid-cols-3 gap-4 max-w-lg mx-auto lg:mx-0 text-center lg:text-right">
              <div>
                <span className="text-2xl font-black text-white">100%</span>
                <p className="text-xs text-slate-400 mt-0.5">يعمل أوفلاين بلا نت</p>
              </div>
              <div>
                <span className="text-2xl font-black text-emerald-400">0</span>
                <p className="text-xs text-slate-400 mt-0.5">إعلانات تجارية</p>
              </div>
              <div>
                <span className="text-2xl font-black text-gold-400">مجاني</span>
                <p className="text-xs text-slate-400 mt-0.5">وقف وصدقة جارية</p>
              </div>
            </div>

          </div>

          {/* Right / Interactive Smartphone Simulator (5 Cols on desktop) */}
          <div id="simulator" className="lg:col-span-5 flex justify-center relative">
            <div className="absolute -inset-4 bg-gradient-to-tr from-brand-500/20 via-gold-500/10 to-transparent rounded-[60px] blur-2xl -z-10"></div>
            <SmartphoneSimulator />
          </div>

        </div>

      </section>

      {/* Bento Grid Features */}
      <BentoGrid />

      {/* Releases Hub Downloads */}
      <ReleasesHub deviceInfo={deviceInfo} />

      {/* APK Install Guide */}
      <InstallGuide />

      {/* FAQ Section */}
      <FaqSection />

      {/* Footer */}
      <Footer />

    </div>
  );
};
