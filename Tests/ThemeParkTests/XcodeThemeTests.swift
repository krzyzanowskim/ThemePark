import XCTest
import ThemePark

final class XcodeThemeTests: XCTestCase {
	func testDefaultLightTheme() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "Default (Light)", withExtension: "xccolortheme", subdirectory: "TestData"))
		let theme = try XcodeTheme(contentsOf: url)

		XCTAssertEqual(theme.sourceTextBackground, "1 1 1 1")
		XCTAssertEqual(theme.invisibles, "0.8 0.8 0.8 1")
		XCTAssertEqual(theme.syntaxColors.count, 28)
		XCTAssertEqual(theme.supportedVariants, [.init(colorScheme: .light)])
		
		// Verify that version is properly decoded when DVTFontAndColorVersion key is present
		XCTAssertEqual(theme.version, 1)

		XCTAssertEqual(theme.syntaxColors["xcode.syntax.attribute"], "0.505801 0.371396 0.012096 1")
	}

	func testSemanticQueries() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "Default (Light)", withExtension: "xccolortheme", subdirectory: "TestData"))
		let theme = try XcodeTheme(contentsOf: url)

		// color equality here is actually quite tricky
		XCTAssertEqual(
			theme.style(for: .editor(.background)).color.toHex(),
			Style(color: PlatformColor(hex: "#ffffff")!).color.toHex()
		)
		XCTAssertEqual(
			theme.style(for: .syntax(.text(nil))).color.toHex(),
			PlatformColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.85).toHex()
		)
		XCTAssertEqual(
			theme.style(for: .syntax(.comment(nil))).color.toHex(),
			PlatformColor(red: 0.36526, green: 0.421879, blue: 0.475154, alpha: 1.0).toHex()
		)
		XCTAssertEqual(
			theme.style(for: .gutter(.background)),
			theme.style(for: .editor(.background))
		)
		XCTAssertEqual(
			theme.style(for: .gutter(.label)),
			theme.style(for: .syntax(.text(nil)))
		)
	}

	func testMissingDVTFontAndColorVersion() throws {
		// Create a minimal theme plist without DVTFontAndColorVersion key
		let themeWithoutVersionPlist = """
		<?xml version="1.0" encoding="UTF-8"?>
		<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
		<plist version="1.0">
		<dict>
			<key>DVTSourceTextBackground</key>
			<string>1 1 1 1</string>
			<key>DVTSourceTextSelectionColor</key>
			<string>0.642038 0.802669 0.999195 1</string>
			<key>DVTMarkupTextNormalColor</key>
			<string>0 0 0 1</string>
			<key>DVTMarkupTextNormalFont</key>
			<string>.AppleSystemUIFont - 10.0</string>
			<key>DVTSourceTextInvisiblesColor</key>
			<string>0.8 0.8 0.8 1</string>
			<key>DVTSourceTextSyntaxColors</key>
			<dict>
				<key>xcode.syntax.plain</key>
				<string>0 0 0 0.85</string>
			</dict>
			<key>DVTSourceTextSyntaxFonts</key>
			<dict>
				<key>xcode.syntax.plain</key>
				<string>SFMono-Regular - 12.0</string>
			</dict>
		</dict>
		</plist>
		"""
		
		let data = themeWithoutVersionPlist.data(using: .utf8)!
		let theme = try XcodeTheme(with: data)
		
		// Verify that version property is nil when DVTFontAndColorVersion key is missing
		XCTAssertNil(theme.version, "Version should be nil when DVTFontAndColorVersion key is missing from theme file")
		
		// Verify that other properties are still properly decoded
		XCTAssertEqual(theme.sourceTextBackground, "1 1 1 1")
		XCTAssertEqual(theme.selection, "0.642038 0.802669 0.999195 1")
		XCTAssertEqual(theme.invisibles, "0.8 0.8 0.8 1")
		XCTAssertEqual(theme.syntaxColors["xcode.syntax.plain"], "0 0 0 0.85")
		XCTAssertEqual(theme.syntaxFonts["xcode.syntax.plain"], "SFMono-Regular - 12.0")
	}
}
