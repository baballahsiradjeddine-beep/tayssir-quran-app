"use client"

import { motion } from "framer-motion"
import { Download, BookOpen, Star, Shield, Users, Smartphone, Globe, Sparkles, ArrowRight } from "lucide-react"
import SpiritualScene from "@/components/SpiritualScene"

export default function LandingPage() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15,
        delayChildren: 0.3,
      },
    },
  }

  const itemVariants = {
    hidden: { y: 30, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: { duration: 0.8, ease: [0.16, 1, 0.3, 1] },
    },
  }

  return (
    <main className="relative min-h-screen selection:bg-emerald-500/20">
      <SpiritualScene />
      
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 p-4 md:p-8 flex justify-center">
        <div className="w-full max-w-7xl bg-white/40 backdrop-blur-xl border border-emerald-500/10 rounded-[32px] px-6 py-4 flex flex-row-reverse justify-between items-center shadow-lg">
          <motion.div 
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="text-2xl font-black text-gradient tracking-tighter"
          >
            BAYAN
          </motion.div>
          
          <div className="hidden md:flex flex-row-reverse gap-8 lg:gap-12 items-center">
            {["الرؤية", "المميزات", "المجتمع", "الدعم"].map((item) => (
              <a 
                key={item} 
                href="#" 
                className="text-sm font-bold text-emerald-950/60 hover:text-emerald-600 transition-colors duration-300"
              >
                {item}
              </a>
            ))}
          </div>

          <motion.button 
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => window.open('http://localhost:8080', '_blank')}
            className="bg-emerald-600 px-6 py-2.5 rounded-2xl text-xs font-black text-white flex items-center gap-2 shadow-lg shadow-emerald-600/20"
          >
            دخول المنصة
            <Globe size={14} />
          </motion.button>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative pt-48 pb-20 px-6 min-h-[90vh] flex flex-col items-center justify-center">
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="visible"
          className="max-w-5xl w-full flex flex-col items-center text-center"
        >
          <motion.div 
            variants={itemVariants}
            className="inline-flex items-center gap-2 bg-emerald-600/5 border border-emerald-600/10 px-5 py-2 rounded-full text-emerald-700 text-xs font-bold mb-10 uppercase tracking-widest"
          >
            <Sparkles size={14} />
            مستقبل تعلم القرآن الكريم
          </motion.div>

          <motion.h1 
            variants={itemVariants}
            className="text-5xl md:text-8xl font-black mb-10 leading-[1.1] tracking-tighter text-emerald-950"
          >
            نورٌ يضيءُ <span className="text-gradient">دربكَ</span> <br /> 
            بيانٌ يرتلُ <span className="text-glow">قلبكَ</span>
          </motion.h1>

          <motion.p 
            variants={itemVariants}
            className="text-lg md:text-2xl text-emerald-950/60 mb-14 leading-relaxed max-w-3xl mx-auto font-medium"
          >
            اختبر تجربة قرآنية فريدة تجمع بين أصالة التلاوة وذكاء التكنولوجيا. 
            بيان هو رفيقك الذكي في رحلة الحفظ، المراجعة، والتدبر برواية ورش الأصيلة.
          </motion.p>

          <motion.div 
            variants={itemVariants}
            className="flex flex-col sm:flex-row-reverse gap-6 justify-center items-center w-full"
          >
            <button 
              onClick={() => window.open('http://localhost:8080', '_blank')}
              className="w-full sm:w-auto bg-emerald-600 hover:bg-emerald-500 text-white px-12 py-5 rounded-2xl font-black text-lg transition-all duration-300 shadow-xl shadow-emerald-600/20 flex flex-row-reverse items-center justify-center gap-3 group"
            >
              ابدأ رحلتك الآن
              <ArrowRight className="rotate-180 group-hover:-translate-x-1 transition-transform" />
            </button>
            <button className="w-full sm:w-auto bg-white border border-emerald-600/10 px-12 py-5 rounded-2xl font-black text-lg text-emerald-900 hover:bg-emerald-50 shadow-sm transition-all duration-300">
              شاهد العرض
            </button>
          </motion.div>
        </motion.div>
      </section>

      {/* Features Grid */}
      <section className="py-20 px-6 max-w-7xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <FeatureCard 
            icon={<BookOpen className="text-emerald-600" />}
            title="مصحف ورش الذكي"
            description="تجربة قراءة غامرة بأجمل الخطوط المغربية الأصيلة مع دعم كامل للواقع المعزز."
            delay={0.1}
          />
          <FeatureCard 
            icon={<Sparkles className="text-amber-600" />}
            title="تسميع بالذكاء الاصطناعي"
            description="صحح تلاوتك في الوقت الحقيقي مع محرك بيان الذكي الذي يتعرف على صوتك بدقة."
            delay={0.2}
          />
          <FeatureCard 
            icon={<Users className="text-emerald-700" />}
            title="الختمة الجماعية"
            description="شارك عائلتك وأصدقاءك روح التنافس في الخير وتابع تقدمكم معاً في لوحة الصدارة."
            delay={0.3}
          />
        </div>
      </section>

      {/* App Preview Section */}
      <section className="py-20 px-6 max-w-7xl mx-auto relative">
        <div className="bg-emerald-50 rounded-[48px] p-12 overflow-hidden relative group border border-emerald-100 shadow-inner">
          <div className="absolute top-0 right-0 w-1/2 h-full bg-gradient-to-l from-emerald-100/50 to-transparent pointer-events-none" />
          <div className="relative z-10 flex flex-col md:flex-row items-center gap-12">
            <div className="flex-1 text-right">
              <h2 className="text-4xl md:text-5xl font-black mb-8 leading-tight text-emerald-950">
                أدواتك للتمكين <br /> في حفظ كتاب الله
              </h2>
              <ul className="space-y-6">
                <li className="flex flex-row-reverse items-center gap-4 justify-start text-emerald-900/70">
                  <div className="w-3 h-3 bg-emerald-500 rounded-full shadow-lg shadow-emerald-500/40" />
                  <span className="text-xl font-bold">خريطة إنجاز نورانية تفاعلية</span>
                </li>
                <li className="flex flex-row-reverse items-center gap-4 justify-start text-emerald-900/70">
                  <div className="w-3 h-3 bg-emerald-500 rounded-full shadow-lg shadow-emerald-500/40" />
                  <span className="text-xl font-bold">أذكار وحصن مسلم ذكي حسب موقعك</span>
                </li>
                <li className="flex flex-row-reverse items-center gap-4 justify-start text-emerald-900/70">
                  <div className="w-3 h-3 bg-emerald-500 rounded-full shadow-lg shadow-emerald-500/40" />
                  <span className="text-xl font-bold">بوصلة قبلة بتقنية الواقع المعزز AR</span>
                </li>
              </ul>
            </div>
            <div className="flex-1 w-full max-w-md">
              <div className="aspect-[9/19] bg-white rounded-[3.5rem] p-4 relative shadow-2xl border-4 border-emerald-100">
                 <div className="w-full h-full bg-emerald-50 rounded-[2.8rem] flex items-center justify-center border border-emerald-100">
                    <Smartphone size={80} className="text-emerald-600/10 animate-pulse" />
                 </div>
                 {/* Floating Badges */}
                 <motion.div 
                   animate={{ y: [0, -15, 0] }}
                   transition={{ duration: 5, repeat: Infinity }}
                   className="absolute -left-12 top-24 bg-white px-5 py-4 rounded-3xl flex items-center gap-4 shadow-xl border border-emerald-50"
                 >
                    <div className="w-10 h-10 bg-amber-100 rounded-2xl flex items-center justify-center text-lg shadow-inner">🌟</div>
                    <div className="text-sm font-black text-emerald-950">فارس البقرة</div>
                 </motion.div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-24 px-6 border-t border-emerald-100 bg-white/80 backdrop-blur-md">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-16 text-center md:text-right">
          <div className="flex flex-col items-center md:items-end">
            <div className="text-3xl font-black text-gradient mb-6">BAYAN</div>
            <p className="text-emerald-950/40 text-base max-w-sm leading-relaxed font-medium">
              تطبيق بيان هو مشروع طموح يهدف لرقمنة تجربة تعلم القرآن الكريم بأحدث الوسائل التقنية.
            </p>
          </div>
          <div className="flex gap-16 flex-row-reverse">
            <FooterLink title="الروابط" links={["الرئيسية", "المميزات", "عن التطبيق"]} />
            <FooterLink title="القانونية" links={["سياسة الخصوصية", "الشروط والأحكام"]} />
            <FooterLink title="تواصل" links={["البريد الإلكتروني", "تويتر", "إنستغرام"]} />
          </div>
        </div>
        <div className="mt-24 text-center text-emerald-950/20 text-sm font-bold tracking-widest">
          © 2026 BAYAN QURAN PLATFORM • جميع الحقوق محفوظة
        </div>
      </footer>
    </main>
  )
}

