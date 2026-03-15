import asyncio
from dataclasses import dataclass, field
from datetime import datetime
import httpx
from bs4 import BeautifulSoup


USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
TIMEOUT = 60.0


CRIME_KEYWORDS = {
    "pembunuhan": ("pembunuhan", 10),
    "membunuh": ("pembunuhan", 10),
    "pemerkosaan": ("pemerkosaan", 9),
    "perkosa": ("pemerkosaan", 9),
    "kekerasan seksual": ("kekerasan seksual", 9),
    "pelecehan seksual": ("pelecehan seksual", 8),
    "perampokan": ("perampokan", 9),
    "begal": ("perampokan", 9),
    "penculikan": ("penculikan", 8),
    "culik": ("penculikan", 8),
    "penganiayaan": ("penganiayaan", 7),
    "kdrt": ("kdrt", 7),
    "kekerasan": ("kekerasan", 6),
    "narkoba": ("narkoba", 6),
    "pencurian": ("pencurian", 5),
    "maling": ("pencurian", 5),
    "tawuran": ("tawuran", 5),
    "penipuan": ("penipuan", 4),
}


NTB_AREAS = {
    "mataram": (-8.5833, 116.1167),
    "ampenan": (-8.5667, 116.0833),
    "cakranegara": (-8.6000, 116.1333),
    "lombok barat": (-8.6000, 116.0833),
    "gerung": (-8.6333, 116.1000),
    "lombok tengah": (-8.7167, 116.2833),
    "praya": (-8.7167, 116.2833),
    "lombok timur": (-8.5333, 116.5333),
    "selong": (-8.6500, 116.5333),
    "lombok utara": (-8.3167, 116.2833),
    "tanjung": (-8.3167, 116.3000),
    "sumbawa": (-8.5000, 117.4167),
    "sumbawa besar": (-8.5000, 117.4167),
    "dompu": (-8.5333, 118.4667),
    "bima": (-8.4500, 118.7167),
}


@dataclass
class ScrapedArticle:
    source: str
    title: str
    url: str
    snippet: str = ""
    published_at: datetime = None
    crime_type: str = None
    severity: int = 0
    area: str = None
    latitude: float = None
    longitude: float = None


@dataclass
class ScrapeConfig:
    max_articles: int = 100
    max_pages: int = 5
    sources: list = field(default_factory=lambda: ["detik", "insidelombok", "postlombok"])


async def fetch_html(url: str) -> str:
    try:
        async with httpx.AsyncClient(headers={"User-Agent": USER_AGENT}, timeout=TIMEOUT, follow_redirects=True) as client:
            response = await client.get(url)
            response.raise_for_status()
            return response.text
    except Exception:
        return ""


def detect_crime(text: str) -> tuple:
    text_lower = text.lower()
    best_type, best_severity = None, 0
    for keyword, (crime_type, severity) in CRIME_KEYWORDS.items():
        if keyword in text_lower and severity > best_severity:
            best_type, best_severity = crime_type, severity
    return best_type, best_severity


def detect_area(text: str) -> tuple:
    text_lower = text.lower()
    for area, coords in NTB_AREAS.items():
        if area in text_lower:
            return area, coords[0], coords[1]
    return None, None, None


def parse_date(date_str: str) -> datetime:
    if not date_str:
        return None
    try:
        return datetime.fromisoformat(date_str.replace("Z", "+00:00"))
    except Exception:
        return None


async def scrape_detik(config: ScrapeConfig) -> list:
    articles = []
    urls = ["https://www.detik.com/bali/hukum-kriminal"]
    for page in range(2, config.max_pages + 1):
        urls.append(f"https://www.detik.com/bali/hukum-kriminal/indeks/{page}")

    for url in urls:
        if len(articles) >= config.max_articles:
            break
        html = await fetch_html(url)
        if not html:
            continue
        soup = BeautifulSoup(html, "html.parser")
        items = soup.select("article") or soup.select(".list-content article, .media__item")
        for item in items:
            if len(articles) >= config.max_articles:
                break
            title_el = item.select_one("h3.media__title a, h2 a, .media__title a, a")
            if not title_el:
                continue
            title = title_el.get_text(strip=True)
            link = title_el.get("href", "")
            if not title or not link:
                continue
            snippet_el = item.select_one(".media__desc, .media__subtitle, p")
            snippet = snippet_el.get_text(strip=True) if snippet_el else ""
            date_el = item.select_one(".media__date span, time, .date")
            published_at = parse_date(date_el.get("title") or date_el.get("datetime") if date_el else None)
            combined = f"{title} {snippet}"
            crime_type, severity = detect_crime(combined)
            area, lat, lng = detect_area(combined)
            if crime_type and area:
                articles.append(ScrapedArticle(
                    source="detik",
                    title=title,
                    url=str(link),
                    snippet=snippet,
                    published_at=published_at,
                    crime_type=crime_type,
                    severity=severity,
                    area=area,
                    latitude=lat,
                    longitude=lng,
                ))
    return articles


