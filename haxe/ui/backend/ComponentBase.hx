package haxe.ui.backend;

import flambe.Entity;
import flambe.System;
import flambe.display.Graphics;
import flambe.display.Sprite;
import flambe.input.MouseCursor;
import flambe.input.PointerEvent;
import flambe.util.SignalConnection;
import haxe.ui.core.Component;
import haxe.ui.core.IComponentBase;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.core.UIEvent;
import haxe.ui.backend.flambe.StyleHelper;
import haxe.ui.styles.Style;
import haxe.ui.util.Rectangle;

class ComponentBase extends Sprite implements IComponentBase {
    private var _entity:Entity;
    private var _eventMap:Map<String, UIEvent->Void>;

    public function new() {
        super();
        _entity = new Entity();
        _eventMap = new Map<String, UIEvent->Void>();
        //this.pixelSnapping = false;
    }

    public function handleCreate(native:Bool):Void {

    }

    public override function getNaturalWidth():Float {
        return _naturalWidth;
    }

    public override function getNaturalHeight():Float {
        return _naturalHeight;
    }

    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    private var _textDisplay:TextDisplay;
    public function createTextDisplay(text:String = null):TextDisplay {
        if (_textDisplay == null) {
            _textDisplay = new TextDisplay();
            _textDisplay.parentComponent = cast this;
            _entity.add(_textDisplay);
        }
        if (text != null) {
            _textDisplay.text = text;
        }
        return _textDisplay;
    }

    public function getTextDisplay():TextDisplay {
        return createTextDisplay();
    }

    public function hasTextDisplay():Bool {
        return (_textDisplay != null);
    }

    private var _textInput:TextInput;
    public function createTextInput(text:String = null):TextInput {
        if (_textInput == null) {
            _textInput = new TextInput();
            _textInput.parentComponent = cast this;
            _entity.add(_textInput);
        }
        if (text != null) {
            _textInput.text = text;
        }
        return _textInput;
    }

    public function getTextInput():TextInput {
        return createTextInput();
    }

    public function hasTextInput():Bool {
        return (_textInput != null);
    }

    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    private var _imageDisplay:ImageDisplay;
    public function createImageDisplay():ImageDisplay {
        if (_imageDisplay == null) {
            _imageDisplay = new ImageDisplay();
            _entity.add(_imageDisplay);
        }
        return _imageDisplay;
    }

    public function getImageDisplay():ImageDisplay {
        return createImageDisplay();
    }

    public function hasImageDisplay():Bool {
        return (_imageDisplay != null);
    }


    public function removeImageDisplay():Void {
        if (_imageDisplay != null) {
            _entity.remove(_imageDisplay);
            _imageDisplay.dispose();
            _imageDisplay = null;
        }
    }

    //***********************************************************************************************************
    // Display tree
    //***********************************************************************************************************
    private var _childToEntity:Map<Component, Entity>;
    private function handleAddComponent(child:Component):Component {
        if (_childToEntity == null) {
            _childToEntity = new Map<Component, Entity>();
        }
        var childEntity:Entity = new Entity();
        childEntity.add(child);
        _entity.addChild(childEntity);
        _childToEntity.set(child, childEntity);
        return child;
    }

