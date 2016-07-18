package haxe.ui.backend.flambe;

import flambe.display.Graphics;
import flambe.display.Texture;
import haxe.ui.assets.ImageInfo;
import haxe.ui.styles.Style;
import haxe.ui.util.ColorUtil;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Slice9;

class StyleHelper {
    public static function paintStyle(g:Graphics, style:Style, w:Float, h:Float):Void {
        var x:Float = 0;
        var y:Float = 0;

        if (style.borderLeftSize != null
            && style.borderLeftSize == style.borderRightSize
            && style.borderLeftSize == style.borderBottomSize
            && style.borderLeftSize == style.borderTopSize) { // full border

            var borderSize:Float = style.borderLeftSize;

            g.fillRect(style.borderTopColor, x, y, w, borderSize); // top
            g.fillRect(style.borderRightColor, x + w - borderSize, y, borderSize, h); // right
            g.fillRect(style.borderBottomColor, x, y + h - borderSize, w, borderSize); // bottom
            g.fillRect(style.borderLeftColor, x, y, borderSize, h); // left

            x += borderSize;
            y += borderSize;
            w -= borderSize * 2;
            h -= borderSize * 2;

        } else if (style.borderLeftSize == null
            && style.borderRightSize == null
            && style.borderBottomSize == null
            && style.borderTopSize == null) { // no border
        } else { // compound border
            if (style.borderTopSize != null && style.borderTopSize > 0) {
                g.fillRect(style.borderTopColor, x, y, w, style.borderTopSize); // top
                y += style.borderTopSize;
                h -= style.borderTopSize;
            }

            if (style.borderLeftSize != null && style.borderLeftSize > 0) {
                g.fillRect(style.borderLeftColor, x, y, style.borderLeftSize, h); // left
                x += style.borderLeftSize;
                w -= style.borderLeftSize;
            }

            if (style.borderBottomSize != null && style.borderBottomSize > 0) {
                g.fillRect(style.borderBottomColor, x, y + h - style.borderBottomSize, w, style.borderBottomSize); // bottom
                h -= style.borderBottomSize;
            }

            if (style.borderRightSize != null && style.borderRightSize > 0) {
                g.fillRect(style.borderRightColor, x + w - style.borderRightSize, y, style.borderRightSize, h); // right
                w -= style.borderRightSize;
            }
        }

        if (style.backgroundColor != null) {
            if (style.backgroundColorEnd != null && style.backgroundColor != style.backgroundColorEnd) {
                var gradientType:String = "vertical";
                if (style.backgroundGradientStyle != null) {
                    gradientType = style.backgroundGradientStyle;
                }

                var arr:Array<Int> = null;
                var n:Int = 0;
                if (gradientType == "vertical") {
                    arr = ColorUtil.buildColorArray(style.backgroundColor, style.backgroundColorEnd, Std.int(h));
                    for (c in arr) {
                        g.fillRect(c, x, y + n, w, 1);
                        n++;
                    }
                } else if (gradientType == "horizontal") {
                    arr = ColorUtil.buildColorArray(style.backgroundColor, style.backgroundColorEnd, Std.int(w));
                    for (c in arr) {
                        g.fillRect(c, x + n, y, 1, h);
                        n++;
                    }
                }
            } else {
                g.fillRect(style.backgroundColor, x, y, w, h);
                /*
                g.fillRect(0xFFFFFF, x, y, w, h);
                drawShadow(g, 0x888888, x, y, w, h, 3, true);
                */
            }
        }

        if (style.backgroundImage != null) {
            Toolkit.assets.getImage(style.backgroundImage, function(imageInfo:ImageInfo) {
                paintBitmapBackground(g, imageInfo.data, style, new Rectangle(x, y, w, h));
            });
        }

        if (style.filter != null) {
            drawShadow(g, 0x888888 | 0x444444, x, y, w, h, 1, true);
        }
    }

    private static function drawShadow(g:Graphics, color:Int, x:Float, y:Float, w:Float, h:Float, size:Int, inset:Bool = false):Void {
        if (inset == false) {
            for (i in 0...size) {
                g.setAlpha(1 - ((1 / size) * i));
                g.setAlpha(.5);
                g.fillRect(color, x + i, y + w + 1 + i, w + 1, 1); // bottom
                g.fillRect(color, x + w + 1 + i, y + i, 1, h + 2); // right
            }
        } else {
            for (i in 0...size) {
                g.setAlpha(1 - ((1 / size) * i));
                g.setAlpha(.5);
                g.fillRect(color, x + i, y + i, w - i, 1); // top
                g.fillRect(color, x + i, y + i, 1, h - i); // left
            }
        }
        g.setAlpha(1);
    }

    private static function paintBitmapBackground(graphics:Graphics, texture:Texture, style:Style, rc:Rectangle) {
        var trc:Rectangle = new Rectangle(0, 0, texture.width, texture.height);
        if (style.backgroundImageClipTop != null
            && style.backgroundImageClipLeft != null
            && style.backgroundImageClipBottom != null
            && style.backgroundImageClipRight != null) {
                trc = new Rectangle(style.backgroundImageClipLeft,
                                    style.backgroundImageClipTop,
                                    style.backgroundImageClipRight - style.backgroundImageClipLeft,
                                    style.backgroundImageClipBottom - style.backgroundImageClipTop);
        }

        var slice:Rectangle = null;
        if (style.backgroundImageSliceTop != null
            && style.backgroundImageSliceLeft != null
            && style.backgroundImageSliceBottom != null
            && style.backgroundImageSliceRight != null) {
            slice = new Rectangle(style.backgroundImageSliceLeft,
                                  style.backgroundImageSliceTop,
                                  style.backgroundImageSliceRight - style.backgroundImageSliceLeft,
                                  style.backgroundImageSliceBottom - style.backgroundImageSliceTop);
        }

        if (slice == null) {
            if (style.backgroundImageRepeat == null) {
                graphics.drawSubTexture(texture, 0, 0, 0, 0, trc.width, trc.height);
            } else if (style.backgroundImageRepeat == "repeat") {
                graphics.drawPattern(texture, 0, 0, rc.width, rc.height);
            } else if (style.backgroundImageRepeat == "stretch") {
                graphics.save();
                var sx:Float = rc.width / trc.width;
                var sy:Float = rc.height / trc.height;
                graphics.scale(sx, sy);
                graphics.drawSubTexture(texture, 0, 0, 0, 0, trc.width, trc.height);
                graphics.restore();
            }
        } else {
            var rects:Slice9Rects = Slice9.buildRects(rc.width, rc.height, trc.width, trc.height, slice);
            var srcRects:Array<Rectangle> = rects.src;
            var dstRects:Array<Rectangle> = rects.dst;
            for (i in 0...srcRects.length) {
                var srcRect = new Rectangle(srcRects[i].left + trc.left,
                                            srcRects[i].top + trc.top,
                                            srcRects[i].width,
                                            srcRects[i].height);
                var dstRect = dstRects[i];
                paintBitmap(graphics, texture, srcRect, dstRect);
            }
        }
    }

    private static function paintBitmap(graphics:Graphics, texture:Texture, srcRect:Rectangle, dstRect:Rectangle) {
        graphics.save();
        var sx:Float = dstRect.width / srcRect.width;
        var sy:Float = dstRect.height / srcRect.height;
        graphics.scale(sx, sy);
        graphics.drawSubTexture(texture, dstRect.left / sx, dstRect.top / sy, srcRect.left, srcRect.top, srcRect.width, srcRect.height);
        graphics.restore();
    }
}