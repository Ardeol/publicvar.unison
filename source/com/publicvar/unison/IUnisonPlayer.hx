package com.publicvar.unison;

/** IUnisonPlayer Interface
 *  @author  Timothy Foster
 *  @version A.02.150716
 * 
 *  An interface representing a player playing Unison.
 * ***************************************************************************/
interface IUnisonPlayer {
/**
 *  Signals the player that his turn has started on the given phase
 *  @param core The core that called this method
 *  @param phase 0 if the first phase, 1 if the second phase
 */
    public function startTurn(core:UnisonCore, phase:Int):Void;
    
/**
 *  @deprecated
 *  Indicates the move that the player wishes to make.
 * 
 *  This should make a call to UnisonCore's assertMove(move) method.
 *  Furthermore, a call to this method indicates the end of the player's turn.
 *  If UnisonCore detects an invalid move, then it will call startTurn() again.
 *  @param core The core for which to commit the move
 *  @param move The move the player wishes to make.
 *
    public function commitMove(core:UnisonCore, move:UnisonMove):Void;
 */
}