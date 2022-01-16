module.exports = {
  content: ["../lib/**/*.ex", "../lib/**/*.heex", "./js/**/*.js"],
  theme: {
    extend: {
      keyframes: {
        "fade-in-down": {
          "0%": {
            opacity: "0",
            transform: "translateY(-2rem)",
          },
          "100%": {
            opacity: "1",
            transform: "translateY(0)",
          },
        },
      },
      animation: {
        "fade-in-down": "fade-in-down 0.3s ease-out forwards",
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
