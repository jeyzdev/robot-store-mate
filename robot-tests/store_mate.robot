*** Settings ***
Library           Browser
Suite Setup       Set Suite Variables
Test Setup        Open Store
Test Teardown     Close Browser
Test Timeout      2 minutes

*** Test Cases ***
SPRS-TC-002: Checkout Without Selection Keeps Payment Disabled
    [Documentation]    เพิ่มสินค้าในตะกร้า เอาเครื่องหมายเลือกออก และตรวจว่าชำระเงินไม่ได้
    Login To Storefront
    Open Product
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
    [Documentation]    ตรวจสอบข้อความและรายการสินค้าในตะกร้าว่าง
    Login To Storefront
    Open Cart
    Clear Cart If Needed
    Wait For Elements State    text=ไม่มีสินค้าในรถเข็น    visible    timeout=30s
    ${count}=    Get Element Count    css=[data-test="order-item"]
    Should Be Equal As Integers    ${count}    0

SPRS-TC-004: Update Product Quantity And Verify Total
    [Documentation]    เพิ่มจำนวนสินค้าจากหนึ่งเป็นสองและตรวจสอบยอดรวม
    Login To Storefront
    Open Cart
    Clear Cart If Needed
    Open Product
    Click    css=[data-test="btn-add-to-cart"]
    Open Cart
    ${quantity_input_count}=    Get Element Count    css=input[type="number"]
    IF    ${quantity_input_count} > 0
        Fill Text    css=input[type="number"]    2
        Press Keys    css=input[type="number"]    ENTER
    ELSE
        Click    css=[data-test="increase-product"]
    END
    Wait For Elements State    css=[data-test="item-quantity"]    visible
    Get Text    css=[data-test="item-quantity"]    ==    2
    Wait For Elements State    text=฿400    visible

SPRS-TC-005: Login With Valid Credentials
    [Documentation]    เข้าสู่ระบบด้วยบัญชีทดสอบที่ถูกต้อง
    Open Login Dialog
    Submit Login
    Wait For Elements State    css=[data-test="home-button"]    visible    timeout=30s

SPRS-TC-001: Successful Payment
    [Documentation]    เพิ่มสินค้าหนึ่งชิ้น ตรวจสอบคำสั่งซื้อ และชำระเงินสำเร็จ
    Login To Storefront
    Open Cart
    Clear Cart If Needed
    Open Product
    Click    css=[data-test="btn-add-to-cart"]
    Open Cart
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
    Click    css=[data-test="select-destination-desktop"]
    Click    css=[data-test="btn-confirm-payment-desktop"]
    ${newest_order}=    Set Variable    xpath=(//*[starts-with(@data-test, 'order-card-')])[1]
    Wait For Elements State    ${newest_order}    visible    timeout=60s
    ${url}=    Get Url
    Should Contain    ${url}    /orders
    Get Text    ${newest_order}//*[@data-test="order-item-name"]    *=    พิเศษสบู่ 3 ก้อน

*** Keywords ***
Set Suite Variables
    Set Suite Variable    ${BASE_URL}    https://storemate-final.vercel.app/
    Set Suite Variable    ${TEST_EMAIL}    %{STOREMATE_TEST_EMAIL=test2@gmail.com}
    Set Suite Variable    ${TEST_PASSWORD}    %{STOREMATE_TEST_PASSWORD=123456Za_}

Open Store
    New Browser    chromium    headless=${TRUE}
    New Context
    New Page    ${BASE_URL}

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
    Go To    ${BASE_URL}product/53
    ${current_url}=    Get Url
    Log    Storefront product URL: ${current_url}
    Wait For Elements State    css=[data-test="click-shop-cart"]    visible    timeout=30s

Open Product
    Go To    ${BASE_URL}product/53
    Wait For Elements State    css=[data-test="btn-add-to-cart"]    enabled    timeout=30s

Open Cart
    Wait For Elements State    css=[data-test="click-shop-cart"]    visible    timeout=30s
    Click    css=[data-test="click-shop-cart"]

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
