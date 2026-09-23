import AppKit

func generateIcons() {
    let arguments = CommandLine.arguments
    guard arguments.count >= 3 else {
        print("Usage: swift generate_icons.swift <source.png> <output_appicon_dir>")
        exit(1)
    }

    let sourcePath = arguments[1]
    let appIconDir = arguments[2]
    // MenuBarIcon.imageset lives next to the AppIcon set in the same asset catalog.
    let menuBarDir = URL(fileURLWithPath: appIconDir)
        .deletingLastPathComponent()
        .appendingPathComponent("MenuBarIcon.imageset")
        .path

    guard let sourceImage = NSImage(contentsOfFile: sourcePath) else {
        print("Could not load image at \(sourcePath)")
        exit(1)
    }

    let masterSize = 1024.0
    let appIconImage = NSImage(size: NSSize(width: masterSize, height: masterSize))
    appIconImage.lockFocus()

    // 1. Draw rounded rectangle background (macOS squircle)
    let margin = 56.0
    let squircleRect = NSRect(x: margin, y: margin, width: masterSize - 2 * margin, height: masterSize - 2 * margin)
    let cornerRadius = 200.0
    let path = NSBezierPath(roundedRect: squircleRect, xRadius: cornerRadius, yRadius: cornerRadius)

    // Gradient background: Dark slate / graphite
    let gradient = NSGradient(
        colors: [
            NSColor(red: 0.15, green: 0.17, blue: 0.22, alpha: 1.0),
            NSColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 1.0)
        ]
    )
    gradient?.draw(in: path, angle: -45)

    // Subtle border
    NSColor(white: 1.0, alpha: 0.12).setStroke()
    path.lineWidth = 4.0
    path.stroke()

    // 2. Draw white glyph inside
    // Find centered rect for glyph (~520px)
    let glyphSize = 520.0
    let glyphRect = NSRect(
        x: (masterSize - glyphSize) / 2.0,
        y: (masterSize - glyphSize) / 2.0,
        width: glyphSize,
        height: glyphSize
    )

    // We tint the source image to white
    if let cgImage = sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        // Clip to the mask of the image and fill white
        ctx?.clip(to: glyphRect, mask: cgImage)
        ctx?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
        ctx?.fill(glyphRect)
        ctx?.restoreGState()
    }

    appIconImage.unlockFocus()

    // Save various sizes for AppIcon
    let sizes: [(CGFloat, CGFloat, String)] = [
        (16, 1, "icon_16x16.png"),
        (16, 2, "icon_16x16@2x.png"),
        (32, 1, "icon_32x32.png"),
        (32, 2, "icon_32x32@2x.png"),
        (128, 1, "icon_128x128.png"),
        (128, 2, "icon_128x128@2x.png"),
        (256, 1, "icon_256x256.png"),
        (256, 2, "icon_256x256@2x.png"),
        (512, 1, "icon_512x512.png"),
        (512, 2, "icon_512x512@2x.png")
    ]

    for (base, scale, filename) in sizes {
        let pixelSize = base * scale
        let resized = NSImage(size: NSSize(width: base, height: base))
        resized.lockFocus()
        appIconImage.draw(in: NSRect(x: 0, y: 0, width: base, height: base), from: NSRect(x: 0, y: 0, width: masterSize, height: masterSize), operation: .copy, fraction: 1.0)
        resized.unlockFocus()

        if let tiff = resized.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let png = rep.representation(using: .png, properties: [:]) {
            let url = URL(fileURLWithPath: appIconDir).appendingPathComponent(filename)
            try? png.write(to: url)
        }
    }
    print("AppIcon files generated successfully.")

    // 3. Generate MenuBarIcon (18x18 and 36x36 template images)
    for (scale, filename) in [(1.0, "menubar_18x18.png"), (2.0, "menubar_18x18@2x.png")] {
        let size = 18.0 * scale
        let menuBarImage = NSImage(size: NSSize(width: size, height: size))
        menuBarImage.lockFocus()
        if let cgImage = sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            let ctx = NSGraphicsContext.current?.cgContext
            let destRect = NSRect(x: 1.0 * scale, y: 1.0 * scale, width: 16.0 * scale, height: 16.0 * scale)
            ctx?.saveGState()
            ctx?.clip(to: destRect, mask: cgImage)
            ctx?.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            ctx?.fill(destRect)
            ctx?.restoreGState()
        }
        menuBarImage.unlockFocus()

        if let tiff = menuBarImage.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let png = rep.representation(using: .png, properties: [:]) {
            let url = URL(fileURLWithPath: menuBarDir).appendingPathComponent(filename)
            try? png.write(to: url)
        }
    }
    print("MenuBarIcon files generated successfully.")
}

generateIcons()
