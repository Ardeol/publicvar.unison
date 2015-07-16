package com.publicvar.unison.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxSort;

import com.publicvar.unison.UnisonPiece;

/** Token Class
 *  @author  Timothy Foster
 *  @version A.00.1507
 *
 *  Represents a single piece in the game and displays the piece as well.
 * 
 *  Piece stacks are kepted as doubly linked lists.  Each piece knows who is
 *  below and on top of it.  Using the appropriate remove and add methods,
 *  the integrity of the linked list will always be preserved.
 *  **************************************************************************/
class Token extends FlxSprite {
/**
 *  Information about the piece itself and not the UI element.
 */
    public var meta(default, null):UnisonPiece;
    
/**
 *  Where the token is in the stack.  Used by Flixel to determine rendering order.
 */
    public var layer(default, null):Int;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new piece token.
 *  @param pieceData What the piece represents.  This is required, otherwise the piece cannot be drawn.
 */
    public function new(pieceData:UnisonPiece) {
        super();
        
        meta = pieceData;
        
        this.loadGraphic(Assets.pieces__png, true, 50, 50);
        this.animation.add(ANIMATION, [animationFrame()], 0, false);
        this.animation.play(ANIMATION);
        
        dragInfo = {
            enabled: false,
            layer: 0,
            origin: null,
            mouseOrigin: null
        };
    }
    
/*  Class Methods
 *  =========================================================================*/
/**
 *  Use with FlxGroup.sort() to place tokens in display order by their layer.
 * 
 *  This ensures that tokens are always stacked correctly.
 *  @param order
 *  @param a
 *  @param b
 */
    public static inline function byLayer(order:Int, a:Token, b:Token):Int {
        return FlxSort.byValues(order, a.layer, b.layer);
    }
 
/*  Core Methods
 *  =========================================================================*/
/**
 *  Destroys the object.  Use kill() instead to just remove it from one game.
 */
    override public function destroy():Void {
        above = null;
        below = null;
        
        super.destroy();
    }
    
/**
 *  Updates the token.  Used primarily for determining its position during a drag sequence.
 */
    override public function update():Void {
        super.update();
        
        if (dragInfo.enabled) {
        //  Map mouse's change in position to token's change in position
            var dx = FlxG.mouse.screenX - dragInfo.mouseOrigin.x;
            var dy = FlxG.mouse.screenY - dragInfo.mouseOrigin.y;
            this.x = dragInfo.origin.x + dx;
            this.y = dragInfo.origin.y + dy;
        }
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Properly removes the token from the stack it is currently in.
 *  @return The token that was below this token, if any.
 */
    public function removeFromStack():Token {
    //  The stack is a linked list
        this.layer = Params.TOP_LAYER;
        var wasBelow:Token = null;
        
        if (this.below != null) {
            wasBelow = this.below;
            this.below.above = this.above;
        }
        if(this.above != null)
            this.above.below = this.below;
        
        var t = this.above;
        while (t != null) {
        //  This loop updates all the layers so they are correct
            --t.layer;
            t = t.above;
        }
        
        this.above = null;
        this.below = null;
        
        return wasBelow;
    }
    
/**
 *  This token captures the token below, removing it from the stack and returning the captured piece.
 *  @return The token that was removed and captured, null if not applicable
 */
    public function capture():Token {
        if (this.below != null) {
            var tmp = this.below;
            this.below.removeFromStack();
            return tmp;
        }
        else 
            return null;
    }
    
/**
 *  Adds the token to the top of another token.
 *  @param t The token to add to the top of
 */
    public function addOnTop(t:Token):Void {
    //  Can be generalized if need be
        this.below = t;
        if (t != null) {
            t.above = this;
            this.layer = t.layer + 1;
        }
        else
            this.layer = Params.BOT_LAYER;
    }
    
/**
 *  Returns true if the token is considered on top of its stack.
 *  @return true if on top of its stack, false otherwise
 */
    public function isOnTop():Bool {
        return this.above == null;
    }
    
/**
 *  Allows the token to start following the mouse from its origin.
 *  @param mouseOrigin The FlxPoint of the mouse when the drag started.
 */
    public function startDrag(mouseOrigin:FlxPoint):Void {
        dragInfo.enabled = true;
        dragInfo.layer = layer;
        dragInfo.origin = new FlxPoint(x, y);
        dragInfo.mouseOrigin = mouseOrigin;
        
        layer = Params.TOP_LAYER;
    }
    
/**
 *  Stops the drag on the current token.  If the token was not being dragged,
 *  then we set its start point as well just in case returnToDragStart() is
 *  called.
 */
    public function stopDrag():Void {
        if (!dragInfo.enabled) {
            dragInfo.origin = new FlxPoint(x, y);
            dragInfo.layer = layer;
        }
        else
            dragInfo.enabled = false;
    }
    
/**
 *  Snaps the piece back to where the drag action started.
 */
    public function returnToDragStart():Void {
        this.x = dragInfo.origin.x;
        this.y = dragInfo.origin.y;
        layer = dragInfo.layer;
    }
 
/*  Private Members
 *  =========================================================================*/
    private static inline var ANIMATION = "animation";
    private var below:Token;
    private var above:Token;
    
    private var dragInfo:DragInfo;
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  Finds the correct animation frame from the piece spritesheet.
 *  @return The frame number
 */
    private inline function animationFrame():Int {
    //  Derives from meta
        var pt = switch(meta.pieceType) {
            case PieceType.CIRCLE: 0;
            case PieceType.TRIANGLE: 1;
            case PieceType.SQUARE: 2;
            case PieceType.PENTAGON: 3;
            default: 0;
        };
        var f = switch(meta.faction) {
            case Faction.WHITE: 0;
            case Faction.BLACK: 1;
            default: 0;
        }
        return pt + 4 * f;
    }
}

private typedef DragInfo = {
    public var enabled:Bool;
    public var layer:Int;
    public var origin:FlxPoint;
    public var mouseOrigin:FlxPoint;
}