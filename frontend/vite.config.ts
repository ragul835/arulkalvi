import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
export default defineConfig({
  plugins:[react()],
  root:'frontend',
  server:{ proxy:{ '/api':'http://localhost:8788', '/pdf':'http://localhost:8788', '/sitemap.xml':'http://localhost:8788', '/robots.txt':'http://localhost:8788' } },
  build:{ outDir:'../dist', emptyOutDir:true }
});
