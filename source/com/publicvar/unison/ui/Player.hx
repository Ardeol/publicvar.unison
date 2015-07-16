package com.publicvar.unison.ui;

import com.publicvar.unison.UnisonCore;
import com.publicvar.unison.UnisonPiece;
import com.publicvar.unison.IUnisonPlayer;

/** Player Class
 *  @author  Timothy Foster
 *  @version A.00.1507
 *
 *  Represents a human player.  All the player needs to do is enable control
 *  of the board.  The board then handles all IO logic.
 *  **************************************************************************/
class Player implements IUnisonPlayer {
    public var faction(default, null):Faction;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new Player instance.  It must be created with the board.
 *  @param board
 *  @param faction Should be WHITE or BLACK, not both or none.
 */
    public function new(board:Board, faction:Faction) {
        this.board = board;
        this.faction = faction;
    }
 
/*  Interface Implementation
 *  =========================================================================*/
/**
 *  @TODO
 *  Signals the player that his turn has started on the given phase
 *  @param core The core that called this method
 *  @param phase 0 if the first phase, 1 if the second phase
 */
    public function startTurn(core:UnisonCore, phase:Int):Void {
    //  Determine the available piecetypes from core, then enable control
        board.enableControl(PieceType.ALL, faction);
    }
    
/*  Private Members
 *  =========================================================================*/
    private var board:Board;
 
}