    private function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
        var childEntity:Entity = _childToEntity.get(child);
        _entity.removeChild(childEntity);
        return child;
    }

    private function handleVisibility(show:Bool):Void {
        this.visible = show;
    }

    //***********************************************************************************************************
    // Redraw callbacks
    //***********************************************************************************************************
    private function applyStyle(style:Style) {
        if (style.hidden != null) {
            this.visible = !style.hidden;
        }
    }

    private var _naturalWidth:Float = 0;
    private var _naturalHeight:Float = 0;
    private function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
        if (width == null || height == null || width <= 0 || height <= 0) {
            return;
        }

        _naturalWidth = width;
        _naturalHeight = height;
    }

    private function handlePosition(left:Null<Float>, top:Null<Float>, style:Style):Void {
        if (left != null) {
            this.x._ = left;
        }
        if (top != null) {
            this.y._ = top;
        }
    }

    private function handleClipRect(value:Rectangle):Void {
        this.scissor = new flambe.math.Rectangle(value.left, value.top, value.width, value.height);
        this.x._ = -value.left + 1;
        this.y._ = -value.top + 1;
    }

    private function handleReady() {

    }

    public function handlePreReposition():Void {
    }

    public function handlePostReposition():Void {
    }


    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    public override function onStart() {
        super.onStart();
        cast(this, Component).ready();
        owner.addChild(_entity);
    }

    //***********************************************************************************************************
    // Redraw
    //***********************************************************************************************************

    public override function draw(g:Graphics) {
        if (_naturalWidth <= 0 || _naturalHeight <= 0) {
            return;
        }

        var style:Style = cast(this, Component).style;
        StyleHelper.paintStyle(g, style, _naturalWidth, _naturalHeight);
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private var _pointerInConnection:SignalConnection;
    private var _pointerOutConnection:SignalConnection;
    private var _pointerDownConnection:SignalConnection;
    private var _pointerUpConnection:SignalConnection;

    private function mapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_OVER:
                if (_eventMap.exists(MouseEvent.MOUSE_OVER) == false) {
                    _pointerInConnection = this.pointerIn.connect(__onPointerOver);
                    _eventMap.set(MouseEvent.MOUSE_OVER, listener);
                }

            case MouseEvent.MOUSE_OUT:
                if (_eventMap.exists(MouseEvent.MOUSE_OUT) == false) {
                    _pointerOutConnection = this.pointerOut.connect(__onPointerOut);
                    _eventMap.set(MouseEvent.MOUSE_OUT, listener);
                }

            case MouseEvent.MOUSE_DOWN:
                if (_eventMap.exists(MouseEvent.MOUSE_DOWN) == false) {
                    _pointerDownConnection = this.pointerDown.connect(__onPointerDown);
                    _eventMap.set(MouseEvent.MOUSE_DOWN, listener);
                }

            case MouseEvent.MOUSE_UP:
                if (_eventMap.exists(MouseEvent.MOUSE_UP) == false) {
                    _pointerUpConnection = this.pointerUp.connect(__onPointerUp);
                    _eventMap.set(MouseEvent.MOUSE_UP, listener);
                }

            case MouseEvent.CLICK:
                if (_eventMap.exists(MouseEvent.CLICK) == false) {
                    _eventMap.set(MouseEvent.CLICK, listener);

                    if (_eventMap.exists(MouseEvent.MOUSE_DOWN) == false) {
                        _pointerDownConnection = this.pointerDown.connect(__onPointerDown);
                    }
                    if (_eventMap.exists(MouseEvent.MOUSE_UP) == false) {
                        _pointerUpConnection = this.pointerUp.connect(__onPointerUp);
                    }
                }
        }
    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {
        _eventMap.remove(type);

        if (_eventMap.exists(MouseEvent.MOUSE_OVER) == false) {
            if (_pointerInConnection != null) {
                _pointerInConnection.dispose();
                _pointerInConnection = null;
            }
        }
        if (_eventMap.exists(MouseEvent.MOUSE_OUT) == false) {
            if (_pointerOutConnection != null) {
                _pointerOutConnection.dispose();
                _pointerOutConnection = null;
            }
        }
        if (_eventMap.exists(MouseEvent.MOUSE_DOWN) == false
            && _eventMap.exists(MouseEvent.CLICK) == false) {
            if (_pointerDownConnection != null) {
                _pointerDownConnection.dispose();
                _pointerDownConnection = null;
            }
        }
        if (_eventMap.exists(MouseEvent.MOUSE_UP) == false
            && _eventMap.exists(MouseEvent.CLICK) == false) {
            if (_pointerUpConnection != null) {
                _pointerUpConnection.dispose();
                _pointerUpConnection = null;
            }
        }
    }

    private function __onPointerOver(event:PointerEvent):Void {
        dispatchMouseEvent(MouseEvent.MOUSE_OVER, event);

        var useHandCursor = false;
        var style:Style = cast(this, Component).style;
        if (style.cursor != null && style.cursor == "pointer") {
            useHandCursor = true;
        }
        if (useHandCursor == true) {
            System.mouse.cursor = MouseCursor.Button;
        }
    }

    private function __onPointerOut(event:PointerEvent):Void {
        dispatchMouseEvent(MouseEvent.MOUSE_OUT, event);

        var useHandCursor = false;
        var style:Style = cast(this, Component).style;
        if (style.cursor != null && style.cursor == "pointer") {
            useHandCursor = true;
        }
        if (useHandCursor == true) {
            System.mouse.cursor = MouseCursor.Default;
        }
    }

    private var _pointerDownFlag:Bool = false;
    private function __onPointerDown(event:PointerEvent):Void {
        _pointerDownFlag = true;
        dispatchMouseEvent(MouseEvent.MOUSE_DOWN, event);
    }

    private function __onPointerUp(event:PointerEvent):Void {
        if (_pointerDownFlag == true) {
            dispatchMouseEvent(MouseEvent.CLICK, event);
        }

        _pointerDownFlag = false;
        dispatchMouseEvent(MouseEvent.MOUSE_UP, event);
    }

    private function dispatchMouseEvent(type:String, copyFrom:PointerEvent):Void {
        var fn = _eventMap.get(type);
        if (fn != null) {
            var mouseEvent = new MouseEvent(type);
            mouseEvent.screenX = copyFrom.viewX;
            mouseEvent.screenY = copyFrom.viewY;
            fn(mouseEvent);
        }
    }
}