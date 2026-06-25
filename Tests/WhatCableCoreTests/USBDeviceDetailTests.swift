import Foundation
import Testing
@testable import WhatCableCore

@Suite("USB device detail display helpers")
struct USBDeviceDetailTests {

    private func device(
        vendorID: UInt16 = 0,
        productID: UInt16 = 0,
        vendorName: String? = nil,
        serialNumber: String? = nil,
        usbVersion: String? = nil,
        busPowerMA: Int? = nil,
        currentMA: Int? = nil
    ) -> USBDevice {
        USBDevice(
            id: 1, locationID: 0x0100_0000, vendorID: vendorID, productID: productID,
            vendorName: vendorName, productName: "Widget", serialNumber: serialNumber,
            usbVersion: usbVersion, speedRaw: nil, busPowerMA: busPowerMA, currentMA: currentMA,
            rawProperties: [:]
        )
    }

    // MARK: - vendorDisplay

    @Test("vendorDisplay prefers the device-reported vendor name and appends VID:PID")
    func vendorDisplayUsesReportedName() {
        let d = device(vendorID: 0x05AC, productID: 0x12A8, vendorName: "Apple Inc.")
        #expect(d.vendorDisplay == "Apple Inc. (0x05AC:0x12A8)")
    }

    @Test("vendorDisplay falls back to the VID database when the device reports no name")
    func vendorDisplayFallsBackToDB() {
        // 0x05AC is Apple in the bundled USB-IF list.
        let d = device(vendorID: 0x05AC, productID: 0x12A8, vendorName: nil)
        #expect(d.vendorDisplay == "Apple (0x05AC:0x12A8)")
    }

    @Test("vendorDisplay shows bare hex when no name is available anywhere")
    func vendorDisplayBareHex() {
        // Sanity-check the precondition: this VID must be unknown to the DB for
        // the test to mean anything. 0xF00D is absent from the bundled list.
        #expect(VendorDB.name(for: 0xF00D) == nil)
        let d = device(vendorID: 0xF00D, productID: 0x0002, vendorName: nil)
        #expect(d.vendorDisplay == "0xF00D:0x0002")
    }

    // MARK: - declaredPowerDisplay

    @Test("declaredPowerDisplay shows both requested and available when present")
    func powerBoth() {
        let d = device(busPowerMA: 900, currentMA: 500)
        #expect(d.declaredPowerDisplay == "500 mA requested · 900 mA available")
    }

    @Test("declaredPowerDisplay shows only requested when available is absent")
    func powerRequestedOnly() {
        let d = device(busPowerMA: nil, currentMA: 500)
        #expect(d.declaredPowerDisplay == "500 mA requested")
    }

    @Test("declaredPowerDisplay shows only available when requested is absent")
    func powerAvailableOnly() {
        let d = device(busPowerMA: 900, currentMA: nil)
        #expect(d.declaredPowerDisplay == "900 mA available")
    }

    @Test("declaredPowerDisplay is nil when neither figure is present")
    func powerNeither() {
        let d = device(busPowerMA: nil, currentMA: nil)
        #expect(d.declaredPowerDisplay == nil)
    }
}
