package haxe.ui.backend.flambe;

import flambe.display.Font;
import flambe.display.Graphics;
import flambe.display.TextSprite;

class TextSpriteEx extends TextSprite {
    public function new(font :Font, ?text :String = "") {
        super(font, text);
    }

    override private function updateLayout() {
        if (_font == null) {
            return;
        }

        super.updateLayout();
    }

    override public function getNaturalWidth():Float {
        updateLayout();
        if (_layout == null) {
            return 0;
        }
        return super.getNaturalWidth();
    }

    override public function getNaturalHeight():Float {
        updateLayout();
        if (_layout == null) {
            return 0;
        }
        return super.getNaturalHeight();
    }

    override public function containsLocal(localX:Float, localY:Float):Bool {
        if (_layout == null) {
            return false;
        }
        return super.containsLocal(localX, localY);
    }

    override public function draw(g:Graphics) {
        if (_layout == null) {
            return;
        }
        super.draw(g);
    }
}