package haxe.ui.backend;

import flambe.asset.AssetPack;
import flambe.display.Font;
import haxe.ui.Toolkit;
import haxe.ui.core.Component;
import haxe.ui.backend.flambe.TextSpriteEx;
import haxe.ui.styles.Style;

class TextDisplayBase extends TextSpriteEx {
    public var parentComponent:Component;

    public function new() {
        super(null);
    }

    public var left(get, set):Float;
    private function get_left():Float {
        return this.x._;
    }
    private function set_left(value:Float):Float {
        this.x._ = value;
        return value;
    }

    public var top(get, set):Float;
    private function get_top():Float {
        return this.y._;
    }
    private function set_top(value:Float):Float {
        this.y._ = value;
        return value;
    }

    private var _width:Float;
    public var width(get, set):Float;
    public function set_width(value:Float):Float {
        if(_width == value) {
            return value;
        }

        _width = value;
        setWrapWidth(value);
        return value;
    }

    public function get_width():Float {
        return _width;
    }

    private var _height:Float;
    public var height(get, set):Float;
    public function set_height(value:Float):Float {
        if(_height == value) {
            return value;
        }

        _height = value;
        return value;
    }

    public function get_height() {
        return _height;
    }

    public var textWidth(get, null):Float;
    private function get_textWidth():Float {
        return getNaturalWidth();
    }

    public var textHeight(get, null):Float;
    private function get_textHeight():Float {
        return getNaturalHeight();
    }

    private var _fontName:String;
    private var _textAlign:String;
    public function applyStyle(style:Style) {
        if (style.color != null) {
            
        }
        if (style.fontName != null && style.fontName != _fontName) {
            _fontName = style.fontName;
            Toolkit.assets.getFont(_fontName, function(f) {
                var pack:AssetPack = ToolkitAssets.instance.assetPack;
                font = new Font(pack, _fontName.substr(0, _fontName.length - 4));
                parentComponent.invalidateLayout();
            });
        }
        if (style.fontSize != null) {
            
        }
        if (style.textAlign != null && style.textAlign != _textAlign) {
            _textAlign = style.textAlign;
            switch(_textAlign) {
                case "left":
                    align = TextAlign.Left;

                case "center":
                    align = TextAlign.Center;

                case "right":
                    align = TextAlign.Right;
            }
        }
    }
}