package haxe.ui;

import flambe.Entity;
import flambe.System;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.FillSprite;

class AppBase {
    private var _callback:Void->Void;
    
    public function new() {
        
    }
    
    private function build() {
        
    }
    
    private function init(callback:Void->Void, onEnd:Void->Void = null) {
        _callback = callback;
        
        // Wind up all platform-specific stuff
        System.init();

        // Load up the compiled pack in the assets directory named "bootstrap"
        var manifest = Manifest.fromAssets(Toolkit.backendProperties.getProp("haxe.ui.flambe.assets.pack", "bootstrap"));
        var loader = System.loadAssetPack(manifest);
        loader.get(onAssetsLoaded);
    }
    
    private function onAssetsLoaded(pack:AssetPack) {
		ToolkitAssets.instance.assetPack = pack;
        
        var background = new FillSprite(Toolkit.backendProperties.getPropCol("haxe.ui.flambe.background.color", 0xFFFFFF),
                                        System.stage.width, System.stage.height);
        System.root.addChild(new Entity().add(background));
        
        _callback();
    }
    
    private function getToolkitInit():Dynamic {
        return {
        };
    }
    
    public function start() {
        
    }
}