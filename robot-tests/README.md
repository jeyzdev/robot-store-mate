# Robot Framework tests

The suite uses Robot Framework Browser, which drives Playwright through the Browser library.

Run these commands from the `robot-store-mate` directory.

## Install (PowerShell)

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
rfbrowser init chromium
```

Node.js 18, 20, or 22 is supported by the pinned Browser library. The first `rfbrowser init` downloads Playwright's Chromium browser.

## Run

```powershell
robot --outputdir robot-results robot-tests\store_mate.robot
```

Override the test account without editing the suite:

```powershell
$env:STOREMATE_TEST_EMAIL = 'test2@gmail.com'
$env:STOREMATE_TEST_PASSWORD = 'your-test-password'
```

The suite runs cases sequentially because they share the same test account and shopping cart. TC-001 submits a Stripe test-mode payment.
