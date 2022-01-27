//Your theme for the new stuff using material UI has been copied here so it doesn't conflict
import { createMuiTheme } from '@material-ui/core/styles';

const newTheme = createMuiTheme({
  palette: {
    type: 'dark',
    text: {
      primary: '#FFF',
    },
    background: {
      default: '#2e2e2e',
      // paper: 'rgba(255, 255, 255, 0.9)',
      paper: '#2b2122',
    },
    primary: {
      light: '#ffab91',
      main: '#e39480',
      dark: '#946053',
      contrastText: '#000',
    },
    secondary: {
      light: '#ff7961',
      main: '#f44336',
      dark: '#ba000d',
      contrastText: '#000',
    },
    action: {
      disabledBackground: '#CDCDCD',
      active: '#000',
      hover: '#000',
    },
  },
  typography: {
    color: '#603c46',
    fontFamily: ['"Rubik"', 'sans-serif'].join(','),
  },
});

export default newTheme;
