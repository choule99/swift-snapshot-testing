#if canImport(CoreImage)
    import CoreImage
    import CustomDump
    import XCTest

    final class CoreImageTests: XCTestCase {
        func testCIQRCodeDescriptor() {
            XCTAssertEqual(
                String(
                    customDumping: [.levelH, .levelL, .levelM, .levelQ]
                        as [CIQRCodeDescriptor.ErrorCorrectionLevel]
                ),
                """
                [
                  [0]: CIQRCodeDescriptor.ErrorCorrectionLevel.levelH,
                  [1]: CIQRCodeDescriptor.ErrorCorrectionLevel.levelL,
                  [2]: CIQRCodeDescriptor.ErrorCorrectionLevel.levelM,
                  [3]: CIQRCodeDescriptor.ErrorCorrectionLevel.levelQ
                ]
                """
            )

            XCTAssertEqual(
                String(customDumping: CIQRCodeDescriptor.ErrorCorrectionLevel.levelH),
                """
                CIQRCodeDescriptor.ErrorCorrectionLevel.levelH
                """
            )
        }
    }
#endif
