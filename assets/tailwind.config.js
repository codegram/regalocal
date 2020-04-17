const { colors } = require("tailwindcss/defaultTheme")

module.exports = {
  important: true,
  theme: {
    fontFamily: {
      sans: ["Helvetica", "Arial", "sans-serif"],
    },
    extend: {
      colors: {
        primary: {
          50: "#fffcfe",
          100: "#fce8f3",
          200: "#fad1e8",
          300: "#f8b4d9",
          400: "#f17eb8",
          500: "#e74694",
          600: "#d61f69",
          700: "#bf125d",
          800: "#99154b",
          900: "#751a3d",
        },
        secondary: {
          ...colors.indigo,
        },
      },
    },
  },
  variants: {},
  plugins: [require("@tailwindcss/ui")],
}
