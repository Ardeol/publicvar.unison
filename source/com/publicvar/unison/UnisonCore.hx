package com.publicvar.unison;

import com.publicvar.unison.UnisonState.TurnPhase;

/** UnisonCore Class
 *  @author  Timothy Foster
 *  @version A.02.1507
 * 
 *  This is the core of the game.  UnisonCore runs all operations in a single
 *  game of Unison.  The class is designed to be connected to multiple UI
 *  clients so that some may serve as spectators.  Eventually, the plan is
 *  to turn this class into a UnisonServer and for the IUnisonUI objects to
 *  be IUnisonClient objects instead.
 *  **************************************************************************/
class UnisonCore {
    public static inline var BOARD_WIDTH  = 8;
    public static inline var BOARD_HEIGHT = 8;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new core.
 */
    public function new() {
        uis = new Array<IUnisonUI>();
    }
    
/*  Class Methods
 *  =========================================================================*/
    
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Sets the white player.
 *  @param player
 */
    public function setWhite(player:IUnisonPlayer):Void {
        playerWhite = player;
    }
    
/**
 *  Sets the black player.
 *  @param player 
 */
    public function setBlack(player:IUnisonPlayer):Void {
        playerBlack = player;
    }
    
/**
 *  Adds a client to the core.
 *  @param ui A client that may or may not assert moves.
 */
    public function addUI(ui:IUnisonUI):Void {
        uis.push(ui);
    }
    
/**
 *  Removes the UI element if possible.
 *  @param ui Reference to the client to remove
 */
    public function removeUI(ui:IUnisonUI):Void {
        uis.remove(ui);
    }
    
/**
 *  Starts a new game.
 */
    public function newGame():Void {
        state = new UnisonState();
        history = new History();
    }
    
/**
 *  Actually begins a game.  <code>newGame()</code> should be called beforehand.
 */
    public function startGame():Void {
        if (coreValid())
            playerWhite.startTurn(this, phaseToInt(WHITE_B));
        else
            throw new UnisonException("UnisonCore", "startGame", "Core is not valid.  Either players or state are null.");
    }
    
/**
 *  Tests if a move is valid and performs it if it is.
 * 
 *  A successful move will also advance the game to the next turn.
 *  @param move A move to test
 *  @return true if the move succeeded, false otherwise
 */
    public function assertMove(move:UnisonMove):Bool {
        var prevPhase = state.phase;
        var actions = state.performMove(move);
        if (state.phase != prevPhase) {
            history.push({move: move, actions: actions});
            for (ui in uis)
                ui.processActions(actions);
        }
        
        startTurn(state.phase);
            
        return state.phase != prevPhase;
    }
    
/**
 *  Returns whether or not a move is valid, but does not actually perform the move.
 *  @param move A move to test
 *  @return true if the move is valid, false otherwise
 */
    public function isValidMove(move:UnisonMove):Bool {
        return true;
    }
    
/**
 *  Returns the board to n positions before the current position and returns that position.
 *  @param n The number of moves to undo
 *  @return The position the board was in n moves ago.
 */
    public function undoMoves(n:Int):UnisonPosition {
        return UnisonPosition.STARTING_POSITION;
    }
 
/*  Private Members
 *  =========================================================================*/
    private var playerWhite:IUnisonPlayer;
    private var playerBlack:IUnisonPlayer;
    private var state:UnisonState;
    private var uis:Array<IUnisonUI>;
    private var history:History;
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  @private
 *  Determines if the core is valid for game start or not.
 */
    private inline function coreValid():Bool {
        return playerWhite != null && playerBlack != null && state != null;
    }
 
/**
 *  Determines the phase number.  This is used for IUnisonPlayer.startTurn().
 *  @param phase
 *  @return An integer representing the current phase, to be interpretted by IUnisonPlayer objects.
 */
    private static inline function phaseToInt(phase:TurnPhase):Int {
        return switch(phase) {
            case NO_TURN: -1;
            case WHITE_A: 0;
            case WHITE_B: 1;
            case BLACK_A: 0;
            case BLACK_B: 1;
            case WHITE_VICTORY: -2;
            case BLACK_VICTORY: -2;
            case DRAW: -2;
        };
    }
    
/**
 *  Starts a new turn depending on the phase.
 *  @param phase
 */
    private function startTurn(phase:TurnPhase):Void {
        if (phase == WHITE_A || phase == WHITE_B)
            playerWhite.startTurn(this, phaseToInt(phase));
        else if (phase == BLACK_A || phase == BLACK_B)
            playerBlack.startTurn(this, phaseToInt(phase));
    }
}

/**
 *  The History keeps track of the move made and all the actions associated with it.
 *  By keeping track of the actions, we can undo moves properly.
 */
private typedef History = Array<{
    var move:UnisonMove;
    var actions:Array<UnisonAction>;
}>