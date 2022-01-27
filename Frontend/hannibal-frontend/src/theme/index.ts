import { brown, purple, teal, grey, red, white } from './colors';

const theme = {
  borderRadius: 12,
  color: {
    brown,
    grey,
    purple,
    primary: {
      light: brown[100],
      main: brown[200],
    },
    secondary: {
      main: teal[200],
    },
    white,
    teal,
  },
  siteWidth: 1200,
  spacing: {
    1: 4,
    2: 8,
    3: 16,
    4: 24,
    5: 32,
    6: 48,
    7: 64,
  },
  topBarSize: 72,
};

export default theme;
