package com.publicvar.unison.ui;

import com.publicvar.unison.IUnisonPlayer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.plugin.MouseEventManager;

import com.publicvar.unison.UnisonCore;
import com.publicvar.unison.UnisonPiece;

/** PlayState Class
 *  @author  Timothy Foster
 *  @version A.00.1507
 *
 *  This runs the actual Unison game.
 * 
 *  @TODO Abstractify initialization items
 *  **************************************************************************/
class PlayState extends FlxState {
 
/*  Core Methods
 *  =========================================================================*/
    override public function create():Void {
        super.create();
        MouseEventManager.init();
        core = new UnisonCore();
        
        board = new Board(core);
        
        core.addUI(board);
        
        this.add(board);
    
        newGame();
    }
    
    override public function destroy():Void {
        super.destroy();
    }
    
    override public function update():Void {
        super.update();
    }
    
/*  Public Methods
 *  =========================================================================*/
    
 
/*  Private Members
 *  =========================================================================*/
    private var core:UnisonCore;
    private var board:Board;
 
/*  Private Methods
 *  =========================================================================*/
    private function newGame():Void {
        core.setWhite(new Player(board, Faction.WHITE));
        core.setBlack(new Player(board, Faction.BLACK));
        board.newGame();
        core.newGame();
        core.startGame();
    }
}