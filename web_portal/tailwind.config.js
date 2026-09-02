/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#eef2ff',
          100: '#e0e7ff',
          200: '#c7d2fe',
          300: '#a5b4fc',
          400: '#818cf8',
          500: '#3551ae', // Primary Deep Royal Blue
          600: '#2b4294',
          700: '#23377a',
          800: '#1d2c61',
          900: '#162248',
          950: '#0b0f19',
        },
        gold: {
          50: '#fffbeb',
          100: '#fef3c7',
          200: '#fde68a',
          300: '#fcd34d',
          400: '#fbbf24',
          500: '#f59e0b',
          600: '#d97706',
          700: '#b45309',
        },
        obsidian: {
          950: '#06070a',
          900: '#08090d',
          850: '#0b0f19',
          800: '#111726',
          750: '#161e31',
          700: '#1e293b',
        },
      },
      fontFamily: {
        sans: ['Tajawal', 'Cairo', 'system-ui', 'sans-serif'],
        quran: ['Amiri', 'serif'],
      },
      boxShadow: {
        'neon-gold': '0 0 30px rgba(245, 158, 11, 0.35)',
        'neon-blue': '0 0 30px rgba(53, 81, 174, 0.4)',
        'glass-card': '0 20px 50px rgba(0, 0, 0, 0.6), 0 0 25px rgba(53, 81, 174, 0.2)',
      },
      animation: {
        'float-slow': 'floatSlow 7s ease-in-out infinite',
        'pulse-glow': 'pulseGlow 2.5s ease-in-out infinite',
      },
      keyframes: {
        floatSlow: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-10px)' },
        },
        pulseGlow: {
          '0%, 100%': { opacity: '1', transform: 'scale(1)' },
          '50%': { opacity: '0.7', transform: 'scale(1.03)' },
        },
      },
    },
  },
  plugins: [],
}
