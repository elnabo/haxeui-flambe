package haxe.ui.backend;

import flambe.Entity;
import flambe.System;
import flambe.util.SignalConnection;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.DialogButton;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;

class ScreenBase {
    private var _mapping:Map<String, UIEvent->Void>;
    private var _entityMap:Map<Component, Entity> = new Map<Component, Entity>();

    public function new() {
        _mapping = new Map<String, UIEvent->Void>();
    }

    public var options(default, default):Dynamic;

    public var width(get, null):Float;
    public function get_width():Float {
        return System.stage.width;
    }

    public var height(get, null):Float;
    public function get_height() {
        return System.stage.height;
    }

    public var focus(get, set):Component;
    private function get_focus():Component {
        return null;
    }
    private function set_focus(value:Component):Component {
        return value;
    }

    public function addComponent(component:Component) {
        resizeComponent(component);
        var entity = new Entity().add(component);
        _entityMap.set(component, entity);
        System.root.addChild(entity);
    }

    public function removeComponent(component:Component) {
        var entity = _entityMap.get(component);
        _entityMap.remove(component);
        System.root.removeChild(entity);
    }

    private function resizeComponent(c:Component) {
        if (c.percentWidth > 0) {
            c.width = (this.width * c.percentWidth) / 100;
        }
        if (c.percentHeight > 0) {
            c.height = (this.height * c.percentHeight) / 100;
        }
    }

    private function handleSetComponentIndex(child:Component, index:Int) {
        
    }
    //***********************************************************************************************************
    // Dialogs
    //***********************************************************************************************************
    public function messageDialog(message:String, title:String = null, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        return null;
    }

    public function showDialog(content:Component, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        return null;
    }

    public function hideDialog(dialog:Dialog):Bool {
        return false;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private var _mouseDownConnection:SignalConnection;
    private var _mouseUpConnection:SignalConnection;
    private var _mouseMoveConnection:SignalConnection;

    private function supportsEvent(type:String):Bool {
        switch (type) {
            case MouseEvent.MOUSE_DOWN | MouseEvent.MOUSE_UP | MouseEvent.MOUSE_MOVE:
                return true;
        }
        return false;
    }

    private function mapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_DOWN:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    _mouseDownConnection = System.mouse.down.connect(__onMouseDown);
                }
            case MouseEvent.MOUSE_UP:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    _mouseUpConnection = System.mouse.up.connect(__onMouseUp);
                }
            case MouseEvent.MOUSE_MOVE:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    _mouseMoveConnection = System.mouse.move.connect(__onMouseMove);
                }
        }
    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_DOWN:
                _mapping.remove(type);
                if (_mouseDownConnection != null) {
                    _mouseDownConnection.dispose();
                    _mouseDownConnection = null;
                }
            case MouseEvent.MOUSE_UP:
                _mapping.remove(type);
                if (_mouseUpConnection != null) {
                    _mouseUpConnection.dispose();
                    _mouseUpConnection = null;
                }
            case MouseEvent.MOUSE_MOVE:
                _mapping.remove(type);
                if (_mouseMoveConnection != null) {
                    _mouseMoveConnection.dispose();
                    _mouseMoveConnection = null;
                }
        }
    }

    private function __onMouseDown(event:flambe.input.MouseEvent):Void {
        dispatchMouseEvent(MouseEvent.MOUSE_DOWN, event);
    }

    private function __onMouseUp(event:flambe.input.MouseEvent):Void {
        dispatchMouseEvent(MouseEvent.MOUSE_UP, event);
    }

    private function __onMouseMove(event:flambe.input.MouseEvent):Void {
        dispatchMouseEvent(MouseEvent.MOUSE_MOVE, event);
    }

    private function dispatchMouseEvent(type:String, copyFrom:flambe.input.MouseEvent):Void {
        var fn = _mapping.get(type);
        if (fn != null) {
            var mouseEvent = new MouseEvent(type);
            mouseEvent.screenX = copyFrom.viewX;
            mouseEvent.screenY = copyFrom.viewY;
            fn(mouseEvent);
        }
    }
}