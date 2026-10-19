*** Settings ***
Library           Browser
Suite Setup       Set Suite Variables
Test Setup        Open Store
Test Teardown     Close Browser
Test Timeout      2 minutes

*** Test Cases ***
SPRS-TC-002: Checkout Without Selection Keeps Payment Disabled
    [Documentation]    ไม่เลือกสินค้าในตะกร้าแล้วปุ่มชำระเงินต้อง Disabled
    Login To Storefront
    Open Cart
    Clear Cart If Needed
    Open Product From Home
    Click    css=[data-test="btn-add-to-cart"]
    Open Cart
    ${checked}=    Get Checkbox State    css=[data-test="checkbox-product-53"]
    IF    ${checked}
        Uncheck Checkbox    css=[data-test="checkbox-product-53"]
    END
    Get Checkbox State    css=[data-test="checkbox-product-53"]    ==    unchecked
    ${states}=    Get Element States    css=[data-test="btn-payment"]
    Should Contain    ${states}    disabled
    ${url}=    Get Url
    Should Not Match Regexp    ${url}    (?i).*/(payment|checkout).*

SPRS-TC-003: Empty Cart State
    [Documentation]    ล้างสินค้าเดิมและตรวจสอบสถานะตะกร้าว่าง
    Login To Storefront
    Open Cart
    Clear Cart If Needed
    Wait For Elements State    text=ไม่มีสินค้าในรถเข็น    visible    timeout=30s
    ${count}=    Get Element Count    css=[data-test="order-item"]
    Should Be Equal As Integers    ${count}    0

SPRS-TC-004: Update Product Quantity And Verify Total
    [Documentation]    เปลี่ยนจำนวนสินค้าเป็นสองและตรวจยอดรวม ฿400
    Login To Storefront
    Open Cart
    Clear Cart If Needed
    Open Product From Home
    Click    css=[data-test="btn-add-to-cart"]
    Open Cart
    ${quantity_input_count}=    Get Element Count    css=input[type="number"]
    IF    ${quantity_input_count} > 0
        Get Property    css=input[type="number"]    value    ==    1
        Fill Text    css=input[type="number"]    2
        Press Keys    css=input[type="number"]    ENTER
    ELSE
        Click    css=[data-test="increase-product"]
    END
    Get Text    css=[data-test="item-quantity"]    ==    2
    Wait For Elements State    text=฿400    visible

SPRS-TC-005: Login With Valid Credentials
    [Documentation]    เข้าสู่ระบบด้วยข้อมูลที่ถูกต้องและตรวจหน้าแรกหลังล็อกอิน
    Open Login Dialog
    Submit Login
    Wait For Elements State    css=[data-test="home-button"]    visible    timeout=30s

