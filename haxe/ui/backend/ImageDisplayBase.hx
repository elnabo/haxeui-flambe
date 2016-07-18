package haxe.ui.backend;

import flambe.display.ImageSprite;
import haxe.ui.assets.ImageInfo;

#if (html || js)
import js.Browser;
import js.html.*;
#else
import haxe.ui.util.ByteConverter;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.utils.ByteArray;
#end

class ImageDisplayBase extends ImageSprite {
    public var aspectRatio:Float = 1; // width x height

    private var _originalWidth:Float;
    private var _originalHeight:Float;

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

    public var imageWidth(get, set):Float;
    private function set_imageWidth(value:Float):Float {
        //this.scaleX._ = value / _originalWidth;
        return value;
    }

    private function get_imageWidth():Float {
        return this.getNaturalWidth() * this.scaleX._;
    }

    public var imageHeight(get, set):Float;
    private function set_imageHeight(value:Float):Float {
        //this.scaleY._ = value / _originalHeight;
        return value;
    }

    private function get_imageHeight():Float {
        return this.getNaturalHeight() * this.scaleY._;
    }


    private var _imageInfo:ImageInfo;
    public var imageInfo(get, set):ImageInfo;
    private function get_imageInfo():ImageInfo {
        return _imageInfo;
    }
    private function set_imageInfo(value:ImageInfo):ImageInfo {
        _imageInfo = value;
        this.texture = _imageInfo.data;
        _originalWidth = _imageInfo.width;
        _originalHeight = _imageInfo.height;
        aspectRatio = _imageInfo.width / _imageInfo.height;
        imageWidth = _imageInfo.width;
        imageHeight = _imageInfo.height;
        return value;
    }
}