import { defineConfig } from 'appshots';

export default defineConfig({
  // Target devices for screenshot generation
  devices: ['iphone-6.9', 'ipad-13'],

  // Frame styling options (used by 'appshots frame')
  frame: {
    background: 'linear-gradient(135deg, #667eea, #764ba2)',
    padding: 0.08,
    borderRadius: 0.04,
    titleColor: '#ffffff',
    subtitleColor: 'rgba(255,255,255,0.7)',
    shadow: true,
  },

  // Screens to capture (used by 'appshots capture')
  capture: {
    baseUrl: 'http://localhost:3000',
    screens: [
      {
        name: 'home',
        path: '/',
        title: 'Welcome Home',
        subtitle: 'Everything you need',
        waitFor: 'Welcome',
      },
      {
        name: 'features',
        path: '/features',
        title: 'Powerful Features',
        delay: 2000,
      },
    ],
  },

  // Output directory
  output: './screenshots',
});