async def scrape_insidelombok(config: ScrapeConfig) -> list:
    articles = []
    base_urls = ["https://insidelombok.id/category/hukum/", "https://insidelombok.id/category/kriminal/"]
    urls = []
    for base in base_urls:
        urls.append(base)
        for page in range(2, config.max_pages + 1):
            urls.append(f"{base}page/{page}/")

    for url in urls:
        if len(articles) >= config.max_articles:
            break
        html = await fetch_html(url)
        if not html:
            continue
        soup = BeautifulSoup(html, "html.parser")
        items = soup.select("article") or soup.select(".post, .entry")
        for item in items:
            if len(articles) >= config.max_articles:
                break
            title_el = item.select_one("h2 a, h3 a, .entry-title a, .post-title a")
            if not title_el:
                continue
            title = title_el.get_text(strip=True)
            link = title_el.get("href", "")
            if not title or not link:
                continue
            snippet_el = item.select_one(".entry-content p, .entry-summary p, .post-excerpt")
            snippet = snippet_el.get_text(strip=True) if snippet_el else ""
            date_el = item.select_one("time, .entry-date, .post-date")
            published_at = parse_date(date_el.get("datetime") if date_el else None)
            combined = f"{title} {snippet}"
            crime_type, severity = detect_crime(combined)
            area, lat, lng = detect_area(combined)
            if crime_type and area:
                articles.append(ScrapedArticle(
                    source="insidelombok",
                    title=title,
                    url=str(link),
                    snippet=snippet,
                    published_at=published_at,
                    crime_type=crime_type,
                    severity=severity,
                    area=area,
                    latitude=lat,
                    longitude=lng,
                ))
    return articles


async def scrape_postlombok(config: ScrapeConfig) -> list:
    articles = []
    base_url = "https://postlombok.com/"
    urls = [base_url]
    for page in range(2, config.max_pages + 1):
        urls.append(f"{base_url}page/{page}/")

    for url in urls:
        if len(articles) >= config.max_articles:
            break
        html = await fetch_html(url)
        if not html:
            continue
        soup = BeautifulSoup(html, "html.parser")
        items = soup.select("article, .post, .entry")
        for item in items:
            if len(articles) >= config.max_articles:
                break
            title_el = item.select_one("h2 a, h3 a, .entry-title a, .post-title a")
            if not title_el:
                continue
            title = title_el.get_text(strip=True)
            link = title_el.get("href", "")
            if not title or not link:
                continue
            snippet_el = item.select_one(".entry-content p, .entry-summary p, .post-excerpt")
            snippet = snippet_el.get_text(strip=True) if snippet_el else ""
            date_el = item.select_one("time, .entry-date, .post-date")
            published_at = parse_date(date_el.get("datetime") if date_el else None)
            combined = f"{title} {snippet}"
            crime_type, severity = detect_crime(combined)
            area, lat, lng = detect_area(combined)
            if crime_type and area:
                articles.append(ScrapedArticle(
                    source="postlombok",
                    title=title,
                    url=str(link),
                    snippet=snippet,
                    published_at=published_at,
                    crime_type=crime_type,
                    severity=severity,
                    area=area,
                    latitude=lat,
                    longitude=lng,
                ))
    return articles


async def run(config: ScrapeConfig = None) -> list:
    if config is None:
        config = ScrapeConfig()
    all_articles = []
    scrapers = {"detik": scrape_detik, "insidelombok": scrape_insidelombok, "postlombok": scrape_postlombok}
    for source in config.sources:
        if source in scrapers:
            articles = await scrapers[source](config)
            all_articles.extend(articles)
    seen_urls = set()
    unique = []
    for a in all_articles:
        if a.url not in seen_urls:
            seen_urls.add(a.url)
            unique.append(a)
    return unique
