package com.publicvar.unison;

/** UnisonAction Class
 *  @author  Timothy Foster
 *  @version A.00.1507
 *
 *  Represents the various actions possible on a Unison board.  Implementation
 *  of these actions are defined by the IUnisonUI they are sent to.
 *  **************************************************************************/
enum UnisonAction {
/**
 *  Pick up a token from a stack.  Needed for simultaneous action to be possible.
 */
    Remove(r:Int, c:Int);
    
/**
 *  Moves a token from one tile to another.
 */
    MoveTo(r0:Int, c0:Int, r1:Int, c1:Int);
    
/**
 *  Perform a capture on the selected tile.
 */
    Capture(r:Int, c:Int);
    
/**
 *  The zero for this set; should not be needed.
 */
    None;
}