package com.publicvar.unison;

/** UnisonMove Abstract
 *  @author  Timothy Foster
 *  @version A.00.150716
 * 
 *  Encodes a move to be made.  A move is of the form (piecetype)(direction),
 *  where each member is a single character.  For example, CS means move all
 *  black pieces in the south direction.  The move pE means move the white
 *  pentagon east.
 * 
 *  An example Unison game may have the following kind of move history:
 *  1. cN CS TS  2. cW tN CS TS  3. and so on
 * 
 *  Compressed, this could be cNCSTScWtNCSTS...
 *  **************************************************************************/
abstract UnisonMove(String) to String {

/*  Constructor
 *  =========================================================================*/
/**
 *  Generates a new Move object from piece information and direction
 *  @param piece
 *  @param dir
 */
    public inline function new(piece:UnisonPiece, dir:Direction) {
        var d = switch(dir) {
            case NORTH: "N";
            case SOUTH: "S";
            case EAST:  "E";
            case WEST:  "W";
        };
        this = piece.toString() + d;
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Get piece information from the String
 */
    public inline function piece():UnisonPiece {
        return UnisonPiece.fromString(this.charAt(0));
    }
    
/**
 *  Returns the direction data given the move string
 */
    public inline function direction():Direction {
        return switch(this.charAt(1)) {
            case "N": NORTH;
            case "S": SOUTH;
            case "E": EAST;
            case "W": WEST;
            default: EAST;
        };
    }
    
/**
 *  Determines whether the move string is valid, NOT if the move itself is valud.
 */
    public inline function valid():Bool {
        return (this.length == 2) &&
               (this.charAt(0).toLowerCase() == "c" || this.charAt(0).toLowerCase() == "t" || this.charAt(0).toLowerCase() == "s" || this.charAt(0).toLowerCase() == "p") &&
               (this.charAt(1) == "N" || this.charAt(1) == "S" || this.charAt(1) == "E" || this.charAt(1) == "W");
    }
}

enum Direction {
    NORTH;
    SOUTH;
    EAST;
    WEST;
}