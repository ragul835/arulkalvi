/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: ['./frontend/index.html', './frontend/src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#172033',
        brand: '#0f766e',
        cream: '#f7faf9'
      }
    }
  },
  plugins: []
};
