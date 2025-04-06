import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import sys

def get_favicons(url):
    try:
        response = requests.get(url, timeout=5, verify=False)  # Desactivar verificación SSL
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'lxml')

        favicons = []

        # Buscar múltiples tipos de favicon
        for link_tag in soup.find_all('link', rel=True):
            rel = link_tag.get('rel')
            href = link_tag.get('href')
            if href and any(r in rel for r in ['icon', 'shortcut icon', 'apple-touch-icon', 'mask-icon']):
                favicon_url = urljoin(url, href)
                favicons.append(favicon_url)

        # Añadir favicon estándar si no se encontró ninguno
        if not favicons:
            standard_favicon = urljoin(url, '/favicon.ico')
            favicons.append(standard_favicon)

        return favicons

    except Exception as e:
        print(f"Error obteniendo favicons de {url}: {e}")
        return []

def main():
    if len(sys.argv) != 2:
        print("Uso: python get_all_favicons.py <URL>")
        return
    
    url = sys.argv[1]
    if not url.startswith('http'):
        url = 'https://' + url

    favicons = get_favicons(url)

    if favicons:
        for favicon_url in favicons:
            print(favicon_url)
    else:
        print(f"⚠ No se encontraron favicons para: {url}")

if __name__ == '__main__':
    # Desactivar advertencias de certificados SSL
    requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)
    main()
