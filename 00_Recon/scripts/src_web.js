// sudo apt install nodejs npm -y
// sudo npm install -g puppeteer
// sudo npm install -g fs

const fs = require('fs');
const puppeteer = require('puppeteer');

(async () => {
  const jsRequests = new Set();
  const apiRequests = new Set();

  const browser = await puppeteer.launch({
    headless: false,
    defaultViewport: null,
    args: ['--start-maximized'],
    executablePath: '/usr/bin/chromium'  // Cambia esto si tu Chromium está en otro path
  });

  const [page] = await browser.pages();

  const target = process.argv[2];
  if (!target) {
    console.log("❌ Uso: node src_web.js https://ejemplo.com");
    process.exit(1);
  }

  // Captura todas las peticiones de red (JS y endpoints)
  page.on('requestfinished', request => {
    const url = request.url();
    const type = request.resourceType();

    if (type === 'script' || url.endsWith('.js')) {
      jsRequests.add(url);
    }

    if (type === 'xhr' || type === 'fetch') {
      apiRequests.add(url);
    }
  });

  // Ir al sitio
  await page.goto(target);

  console.log(`🧭 Navega libremente en: ${target}`);
  console.log("🔒 Cierra la pestaña para terminar y ver resultados...\n");

  // Esperar a que se cierre la pestaña principal
  await new Promise(resolve => {
    page.on('close', resolve);
  });

  // Guardar y mostrar resultados
  const jsList = [...jsRequests].sort();
  const apiList = [...apiRequests].sort();

  console.log("\n🔍 Archivos JavaScript detectados:");
  jsList.forEach(url => console.log(url));

  console.log("\n📡 Endpoints (XHR/fetch) detectados:");
  apiList.forEach(url => console.log(url));

  fs.writeFileSync('js_urls.txt', jsList.join('\n'));
  fs.writeFileSync('api_endpoints.txt', apiList.join('\n'));

  console.log("\n✅ Resultados guardados en: js_urls.txt y api_endpoints.txt");

  await browser.close();
})();
