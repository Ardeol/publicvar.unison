package com.publicvar.unison.ui;

import haxe.ds.Vector;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.plugin.MouseEventManager;
import flixel.util.FlxPoint;
import flixel.util.FlxVector;

import com.publicvar.unison.IUnisonPlayer;
import com.publicvar.unison.IUnisonUI;
import com.publicvar.unison.UnisonAction;
import com.publicvar.unison.UnisonCore;
import com.publicvar.unison.UnisonPiece;
import com.publicvar.unison.UnisonMove;
import com.publicvar.unison.UnisonPosition;

/** Board Class
 *  @author  Timothy Foster
 *  @version A.00.1507
 * 
 *  The Board is an IUnisonUI entity that actually displays the game's
 *  position.  Furthermore, it allows for the player to interact with the
 *  game so that moves can be sent to the core.
 *  
 *  This class is not responsible for handling any game logic.  All logic is
 *  done within UnisonCore; the core then sends commands to this object
 *  so that the correct animations can be played that accurately reflect
 *  the game's progression.
 *  **************************************************************************/
class Board extends FlxGroup implements IUnisonUI {
/**
 *  true if the player has control over the pieces.
 */
    public var controlEnabled(default, null):Bool;
    
/**
 *  true if a drag is currently in process.  Prevents double dragging and weirdness.
 */
    public var dragStarted(default, null):Bool;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new Board instance.  Note that a core must first be created, and then the UI element can be added to the core.
 *  @param core
 */
    public function new(core:UnisonCore) {
        super();
        this.core = core;
        board = new FlxSprite();
        tokens = new FlxTypedGroup<Token>();
        tokenStacks = new Vector<Token>(UnisonCore.BOARD_WIDTH * UnisonCore.BOARD_HEIGHT);
        enabledTokens = new Array<Token>();
        
        board.loadGraphic(Assets.tileboard__png);
        
        this.add(board);
        this.add(tokens);
    }
    
/*  Core Methods
 *  =========================================================================*/
/**
 *  Update's the board every frame.
 */
    override public function update():Void {
        super.update();
        if (dragStarted && FlxG.mouse.justReleased) {
            stopDrag();
        }
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Begins a new game by setting up the board's Tokens
 */
    public function newGame():Void {
        var startPosition = UnisonPosition.STARTING_POSITION;
        startPosition.parse(function(pt, f, r, c) {
            var token = new Token(new UnisonPiece(pt, f));
            placeToken(token, r, c);
            tokens.add(token);
            return true;
        });
    }

/**
 *  Enables user input for the given faction and piece type(s).
 * 
 *  To use multiple piece types, use bitwise or.  To use both factions, use Faction.BOTH.
 *  @param pt The piece types to enable input for
 *  @param f The faction to enable input for
 */
    public function enableControl(pt:PieceType, f:Faction):Void {
        if (!this.controlEnabled) {
            this.controlEnabled = true;
            for (token in tokens) {
                if (token.meta.isPieceType(pt) && token.meta.isFaction(f) && token.isOnTop()) {
                    MouseEventManager.add(token, startDragFor);
                    enabledTokens.push(token);
                }
            }
        }
        else
            throw 'ERROR in Board enableControl: Control already enabled';
    }
    
/**
 *  Removes all control from the player
 */
    public function disableControl():Void {
        while (enabledTokens.length > 0)
            MouseEventManager.remove(enabledTokens.pop());
        this.controlEnabled = false;
    }
    
/**
 *  Initiates drag sequence for a set of tokens matching the seleted token.
 *  @param t The token that was clicked on originally
 */
    public function startDragFor(t:Token):Void {
        dragStarted = true;
        activeToken = t;
        dragOrigin = FlxG.mouse.getScreenPosition();
        for (token in tokens) {
            if (token.isOnTop() && token.meta.isFaction(t.meta.faction) && token.meta.isPieceType(t.meta.pieceType)) {
                //token.removeFromStack();  // Do not use this command; it breaks the game
                token.startDrag(dragOrigin);
            }
        }
    //  Puts the dragged tokens on top
        tokens.sort(Token.byLayer);
    }
    
/**
 *  Ends the current dragging sequence so that a move can be submitted to the core.
 */
    public function stopDrag():Void {
    /*
     *  1)  Stop dragging all tokens
     *  2)  Determine the direction of displacement
     *  3)  Ask if the move is valid
     *  4a) If so, disable control and attempt to perform the move.
     *      If the move is actually invalid, the core will detect this and simply restart the current turn
     *  4b) Otherwise snap all pieces back to where they were
     *  5)  Stop the dragging
     */
        for (token in tokens)
            token.stopDrag();
        
        var dir:FlxVector = mouseDisplacement();
        var success:Bool = false;
        var move = new UnisonMove(activeToken.meta, vectorToDirection(dir));
        if (dir.length == 1) {
        //  Only cardinal directions are valid, and only cardinals have magnitude 1
        //  We pass this as a UnisonMove to UnisonCore and await its response for validity
            success = core.isValidMove(move);
        }
        
        if (success) {
            disableControl();
            core.assertMove(move);
        }
        else {
        //  Return everything back the way it was
            for (token in tokens)
                token.returnToDragStart();
        }
        
        dragStarted = false;
    }
    
/**
 *  Performs the commands given by the core.  Implementation of the IUnisonUI interface.
 *  @param actions List of actions to perform.
 */
    public function processActions(actions:Iterable<UnisonAction>):Void {
    //  removedTokens tracks all of the tokens that have been removed so far.
    //  We know that all the Remove actions will precede MoveTo, so this is a safe operation.
        var removedTokens = new Map<Int, Token>();
        for (action in actions) {
            switch(action) {
                case UnisonAction.Remove(r, c):
                //  Store the token then remove it; prevents it from having another token put on top of it before it has a chance to move
                    var tile = rcToTile(r, c);
                    removedTokens[tile] = tokenStacks[tile];
                    removeToken(r, c);
                case UnisonAction.MoveTo(r0, c0, r1, c1):
                //  Like how easy this is to do?
                    placeToken(removedTokens[rcToTile(r0, c0)], r1, c1);
                case UnisonAction.Capture(r, c):
                //  Captures always happen after a move
                    var token = tokenStacks[rcToTile(r, c)];
                    var captured = token.capture();
                //  Remove and replace to set its layer appropriately
                    removeToken(r, c);
                    placeToken(token, r, c);
                //  Remove from board, but do not destroy
                    if (captured != null)
                        captured.kill();
                    else throw 'ERROR in Board processActions: A capture was attempted at ($r, $c) but failed';
                default:
            }
        }
    }
 
/*  Private Members
 *  =========================================================================*/
    private var core:UnisonCore;
    private var board:FlxSprite;
    private var tokens:FlxTypedGroup<Token>;
    private var tokenStacks:Vector<Token>; // references to the top of each stack
    private var enabledTokens:Array<Token>;
    private var dragOrigin:FlxPoint;
    private var activeToken:Token;
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  @private
 *  Removes the token from the stack's top.  Does not capture/kill the token.
 *  @param r
 *  @param c
 *  @return The tile that was on top of the stack at (r, c)
 */
    private function removeToken(r:Int, c:Int):Token {
        var tile = rcToTile(r, c);
        var token = tokenStacks[tile];
        if(token != null)
            tokenStacks[tile] = token.removeFromStack();
        return token;
    }
 
 /**
 *  @private
 *  Places the token onto the given square and updates internal data accordingly.
 *  @param token
 *  @param r row
 *  @param c column
 */
    private function placeToken(token:Token, r:Int, c:Int):Void {
        var tile:Int = rcToTile(r, c);
        token.removeFromStack();  // needs to be removed first; if already removed, this does nothing
        token.addOnTop(tokenStacks[tile]);
        tokenStacks[tile] = token;
        token.x = Params.TILE_WIDTH * c + Params.PIECE_LAYER_OFFSET_X * (token.layer - 1);
        token.y = Params.TILE_WIDTH * r + Params.PIECE_LAYER_OFFSET_Y * (token.layer - 1);
    }
    
/**
 *  @private
 *  Calculates the displacement of the mouse after a drag sequence.
 * 
 *  @return A vector describing the direction of displacement.  Components are rounded to integers.
 */
    private function mouseDisplacement():FlxVector {
        var curPosition = FlxG.mouse.getScreenPosition();
    //  Using round() allows the calculated vector to ALWAYS point to the tile the mouse was released on.
        return new FlxVector(Math.round((curPosition.x - dragOrigin.x) / Params.TILE_WIDTH),
                             Math.round((curPosition.y - dragOrigin.y) / Params.TILE_WIDTH));
    }
    
/**
 *  @private
 *  Determines a direction given a vector.
 */
    private inline function vectorToDirection
        <T:{
            public var x(default, dynamic):Float;
            public var y(default, dynamic):Float;
        }> (v:T):Direction {
        if (v.x > 0)
            return EAST;
        else if (v.x < 0)
            return WEST;
        else if (v.y > 0)
            return SOUTH;
        else
            return NORTH;
    }
    
/**
 *  @private
 *  Converts a (r, c) tuple into the stack number
 *  @param r
 *  @param c
 *  @return A number between 1 and 64
 */
    private static inline function rcToTile(r:Int, c:Int):Int {
        return UnisonCore.BOARD_WIDTH * r + c;
    }
 
}