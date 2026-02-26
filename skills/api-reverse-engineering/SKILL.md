# API Reverse Engineering — Extracting Data from Web Applications

Use when asked to scrape, reverse engineer, or extract data from web applications that load data client-side. Covers the full methodology: reconnaissance, auth bypass, request replication, and building scrapers. Also applicable when evaluating the security of your own API endpoints.

**Note:** This technique targets APIs that serve data to the browser via XHR/fetch. Server-side rendered pages require different approaches (see `scrapling` in TOOLS.md).

---

## The Method (5 Steps)

### 1. Reconnaissance — Network Tab Analysis

Open browser DevTools → Network tab → filter by `XHR` or `Fetch`.

Navigate the target site normally. Watch for:
- **API base URLs** — the domain and path pattern (e.g., `api-v2.example.io/v2/`)
- **Data endpoints** — which URLs return the actual data you want
- **Response format** — JSON, protobuf, GraphQL, etc.
- **Request headers** — any custom auth headers, tokens, API keys
- **Query parameters** — pagination, filters, sorting

**Key signal:** If data loads via XHR/fetch calls, the API is exposed. If the page is server-side rendered (SSR), there are no interceptable API calls — you'll need browser automation or HTML parsing instead.

**Red flag for the target:** Client-side data loading means every endpoint is visible to anyone with DevTools. If their business model is selling API access, this is a fundamental architecture flaw.

### 2. Auth Mechanism Analysis

Look at request headers for auth tokens. Common patterns:

| Pattern | Difficulty | Bypass approach |
|---|---|---|
| **No auth** | Trivial | Just call the endpoint |
| **Static API key in JS** | Easy | Search JS bundles for the key string |
| **Client-side token generation** | Easy | Reverse engineer the generation function from JS |
| **Cookie/session based** | Medium | Use a browser session or replicate cookies |
| **Server-issued JWT** | Medium | Need to authenticate first, then use the token |
| **TLS fingerprinting** | Hard | Use `curl_cffi` or `cloudscraper` to impersonate browser TLS |
| **HMAC/signed requests** | Hard | Must find the signing key/logic in JS |
| **Server-side only (no client API)** | N/A | Not applicable — use browser automation |

**To find auth logic in JS:**
1. In Network tab, find a request with the auth header
2. Right-click → "Copy as cURL" (useful for testing)
3. In Sources tab, search for the header name (e.g., `sol-aut`, `x-api-key`, `authorization`)
4. Trace the code that generates/attaches the header
5. Look for: `generateToken()`, `getAuthHeader()`, string concatenation patterns, `Math.random()`, `crypto.subtle`

**Example — Solscan's `sol-aut` header:**
```javascript
// Found in _app-*.js by searching for "sol-aut"
// Generates 40-char random string with fixed substring "B9dls0fK" inserted at random position
generateRandomString() {
    let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789==--",
        part1 = Array(16).join().split(",").map(() =>
            chars.charAt(Math.floor(Math.random() * chars.length))
        ).join(""),
        part2 = Array(16).join().split(",").map(() =>
            chars.charAt(Math.floor(Math.random() * chars.length))
        ).join(""),
        pos = Math.floor(31 * Math.random()),
        combined = part1 + part2;
    return [combined.slice(0, pos), "B9dls0fK", combined.slice(pos)].join("");
}
```

Python equivalent:
```python
import random
import string

def generate_sol_aut():
    chars = string.ascii_letters + string.digits + "==--"
    part1 = ''.join(random.choice(chars) for _ in range(15))
    part2 = ''.join(random.choice(chars) for _ in range(15))
    pos = random.randint(0, 30)
    combined = part1 + part2
    return combined[:pos] + "B9dls0fK" + combined[pos:]
```

### 3. Request Replication

Once you understand the auth, replicate the full request in Python:

```python
import requests

# Basic pattern
session = requests.Session()
session.headers.update({
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ...",
    "Accept": "application/json",
    "Referer": "https://target-site.com/",
    # Add auth headers
    "x-custom-auth": generate_auth_token(),
})

response = session.get("https://api.target-site.com/v2/endpoint", params={
    "address": target_address,
    "page": 1,
    "page_size": 100,
})
data = response.json()
```

**If Cloudflare protected**, use `cloudscraper`:
```python
import cloudscraper

scraper = cloudscraper.create_scraper(
    browser={"browser": "chrome", "platform": "darwin", "mobile": False}
)
scraper.headers.update({"x-custom-auth": generate_auth_token()})
response = scraper.get(url)
```

**If TLS fingerprinting is active**, use `curl_cffi`:
```python
from curl_cffi import requests as cffi_requests

response = cffi_requests.get(url, impersonate="chrome", headers={...})
```

### 4. Endpoint Discovery

