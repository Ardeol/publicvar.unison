package com.publicvar.unison;

import com.publicvar.unison.UnisonPiece;

/** UnisonPosition
 *  @author  Timothy Foster
 *  @version A.01.150716
 *
 ** A wrapper for a string representing a position.
 * 
 ** The format is as follows.
 *  1)  Starting with the NW corner of the board, progress left.
 *  2)  If the tile has pieces in it, record the piece codes starting from the
 *      bottom of the stack.  Then place a period (.)
 *  3)  If the tile has no pieces on it, record the number of spaces after
 *      and including the current tile that are blank as well.  Then place a
 *      period (.).  If the number was 1, do not write it.
 *  4)  The piece codes are as follows:
 *      *  Circle = c, Triangle = t, Square = s, Pentagon = p
 *      *  If the faction is White, use lowercase; uppercase otherwise
 * 
 ** Sample valid string for a 4x4 board:
 *  c..c.c..cC.t.s.3.T.C.CcT.S..
 * 
 ** A position can also be uncompressed like the below:
 *  c..c.c..cC.t.s....T.C.CcT.S..
 * ***************************************************************************/
@:forward
abstract UnisonPosition(String) from String to String {
    public static inline var DELIM = ".";
    public static inline var REMOVE = "-";
    public static inline var STARTING_POSITION:UnisonPosition = "T.C.S.C.P.C.T.C.C.T.C.S.C.S.C.T.32.c.t.c.s.c.s.c.t.t.c.s.c.p.c.t.c.";
    
/**
 *  Creates a new position object.
 *  @param s The position to store.
 */
    public inline function new(s:String) {
        this = s;
    }
    
/**
 *  @TODO implement position validity
 *  @return true if the position is valid
 */
    public function isValid():Bool {
        return true;
    }
    
/**
 *  @deprecated
 *  Compares two positions and returns the difference as a position
 *  @param other
 *
    public function differences(other:UnisonPosition):UnisonPosition {
        var thisArr = decompress().split(DELIM);
        var otherArr = other.decompress().split(DELIM);
        if (thisArr.length != otherArr.length)
            throw "ERROR in UnisonPosition differences: Dimension mismatch";
        var difference = new StringBuf();
        for (i in 0...(thisArr.length - 1)) {
            var thisStack = thisArr[i];
            var otherStack = otherArr[i];
            var len = thisStack < otherStack ? thisStack.length : otherStack.length;
        //  Find first nonmatching letter
            var j:Int = 0;
            while (j < len && thisStack.charAt(j) == otherStack.charAt(j))
                ++j;
        //  Push minus signs
            var numMinuses:Int = cast Math.max((len - j), thisStack.length - otherStack.length);
            for (k in 0...numMinuses)
                difference.add(REMOVE);
        //  Push missing tokens; note this works even if thisStack > otherStack
            difference.add(otherStack.substring(j));
            difference.add(DELIM);
        }
        
        return difference.toString();
    }
 */
    
/**
 *  Returns a compressed version of the position; does not modify current position
 *  @return new position that is compressed
 */
    public function compress():UnisonPosition {
        var e = ~/\.\.\.+/g;
        return new UnisonPosition(e.map(this, function(r) {
            var match = r.matched(0);
            var len = match.length - 1;
            return '$DELIM$len$DELIM';
        }));
    }
    
/**
 *  Returns a decompressed version of the position; does not modify current position
 *  @return new position that is decompressed
 */
    public function decompress():UnisonPosition {
        var e = ~/[1-6]?[0-9]/g;
        return new UnisonPosition(e.map(this, function(r) {
            var n = Std.parseInt(r.matched(0)) - 1;
            var s = new StringBuf();
            for (i in 0...n)
                s.add(DELIM);
            return s.toString();
        }));
    }
    
/**
 *  Applies a function given a position that may be used for setting up boards or processing
 *  @param f A function that takes the piece type, faction, row and column of the piece.  It should return true if the parse succeeded.
 */
    public function parse(f:PieceType->Faction->Int->Int->Bool):Void {
        var elements = this.split(DELIM);
        var tileNumber = 0;
        for (e in elements) {
            if (e == "")
                ++tileNumber;
            else if (Std.parseInt(e) == null) {
            //  It must be a stack of pieces
                for (piece in e.split("")) {
                    var faction:Faction;
                    if (piece == piece.toLowerCase())
                        faction = Faction.WHITE;
                    else
                        faction = Faction.BLACK;
                    var row = Std.int(tileNumber / UnisonCore.BOARD_HEIGHT);
                    var col = tileNumber % UnisonCore.BOARD_HEIGHT;
                    var wasValid = switch(piece.toLowerCase()) {
                        case "c": f(PieceType.CIRCLE, faction, row, col);
                        case "t": f(PieceType.TRIANGLE, faction, row, col);
                        case "s": f(PieceType.SQUARE, faction, row, col);
                        case "p": f(PieceType.PENTAGON, faction, row, col);
                        default: false;
                    }
                    if (!wasValid)
                        throw new UnisonException("UnisonPosition", "parse", 'The piece for ($row, $col) could not be parsed.');
                }
                
                ++tileNumber;
            }
            else {
            //  It is a number
                tileNumber += Std.parseInt(e);
            }
        }
    }
}