/** @type {import('tailwindcss').Config} */
module.exports = {
    darkMode: 'media',
    content: ["./src/tmbgodt/templates/*.matcha", "./node_modules/flowbite/**/*.js"],
    theme: {
      extend: {},
    },
    plugins: [require('flowbite/plugin')],
  }
  
  