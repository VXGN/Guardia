"""News scraper for NTB crime news from multiple Indonesian news sources."""

import logging
from dataclasses import dataclass
from datetime import datetime

import httpx
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/120.0.0.0 Safari/537.36"
)

TIMEOUT = 30.0


@dataclass
class RawArticle:
    source: str
    title: str
    url: str
    snippet: str | None = None
    published_at: datetime | None = None


async def _fetch_html(url: str) -> str | None:
    """Fetch HTML content from a URL."""
    try:
        async with httpx.AsyncClient(
            headers={"User-Agent": USER_AGENT},
            timeout=TIMEOUT,
            follow_redirects=True,
        ) as client:
            response = await client.get(url)
            response.raise_for_status()
            return response.text
    except Exception as e:
        logger.error(f"Failed to fetch {url}: {e}")
        return None


async def scrape_detik() -> list[RawArticle]:
    """Scrape crime news from detik.com NTB regional section."""
    articles: list[RawArticle] = []
    urls = [
        "https://www.detik.com/bali/hukum-dan-kriminal",
        "https://www.detik.com/sulawesi/hukum-dan-kriminal",
    ]

    for url in urls:
        html = await _fetch_html(url)
        if not html:
            continue

        soup = BeautifulSoup(html, "html.parser")

        for item in soup.select("article"):
            title_el = item.select_one("h3.media__title a, h2.title a, .media__title a")
            if not title_el:
                title_el = item.select_one("a")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            link = title_el.get("href", "")
            if not title or not link:
                continue

            snippet_el = item.select_one(".media__desc, .media__subtitle, p")
            snippet = snippet_el.get_text(strip=True) if snippet_el else None

            combined = (title + " " + (snippet or "")).lower()
            ntb_keywords = [
                "ntb", "lombok", "mataram", "sumbawa", "bima", "dompu",
                "nusa tenggara barat", "praya", "selong",
            ]
            if not any(kw in combined for kw in ntb_keywords):
                continue

            date_el = item.select_one(".media__date span, time, .date")
            published_at = None
            if date_el:
                date_str = date_el.get("title") or date_el.get("datetime")
                if date_str:
                    try:
                        published_at = datetime.fromisoformat(date_str.replace("Z", "+00:00"))
                    except (ValueError, TypeError):
                        pass

            articles.append(RawArticle(
                source="detik",
                title=title,
                url=str(link),
                snippet=snippet,
                published_at=published_at,
            ))

    logger.info(f"Scraped {len(articles)} articles from detik.com")
    return articles


async def scrape_kompas() -> list[RawArticle]:
    """Scrape crime news from kompas.com NTB regional section."""
    articles: list[RawArticle] = []
    url = "https://regional.kompas.com/nusatenggara"

    html = await _fetch_html(url)
    if not html:
        return articles

    soup = BeautifulSoup(html, "html.parser")

    for item in soup.select(".articleListItem, .latest--news .article-item, .most .article-item, .articleItem"):
        title_el = item.select_one("h3 a, h2 a, .article__title a, .articleTitle a")
        if not title_el:
            title_el = item.select_one("a.article__link, a")
        if not title_el:
            continue

        title = title_el.get_text(strip=True)
        link = title_el.get("href", "")
        if not title or not link:
            continue

        snippet_el = item.select_one(".article__lead, .articleExcerpt, p")
        snippet = snippet_el.get_text(strip=True) if snippet_el else None

        date_el = item.select_one(".article__date, .articleDate, time")
        published_at = None
        if date_el:
            date_str = date_el.get("datetime") or date_el.get("title")
            if date_str:
                try:
                    published_at = datetime.fromisoformat(date_str.replace("Z", "+00:00"))
                except (ValueError, TypeError):
                    pass

        articles.append(RawArticle(
            source="kompas",
            title=title,
            url=str(link),
            snippet=snippet,
            published_at=published_at,
        ))

    logger.info(f"Scraped {len(articles)} articles from kompas.com")
    return articles