SPRS-TC-006: Successful Credit Card Payment
    [Documentation]    ชำระเงินสำเร็จด้วยบัตรทดสอบ Stripe และตรวจสอบออเดอร์ล่าสุด
    Login To Storefront
    Open Cart
    Clear Cart If Needed
    Open Product From Home
    Click    css=[data-test="btn-add-to-cart"]
    Open Cart
    Set Cart Quantity To One
    Get Text    css=[data-test="item-quantity"]    ==    1
    Check Checkbox    css=[data-test="checkbox-product-53"]
    Click    css=[data-test="btn-payment"]
    Wait For Elements State    css=[data-test="address"]    visible
    Get Text    css=[data-test="address"]    *=    123 ถนนสุขุมวิท ต.บางขุนเทียน อ.เขตจอมทอง จ.กรุงเทพมหานคร 10150
    Get Text    css=[data-test="order-item"]    *=    X 1
    Get Text    css=[data-test="order-item"]    *=    ฿ 200
    Get Text    css=[data-test="product-name"]    *=    พิเศษสบู่ 3 ก้อน
    Get Text    role=main    *=    ยอดชำระทั้งหมด
    Get Text    role=main    *=    ฿ 200
    Get Text    role=main    *=    ยืนยันการชำระเงิน
    Click    css=[data-test="select-credit-desktop"]
    ${saved_card_count}=    Get Element Count    xpath=//button[contains(., "TEST CUSTOMER") and contains(., "4242")]
    IF    ${saved_card_count} == 0
        Click    css=[data-test="btn-add-credit-card-desktop"]
        ${url}=    Get Url
        Should Contain    ${url}    /add-credit-card
        Fill Text    css=#cardName    TEST CUSTOMER
        Fill Text    css=[data-test="card-number-input"] iframe >>> input[name="cardnumber"]    4242 4242 4242 4242
        Fill Text    css=[data-test="card-expiry-input"] iframe >>> input[name="exp-date"]    12 / 30
        Fill Text    css=[data-test="card-cvc-input"] iframe >>> input[name="cvc"]    123
        Click    xpath=(//button[normalize-space(.)="ยืนยันข้อมูลบัตร"])[1]
        Wait For Elements State    css=[data-test="address"]    visible
        Click    css=[data-test="select-credit-desktop"]
    END
    Click    xpath=(//button[contains(., "TEST CUSTOMER") and contains(., "4242")])[1]
    Click    css=[data-test="btn-confirm-payment-desktop"]
    Wait For Elements State    xpath=(//*[starts-with(@data-test, 'order-card-')])[1]    visible    timeout=60s
    ${url}=    Get Url
    Should Contain    ${url}    /orders
    Get Text    xpath=(//*[starts-with(@data-test, 'order-card-')])[1]//*[@data-test="order-item-name"]    *=    พิเศษสบู่ 3 ก้อน

SPRS-TC-007: Credit Card Details Are Required
    [Documentation]    ไม่กรอกข้อมูลบัตรแล้วปุ่มยืนยันข้อมูลบัตรต้อง Disabled
    Login To Storefront
    Open Cart
    Clear Cart If Needed
    Open Product From Home
    Click    css=[data-test="btn-add-to-cart"]
    Open Cart
    Check Checkbox    css=[data-test="checkbox-product-53"]
    Click    css=[data-test="btn-payment"]
    Click    css=[data-test="select-credit-desktop"]
    Click    css=[data-test="btn-add-credit-card-desktop"]
    ${url}=    Get Url
    Should Contain    ${url}    /add-credit-card
    Get Property    css=#cardName    value    ==    ${EMPTY}
    ${states}=    Get Element States    xpath=//button[normalize-space(.)="ยืนยันข้อมูลบัตร"]
    Should Contain    ${states}    disabled
    ${url}=    Get Url
    Should Not Contain    ${url}    /orders

*** Keywords ***
Set Suite Variables
    Set Suite Variable    ${BASE_URL}    https://storemate-final.vercel.app/
    Set Suite Variable    ${TEST_EMAIL}    %{STOREMATE_TEST_EMAIL=test2@gmail.com}
    Set Suite Variable    ${TEST_PASSWORD}    %{STOREMATE_TEST_PASSWORD=123456Za_}

Open Store
    New Browser    chromium    headless=${TRUE}
    New Context
    New Page    ${BASE_URL}    wait_until=domcontentloaded

Open Login Dialog
    Click    css=[data-test="login-btn"]
    Wait For Elements State    css=[data-test="email"]    visible    timeout=15s

Submit Login
    Fill Text    css=[data-test="email"]    ${TEST_EMAIL}
    Fill Text    css=[data-test="password"]    ${TEST_PASSWORD}
    Click    css=[data-test="btn-submit"]
    Wait For Elements State    text=เข้าสู่ระบบสำเร็จ    visible    timeout=30s
    Wait For Elements State    text=เข้าสู่ระบบสำเร็จ    hidden    timeout=30s
    Wait For Elements State    css=[data-test="home-button"]    visible    timeout=60s

Login To Storefront
    Open Login Dialog
    Submit Login
    Go To    ${BASE_URL}product/53    wait_until=domcontentloaded
    Wait For Elements State    css=[data-test="click-shop-cart"]    visible    timeout=30s

Open Product From Home
    Click    css=[data-test="home-button"]
    Click    xpath=//a[contains(normalize-space(.), "พิเศษสบู่ 3")]
    Wait For Elements State    css=[data-test="btn-add-to-cart"]    enabled    timeout=30s

Open Cart
    Wait For Elements State    css=[data-test="click-shop-cart"]    visible    timeout=30s
    Click    css=[data-test="click-shop-cart"]

Set Cart Quantity To One
    ${quantity_input_count}=    Get Element Count    css=input[type="number"]
    IF    ${quantity_input_count} > 0
        ${quantity}=    Get Property    css=input[type="number"]    value
        IF    $quantity != '1'
            Fill Text    css=input[type="number"]    1
            Press Keys    css=input[type="number"]    ENTER
        END
    ELSE
        ${quantity}=    Get Text    css=[data-test="item-quantity"]
        ${quantity}=    Convert To Integer    ${quantity}
        WHILE    ${quantity} > 1
            Click    css=[data-test="decrease-product"]
            ${quantity}=    Evaluate    ${quantity} - 1
        END
    END

Clear Cart If Needed
    ${remove_all}=    Set Variable    xpath=//button[normalize-space(.)="ลบออกทั้งหมด"]
    ${empty_cart}=    Set Variable    xpath=//*[normalize-space(.)="ไม่มีสินค้าในรถเข็น"]
    Wait For Elements State    xpath=//button[normalize-space(.)="ลบออกทั้งหมด"] | //*[normalize-space(.)="ไม่มีสินค้าในรถเข็น"]    visible    timeout=30s
    ${item_count}=    Get Element Count    ${remove_all}
    IF    ${item_count} > 0
        Check Checkbox    css=[data-test="radio-all-product"]
        Click    ${remove_all}
        Click    xpath=//button[normalize-space(.)="ยืนยัน"]
    END
    Wait For Elements State    ${empty_cart}    visible    timeout=30s
