import React from 'react';
import {
  UnifiedTheme,
  UnifiedThemeProvider,
  createUnifiedTheme,
  genPageTheme,
  themes,
  shapes,
} from '@backstage/theme';

const defaultLightTheme = themes.light.getTheme('v4');

export const beyondTheme: UnifiedTheme = createUnifiedTheme({
  palette: {
    ...defaultLightTheme?.palette,
    primary: {
      main: '#0072EF',
    },
    background: {
      default: '#FFFFFF',
      paper: '#F2F5F8',
    },
    navigation: {
      background: '#F8FAFC',
      indicator: '#32373E',
      color: '#32373E',
      selectedColor: '#32373E',
      navItem: {
        hoverBackground: '#FFFFFF',
      },
      submenu: {
        background: '#F2F5F8',
      },
    },
  },
  components: {
    BackstageHeader: {
      styleOverrides: {
        header: {
          boxSizing: 'border-box',
        },
      },
    },
  },
  defaultPageTheme: 'light',
  pageTheme: {
    ...defaultLightTheme?.getPageTheme,
    light: genPageTheme({
      colors: ['#F2F5F8', '#6C7784'],
      shape: shapes.wave2,
      options: {
        fontColor: '#32373E',
      },
    }),
  },
});

export const beyondAppTheme = {
  id: 'beyond-light',
  title: 'Beyond Light',
  variant: 'light' as const,
  Provider: ({ children }: { children: React.ReactNode }) =>
    React.createElement(UnifiedThemeProvider, { theme: beyondTheme }, children),
};
