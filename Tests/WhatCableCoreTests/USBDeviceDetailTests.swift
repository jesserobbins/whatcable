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
        usbVersion: String? = nil
    ) -> USBDevice {
        USBDevice(
            id: 1, locationID: 0x0100_0000, vendorID: vendorID, productID: productID,
            vendorName: vendorName, productName: "Widget", serialNumber: serialNumber,
            usbVersion: usbVersion, speedRaw: nil, busPowerMA: nil, currentMA: nil,
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
}
