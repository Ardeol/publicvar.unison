package com.publicvar.unison;

/** IUnisonUI Interface
 *  @author  Timothy Foster
 *  @version A.00.150716
 *
 *  Used by objects that actually display graphical data about a Unison game
 *  to the player(s).
 *  **************************************************************************/
interface IUnisonUI {
/**
 *  Causes the UI element to perform a list of commands determined by a UnisonCore.
 *  
 *  UnisonCore calls this method for every UI element attached to it.  This structure
 *  allows us to decouple game logic and UI so that only the core needs to know
 *  how to process a move and determine the next position.
 *  @param actions A list of actions to be performed.
 */
    public function processActions(actions:Iterable<UnisonAction>):Void;
}