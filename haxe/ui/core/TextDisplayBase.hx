package haxe.ui.core;

import flambe.asset.AssetPack;
import flambe.display.Font;
import haxe.ui.Toolkit;
import haxe.ui.core.Component;
import haxe.ui.flambe.TextSpriteEx;

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

    public var width(get, set):Float;
    public function set_width(value:Float):Float {
        return value;
    }

    public function get_width():Float {
        return textWidth;
    }

    public var height(get, set):Float;
    public function set_height(value:Float):Float {
        return value;
    }

    public function get_height() {
        return textHeight;
    }

    public var textWidth(get, null):Float;
    private function get_textWidth():Float {
        return getNaturalWidth();
    }

    public var textHeight(get, null):Float;
    private function get_textHeight():Float {
        return getNaturalHeight();
    }

    public var color(get, set):Int;
    private function get_color():Int {
        return 0;
    }
    private function set_color(value:Int):Int {
        return value;
    }

    private var _fontName:String;
    public var fontName(get, set):String;
    private function get_fontName():String {
        return _fontName;
    }
    private function set_fontName(value:String):String {
        if (value == _fontName) {
            return value;
        }
        _fontName = value;

        Toolkit.assets.getFont(value, function(f) {
            var pack:AssetPack = ToolkitAssets.instance.assetPack;
            font = new Font(pack, _fontName.substr(0, _fontName.length - 4));
            parentComponent.invalidateLayout();
        });

        return value;
    }

    private var _fontSize:Float;// = 16;
    public var fontSize(get, set):Null<Float>;
    private function get_fontSize():Null<Float> {
        return _fontSize;
    }
    private function set_fontSize(value:Null<Float>):Null<Float> {
        if (value == _fontSize) {
            return value;
        }
        return value;
    }
}