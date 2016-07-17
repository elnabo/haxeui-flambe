package haxe.ui;

import flambe.System;
import flambe.asset.AssetPack;
import flambe.asset.File;
import flambe.display.Texture;
import flambe.platform.BasicFile;
import haxe.Resource;
import haxe.io.Bytes;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;

#if html
import js.Browser;
import js.html.*;
#else
import haxe.ui.util.ByteConverter;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.utils.ByteArray;
#end

class AssetsBase {
	private var _assetPack:AssetPack;
	
	public function new() {
		
	}
	
    public var assetPack(get, set):AssetPack;
    private function get_assetPack():AssetPack {
        if (_assetPack != null) {
            return _assetPack;
        }
        var options = cast(this, ToolkitAssets).options;
        if (options == null) {
            return null;
        }
        return options.assetPack;
    }
    private function set_assetPack(value:AssetPack):AssetPack {
        _assetPack = value;
        return value;
    }
    
	private function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
		try {
			if (assetPack != null) {
				var t:Texture = assetPack.getTexture(getAssetName(resourceId));
				var imageInfo:ImageInfo = {
					width: t.width,
					height: t.height,
					data: t
				}
				callback(imageInfo);
			} else {
				callback(null);
			}
		} catch (ex:Dynamic) {
			callback(null);
		}
	}
	
	private function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void) {
		var bytes:Bytes = Resource.getBytes(resourceId);
		
		#if html
		
		var image = Browser.document.createImageElement();
		image.onload = function(e) {
			var t = System.renderer.createTextureFromImage(image);
			var imageInfo:ImageInfo = {
				width: t.width,
				height: t.height,
				data: t
			}
			callback(resourceId, imageInfo);
			
		}
		var base64:String = haxe.crypto.Base64.encode(bytes);
		image.src = "data:image/png;base64," + base64;
		
		#else
		
		var ba:ByteArray = ByteConverter.fromHaxeBytes(bytes);
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e) {
			if (loader.content != null) {
				var bmpData = cast(loader.content, Bitmap).bitmapData;
				var t = System.renderer.createTextureFromImage(bmpData);
				var imageInfo:ImageInfo = {
					width: t.width,
					height: t.height,
					data: t
				}
				callback(resourceId, imageInfo);
				
			}
		});
		loader.loadBytes(ba);
		
		#end
	}
	
	private function getFontInternal(resourceId:String, callback:FontInfo->Void):Void {
		try {
			if (assetPack != null) {
				var f:File = assetPack.getFile(resourceId);
				if (f != null) {
					callback({
                        data: null
                    });
				} else {
					callback(null);
				}
			}
		} catch (ex:Dynamic) {
			callback(null);
		}
	}
	
	private function getFontFromHaxeResource(resourceId:String, callback:String->FontInfo->Void) {
		var text = Resource.getString(resourceId);
		if (text == null) {
			callback(resourceId, null);
			return;
		}

		var n1 = text.indexOf("file=");
		n1 += 6;
		var n2 = text.indexOf("\"", n1);
		var file = text.substring(n1, n2);
		var arr = resourceId.split("/");
		arr.pop();
		var path = arr.join("/");
		var textureId:String = path + "/" + file;
		
		
		var map:Map<String, Dynamic> = Reflect.field(assetPack, "files");
		map.set(resourceId, new BasicFile(text));
		getImageFromHaxeResource(textureId, function(r, info) {
			var map:Map<String, Dynamic> = Reflect.field(assetPack, "textures");
			map.set(textureId.substr(0, textureId.length - 4), info.data);
			callback(resourceId, {
                data: null
            });
		});
	}
	
	public function getTextDelegate(resourceId:String):String {
		try {
			if (assetPack == null) {
				return null;
			}
			var f:File = assetPack.getFile(resourceId);
			if (f != null) {
				return f.toString();
			}
		} catch (e:Dynamic) {
			trace(e);
		}
		return null;
	}
	
	private function getAssetName(resourceId:String):String {
		var s = resourceId;
		if (s.indexOf(".") != -1) {
			var n = s.lastIndexOf(".");
			s = s.substr(0, n);
		}
		return s;
	}
}