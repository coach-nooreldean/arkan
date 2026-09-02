import React, { useState } from 'react';
import { ChevronDown, HelpCircle } from 'lucide-react';

export const FaqSection: React.FC = () => {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  const faqs = [
    {
      q: 'هل التطبيق مجاني بالكامل؟ وهل يحتوي على إعلانات؟',
      a: 'تطبيق «أركان» مجاني بالكامل 100% لوجه الله تعالى (صدقة جارية)، ولا يحتوي على أي إعلانات تجارية مزعجة تشتت خشوعك، ولن يتم وضع أي إعلانات فيه مستقبلاً.',
    },
    {
      q: 'هل يعمل التطبيق دون الحاجة للاتصال بالإنترنت؟',
      a: 'نعم! يعمل التطبيق أوفلاين بالكامل (100% Offline). جميع مواقيت الصلاة، الأذكار، الأحاديث النبوية، أسماء الله الحسنى، والمسبحة الإلكترونية ومحفظة الكوينز مدمجة داخل هاتفك. تحتاج الإنترنت فقط إذا أردت الاستماع إلى تلاوات صوتية جديدة أو تحميلها.',
    },
    {
      q: 'كيف يتم حساب مواقيت الصلاة؟ وهل هي دقيقة لمدينتي؟',
      a: 'يعتمد تطبيق أركان على الحساب الفلكي الدقيق المعتمد عالمياً بـ 8 طرق حساب (مثل الهيئة المصرية العامة للمساحة، تقويم أم القرى، رابطة العالم الإسلامي، وجامعة العلوم الإسلامية بكراتشي). كما يتيح لك تعديل الدقائق يدوياً لضبط أي فارق زمني في مساجد حيك.',
    },
    {
      q: 'هل يجمع التطبيق أي بيانات شخصية أو يتطلب تسجيل دخول؟',
      a: 'لا على الإطلاق! التطبيق لا يتطلب إنشاء أي حساب أو بريد إلكتروني، ولا يقوم بجمع أو إرسال أي بيانات شخصية لأي خوادم خارجية. كل شيء يُخزّن محلياً على هاتفك فقط.',
    },
    {
      q: 'ما هو نظام كوينز ومكافآت الطاعات؟',
      a: 'هو نظام تحفيزي إسلامي محلي لطيف، يكافئك عند تسجيل صلاتك في وقتها، قراءة الورد اليومي من القرآن، أو إتمام أذكار الصباح والمساء، حيث ترتفع رتبتك الإيمانية داخل التطبيق (مثل: ساعٍ في الخير، حريص على الطاعات، سابق بالخيرات) مع فتح شارات إيمانية تشجيعية.',
    },
  ];

  return (
    <section id="faq" className="py-24 px-4 sm:px-6 lg:px-8 max-w-5xl mx-auto">
      
      <div className="text-center mb-16 space-y-3">
        <span className="px-4 py-1.5 rounded-full text-xs font-bold bg-white/5 text-slate-300 border border-white/10 inline-flex items-center gap-1.5">
          <HelpCircle className="w-3.5 h-3.5 text-gold-400" /> الأسئلة الشائعة
        </span>
        <h2 className="text-3xl sm:text-4xl font-black text-white">كل ما تريد معرفته عن «أركان»</h2>
      </div>

      <div className="space-y-4">
        {faqs.map((faq, index) => {
          const isOpen = openIndex === index;
          return (
            <div 
              key={index}
              className="glass-card rounded-2xl border border-white/10 overflow-hidden transition-colors"
            >
              <button
                onClick={() => setOpenIndex(isOpen ? null : index)}
                className="w-full p-6 text-right flex items-center justify-between gap-4 font-bold text-base sm:text-lg text-slate-100 focus:outline-none"
              >
                <span>{faq.q}</span>
                <ChevronDown className={`w-5 h-5 text-gold-400 shrink-0 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} />
              </button>
              
              {isOpen && (
                <div className="px-6 pb-6 pt-1 text-slate-400 text-sm leading-relaxed border-t border-white/5">
                  {faq.a}
                </div>
              )}
            </div>
          );
        })}
      </div>

    </section>
  );
};
