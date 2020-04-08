module.exports = {
  important: true,
  theme: {
    extend: {
      colors: {
        primary: {
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
      },
    },
  },
  variants: {},
  plugins: [require("@tailwindcss/ui")],
}