Methods to find all available endpoints:

1. **Network tab monitoring** — browse every page/feature, log all API calls
2. **JS bundle search** — search for the API base URL in all JS files, extract path patterns
3. **Official API docs comparison** — if they publish paid API docs, the internal endpoints often mirror them
4. **Path fuzzing** — try common REST patterns: `/v2/account/{address}`, `/v2/token/{address}`, `/v2/transaction/{hash}`
5. **GraphQL introspection** — if GraphQL, try `{ __schema { types { name fields { name } } } }`

### 5. Building the Scraper

Structure for a reusable scraper:

```python
class APIClient:
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
        self._setup_headers()

    def _setup_headers(self):
        self.session.headers.update({
            "User-Agent": self._random_ua(),
            "Accept": "application/json",
        })

    def _auth_header(self):
        """Generate fresh auth token per request"""
        return {"x-custom-auth": generate_auth_token()}

    def _request(self, endpoint, params=None):
        """Rate-limited request with retry"""
        headers = self._auth_header()
        for attempt in range(3):
            try:
                resp = self.session.get(
                    f"{self.base_url}/{endpoint}",
                    params=params,
                    headers=headers,
                    timeout=10,
                )
                if resp.status_code == 200:
                    return resp.json()
                if resp.status_code == 429:
                    time.sleep(2 ** attempt)
                    continue
            except requests.exceptions.RequestException:
                time.sleep(1)
        return None

    def get_transaction(self, tx_hash):
        return self._request("transaction/detail", {"tx": tx_hash})

    def get_account(self, address):
        return self._request("account/info", {"address": address})
```

---

## Anti-Detection Measures

| Measure | How sites detect you | How to evade |
|---|---|---|
| **Rate limiting** | Too many requests per second | Add `time.sleep()` between requests, randomize intervals |
| **User-Agent checking** | Non-browser UA string | Rotate realistic UAs from a list |
| **Referer checking** | Missing or wrong Referer header | Set Referer to the site's own URL |
| **TLS fingerprinting** | Python requests has distinctive TLS fingerprint | Use `curl_cffi` with `impersonate="chrome"` |
| **Cloudflare/WAF** | JavaScript challenges, captchas | `cloudscraper` handles ~80% of cases. For the rest, use browser automation |
| **IP blocking** | Too many requests from one IP | Rotate proxies, use residential proxies |
| **Cookie validation** | Expecting specific cookies from initial page load | Load the page first in a session, then use the cookies |
| **Canvas/WebGL fingerprinting** | Browser fingerprint checking | Not relevant for API-only scraping |

---

## When NOT to Use This

- **Terms of Service explicitly prohibit it** — know the legal risk. This is educational knowledge.
- **The data is available through a free/cheap official API** — don't reinvent the wheel
- **You need reliability** — unofficial APIs break without notice
- **Production systems** — don't build critical infrastructure on reverse-engineered endpoints
- **When browser automation is simpler** — if the site is SSR or heavily protected, Playwright/Puppeteer may be faster to implement

---

## Solana-Specific: Solscan Scraper

Reference implementation for Solscan (educational):

**Install:** `pip install https://github.com/paoloanzn/free-solscan-api/releases/download/0.0.4/free_solscan_api-0.0.4-py3-none-any.whl`

**API base:** `https://api-v2.solscan.io/v2` (mirrors pro API at `https://pro-api.solscan.io/v2.0`)

**Available endpoints:** transaction, transactions, defi_activities, token_holders, transfers, token_holders_total, account_info, portfolio, balance_history, top_address_transfers, token_data

**Auth:** `sol-aut` header = 40-char random string with `"B9dls0fK"` inserted at random position. Generated client-side per request. Cloudflare added later (bypassed with cloudscraper).

**Usage:**
```python
import free_solscan_api

router = free_solscan_api.Router(free_solscan_api.solscan_endpoints)
tx = router.transaction("57YB5kSK...")
holders = router.token_holders("TokenAddress...", page=1, page_size=100)
```

---

## Security Audit Angle

When reviewing your OWN APIs, check for these anti-patterns:

1. **Client-side auth token generation** — if the browser generates the auth, there is no auth
2. **Same endpoints for web and paid API** — means free access is one DevTools away
3. **Unobfuscated auth logic in JS bundles** — search your own bundles for auth header names
4. **No rate limiting on internal endpoints** — the web-facing endpoints need limits too
5. **No TLS fingerprinting** — automated tools are trivially distinguishable from browsers
6. **Static magic strings as "secrets"** — a fixed substring in a random token is security theater

**The rule:** If your revenue depends on API access, the API endpoints MUST be server-side only (SSR the page, never expose raw data endpoints to the browser) OR use server-issued, short-lived tokens with proper rate limiting.
