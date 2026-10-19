# Robot Framework tests

The suite uses Robot Framework Browser, which drives Playwright through the Browser library.

Run these commands from the `robot-store-mate` directory.

## Install (PowerShell)

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m Browser.entry install chromium
```

The pinned BrowserBatteries package includes the Node.js runtime and Browser library dependencies. Install Chromium once after installing the Python packages.

## Run

```powershell
robot --outputdir robot-results robot-tests\store_mate.robot
```

Override the test account without editing the suite:

```powershell
$env:STOREMATE_TEST_EMAIL = 'test2@gmail.com'
$env:STOREMATE_TEST_PASSWORD = 'your-test-password'
```

The suite contains SPRS-TC-002 through SPRS-TC-007 and runs cases sequentially because they share the same test account and shopping cart. SPRS-TC-006 submits a Stripe test-mode payment with card `4242 4242 4242 4242`; SPRS-TC-007 checks that card details are required.
