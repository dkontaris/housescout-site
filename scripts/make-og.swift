import AppKit
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

// Composes a 1200x630 Open Graph social card: brand text on the left, a phone
// screenshot bleeding off the right. DKC palette.
let W = 1200.0, H = 630.0
let out = CommandLine.arguments[1]
let iconPath = CommandLine.arguments[2]
let shotPath = CommandLine.arguments[3]

let cs = CGColorSpaceCreateDeviceRGB()
func rgb(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) -> CGColor {
    CGColor(colorSpace: cs, components: [r, g, b, a])!
}
let cream = rgb(0.980, 0.976, 0.969)
let creamWarm = rgb(0.949, 0.918, 0.882)
let ink = rgb(0.102, 0.102, 0.102)
let sec = rgb(0.353, 0.353, 0.353)
let accentInk = rgb(0.651, 0.322, 0.122)
let accentTint = rgb(0.957, 0.902, 0.855)
let dark = rgb(0.102, 0.102, 0.102)

guard let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8,
                          bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    fatalError("ctx")
}

let grad = CGGradient(colorsSpace: cs, colors: [cream, creamWarm] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])

func loadImage(_ path: String) -> CGImage? {
    guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(src, 0, nil)
}
func roundedPath(_ r: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}
func font(_ name: String, _ size: CGFloat) -> CTFont { CTFontCreateWithName(name as CFString, size, nil) }
func draw(_ s: String, font f: CTFont, color: CGColor, x: CGFloat, baseline y: CGFloat) {
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: color]))
    ctx.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, ctx)
}
func width(_ s: String, font f: CTFont) -> CGFloat {
    CTLineGetTypographicBounds(CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: [.font: f])), nil, nil, nil)
}

// Phone screenshot (right, bleeds top & bottom)
let phoneW = 362.0
let phoneH = phoneW * 2868.0 / 1320.0
let phoneRect = CGRect(x: 812, y: H / 2 + 8 - phoneH / 2, width: phoneW, height: phoneH)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -16), blur: 48, color: rgb(0.1, 0.08, 0.05, 0.30))
ctx.addPath(roundedPath(phoneRect.insetBy(dx: -12, dy: -12), 54)); ctx.setFillColor(dark); ctx.fillPath()
ctx.restoreGState()
if let shot = loadImage(shotPath) {
    ctx.saveGState()
    ctx.addPath(roundedPath(phoneRect, 44)); ctx.clip()
    ctx.draw(shot, in: phoneRect)
    ctx.restoreGState()
}

let leftX = 80.0

// Icon
if let icon = loadImage(iconPath) {
    let r = CGRect(x: leftX, y: H - 72 - 92, width: 92, height: 92)
    ctx.saveGState()
    ctx.addPath(roundedPath(r, 22)); ctx.clip()
    ctx.draw(icon, in: r)
    ctx.restoreGState()
}

draw("HouseScout", font: font("AvenirNext-Bold", 66), color: ink, x: leftX, baseline: H - 268)
let tag = font("AvenirNext-Medium", 29)
draw("Score every home against", font: tag, color: sec, x: leftX, baseline: H - 324)
draw("what actually matters to you.", font: tag, color: sec, x: leftX, baseline: H - 364)

// Pills
let pillFont = font("AvenirNext-DemiBold", 19)
var px = leftX
let pillY = 128.0, pillH = 44.0, padX = 19.0
for p in ["No ads", "No tracking", "Free"] {
    let w = width(p, font: pillFont) + padX * 2
    ctx.addPath(roundedPath(CGRect(x: px, y: pillY, width: w, height: pillH), pillH / 2))
    ctx.setFillColor(accentTint); ctx.fillPath()
    draw(p, font: pillFont, color: accentInk, x: px + padX, baseline: pillY + (pillH - CTFontGetCapHeight(pillFont)) / 2)
    px += w + 12
}

draw("housescout.dkcreative.uk", font: font("AvenirNext-Medium", 21), color: sec, x: leftX, baseline: 60)

guard let image = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
    fatalError("dest")
}
CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.86] as CFDictionary)
CGImageDestinationFinalize(dest)
print("wrote \(out)")
