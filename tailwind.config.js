const defaultTheme = require('tailwindcss/defaultConfig').theme

module.exports = {
  content: [
    'app/views/**/*.{html,erb}',
    'app/helpers/**/*.rb',
    'app/assets/javascripts/**/*.js',
    'app/javascript/**/*.js',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
}