async def scrape_insidelombok() -> list[RawArticle]:
    """Scrape crime news from insidelombok.com."""
    articles: list[RawArticle] = []
    urls = [
        "https://insidelombok.id/category/hukum-kriminal/",
        "https://insidelombok.id/category/hukum/",
        "https://insidelombok.id/",
    ]

    for url in urls:
        html = await _fetch_html(url)
        if not html:
            continue

        soup = BeautifulSoup(html, "html.parser")

        for item in soup.select("article, .post, .entry"):
            title_el = item.select_one("h2 a, h3 a, .entry-title a, .post-title a")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            link = title_el.get("href", "")
            if not title or not link:
                continue

            snippet_el = item.select_one(
                ".entry-content p, .entry-summary p, .post-excerpt, .excerpt"
            )
            snippet = snippet_el.get_text(strip=True) if snippet_el else None

            date_el = item.select_one("time, .entry-date, .post-date")
            published_at = None
            if date_el:
                date_str = date_el.get("datetime")
                if date_str:
                    try:
                        published_at = datetime.fromisoformat(date_str.replace("Z", "+00:00"))
                    except (ValueError, TypeError):
                        pass

            articles.append(RawArticle(
                source="insidelombok",
                title=title,
                url=str(link),
                snippet=snippet,
                published_at=published_at,
            ))

    seen_urls: set[str] = set()
    unique: list[RawArticle] = []
    for a in articles:
        if a.url not in seen_urls:
            seen_urls.add(a.url)
            unique.append(a)

    logger.info(f"Scraped {len(unique)} articles from insidelombok")
    return unique


async def scrape_postlombok() -> list[RawArticle]:
    """Scrape crime news from postlombok.com."""
    articles: list[RawArticle] = []
    urls = [
        "https://postlombok.com/category/hukum-kriminal/",
        "https://postlombok.com/category/hukum/",
        "https://postlombok.com/",
    ]

    for url in urls:
        html = await _fetch_html(url)
        if not html:
            continue

        soup = BeautifulSoup(html, "html.parser")

        for item in soup.select("article, .post, .entry"):
            title_el = item.select_one("h2 a, h3 a, .entry-title a, .post-title a")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            link = title_el.get("href", "")
            if not title or not link:
                continue

            snippet_el = item.select_one(
                ".entry-content p, .entry-summary p, .post-excerpt, .excerpt"
            )
            snippet = snippet_el.get_text(strip=True) if snippet_el else None

            date_el = item.select_one("time, .entry-date, .post-date")
            published_at = None
            if date_el:
                date_str = date_el.get("datetime")
                if date_str:
                    try:
                        published_at = datetime.fromisoformat(date_str.replace("Z", "+00:00"))
                    except (ValueError, TypeError):
                        pass

            articles.append(RawArticle(
                source="postlombok",
                title=title,
                url=str(link),
                snippet=snippet,
                published_at=published_at,
            ))

    seen_urls: set[str] = set()
    unique: list[RawArticle] = []
    for a in articles:
        if a.url not in seen_urls:
            seen_urls.add(a.url)
            unique.append(a)

    logger.info(f"Scraped {len(unique)} articles from postlombok")
    return unique


async def scrape_all_sources() -> list[RawArticle]:
    """Scrape all news sources and return combined results."""
    all_articles: list[RawArticle] = []

    scrapers = [
        ("detik", scrape_detik),
        ("kompas", scrape_kompas),
        ("insidelombok", scrape_insidelombok),
        ("postlombok", scrape_postlombok),
    ]

    for name, scraper_fn in scrapers:
        try:
            articles = await scraper_fn()
            all_articles.extend(articles)
        except Exception as e:
            logger.error(f"Scraper {name} failed: {e}")

    logger.info(f"Total scraped: {len(all_articles)} articles from all sources")
    return all_articles
