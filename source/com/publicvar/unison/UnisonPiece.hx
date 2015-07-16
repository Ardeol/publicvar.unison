package com.publicvar.unison;
import com.publicvar.unison.UnisonPiece.Faction;

/** UnisonPiece Abstract
 *  @author  Timothy Foster
 *  @version A.00.150716
 * 
 *  Encodes all the information about a piece in the game.  A piece has two
 *  pertinent kinds of information: its type (circle, square, etc) and 
 *  faction.
 *  
 *  The abstract stores this as an Int.  This allows for things like:
 *  @usage enableControl(PieceType.ALL & ~PieceType.CIRCLE)
 *  **************************************************************************/
abstract UnisonPiece(Int) {
/**
 *  Creates a new piece.
 */
    public inline function new(pt:PieceType, f:Faction) {
        this = pt | f;
    }
    
    public var pieceType(get, never):PieceType;
    public var faction(get, never):Faction;
    
/**
 *  Determines if a piece's type is compatible with the argument.
 *  
 *  This is not strict equality.  For example, CIRCLE.isPieceType(ALL) will return true because
 *  a piece that is a Circle is indeed one in the set of All piece types.
 * 
 *  To test strict equality, use piece.pieceType == PieceType.CIRCLE.
 *  @param pt
 */
    public inline function isPieceType(pt:PieceType):Bool {
        return cast (pieceType & pt);
    }
    
/**
 *  Determines if a piece's faction is compatible with the argument.
 *  
 *  This is not strict equality.  For example, WHITE.isPieceType(BOTH) will return true because
 *  a piece that is WHITE is indeed one of the factions in BOTH.
 * 
 *  To test strict equality, use piece.pieceType == PieceType.WHITE.
 *  @param f
 */
    public inline function isFaction(f:Faction):Bool {
        return cast (faction & f);
    }
    
/**
 *  Returns the string representation of the piece.  Used in UnisonMove encoding.
 * 
 *  Piece type determines the letter, and faction determines capitalization.
 */
    public inline function toString():String {
        var s:String = switch(pieceType) {
            case PieceType.NONE: "";
            case PieceType.CIRCLE: "c";
            case PieceType.TRIANGLE: "t";
            case PieceType.SQUARE: "s";
            case PieceType.PENTAGON: "p";
            case PieceType.ALL: "a";
        };
        if (isFaction(Faction.BLACK))
            return s.toUpperCase();
        return s;
    }
    
/**
 *  From the string, determines the piece's type and faction.
 * @param s Must be a string of length 1.
 */
    public static function fromString(s:String):UnisonPiece {
        var c = s.charAt(0);
        var pt = switch(c.toLowerCase()) {
            case "c": PieceType.CIRCLE;
            case "t": PieceType.TRIANGLE;
            case "s": PieceType.SQUARE;
            case "p": PieceType.PENTAGON;
            case "a": PieceType.ALL;
            default: PieceType.NONE;
        };
        var f:Faction;
        if (c.toLowerCase() == c)
            f = Faction.WHITE;
        else
            f = Faction.BLACK;
        return new UnisonPiece(pt, f);
    }
    
    private inline function get_pieceType():PieceType {
        return this & PieceType.ALL;
    }
    
    private inline function get_faction():Faction {
        return this & Faction.ALL;
    }
}

@:enum
abstract PieceType(Int) from Int to Int {
    var NONE =     0x00;
    var CIRCLE =   0x01;
    var TRIANGLE = 0x02;
    var SQUARE =   0x04;
    var PENTAGON = 0x08;
    var ALL =      0xFF;
}

@:enum
abstract Faction(Int) from Int to Int {
    var NONE  = 0x00 << 8;
    var WHITE = 0x01 << 8;
    var BLACK = 0x02 << 8;
    var ALL   = 0xFF << 8;
}