function FeatureCard({ icon, title, description, delay }: { icon: any, title: string, description: string, delay: number }) {
  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ delay, duration: 0.8 }}
      whileHover={{ y: -8, scale: 1.02 }}
      className="bg-white/80 backdrop-blur-sm p-10 rounded-[40px] border border-emerald-100 hover:border-emerald-300 transition-all duration-500 group text-right shadow-sm hover:shadow-xl hover:shadow-emerald-900/5"
    >
      <div className="w-16 h-16 bg-emerald-50 rounded-2xl flex items-center justify-center mb-8 group-hover:scale-110 group-hover:bg-emerald-100 transition-all duration-500 mr-0 ml-auto shadow-inner">
        {icon}
      </div>
      <h3 className="text-2xl font-black mb-5 text-emerald-950 group-hover:text-emerald-600 transition-colors">{title}</h3>
      <p className="text-emerald-950/50 text-base leading-relaxed font-medium">{description}</p>
    </motion.div>
  )
}

function FooterLink({ title, links }: { title: string, links: string[] }) {
  return (
    <div className="flex flex-col gap-5 text-right">
      <h4 className="text-base font-black text-emerald-950">{title}</h4>
      {links.map(l => <a key={l} href="#" className="text-sm font-bold text-emerald-950/30 hover:text-emerald-600 transition-colors">{l}</a>)}
    </div>
  )
}
