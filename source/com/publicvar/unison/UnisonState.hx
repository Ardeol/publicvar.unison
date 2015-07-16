package com.publicvar.unison;

/** UnisonState Class
 *  @author  Timothy Foster
 *  @version A.02.150716
 * 
 *  Stores the state of a game of Unison.  When given a move, this object
 *  changes its state to accurately reflect the game's progress.
 * 
 *  One can only interact with this object by providing a move to execute
 *  or obtaining the position as a string.  Otherwise, how a game is stored
 *  is the business of this class and this class only.
 * 
 *  Clients never interact with a UnisonState object.  Clients deal with the
 *  interface of UnisonCore instead.
 *  **************************************************************************/
class UnisonState {
/**
 *  The current phase of the game.
 */
    public var phase(default, null):TurnPhase;

/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new state object
 */
    public function new() {
    //    initBoard();
        newGame();
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  @deprecated Instead, starting a new game should just create a new state object and discard this one.
 *  Begins a new game.
 */
    public function newGame():Void {
        initBoard();
        initPhase();
        UnisonPosition.STARTING_POSITION.parse(function(pt, f, r, c) {
            var stack = board.get(TILE(r, c));
            stack.push(new Piece(pt, f));
            return true;
        });
    }
    
/**
 *  Performs the given move and returns an array of actions that took place.
 *  @param move The move to perform
 */
    public function performMove(move:UnisonMove):Array<UnisonAction> {
        var actions = new Array<UnisonAction>();
        if (move.valid()) {
            advance(move.piece().pieceType, currentFaction, move.direction(), actions);
            if (actions.length > 0)
            //  Only advance if actions took place
                advanceTurn();
        }
        return actions;
    }
    
/**
 *  Converts the board state into a position string
 *  @param compressed If true, the string is compressed
 */
    public function position(compressed:Bool = true):UnisonPosition {
        var s = new StringBuf();
        for (tile in board.keys()) {
            var stack = new StringBuf();
            for (piece in board.get(tile))
                stack.add(piece.toString());
            s.add(stack.toString());
            s.add(UnisonPosition.DELIM);
        }
        if (compressed)
            return new UnisonPosition(s.toString()).compress();
        return s.toString();
    }
    
/**
 *  @DEBUG
 */
    public function disp():Void {
        for (r in 0...UnisonCore.BOARD_HEIGHT) {
            var row = "";
            for (c in 0...UnisonCore.BOARD_WIDTH) {
                var stack = board.get(TILE(r, c));
                for (p in stack) {
                    var pieceStr:String;
                    switch(p.pieceType) {
                        case PieceType.NONE: pieceStr = "n";
                        case PieceType.CIRCLE: pieceStr = "c";
                        case PieceType.TRIANGLE: pieceStr = "t";
                        case PieceType.SQUARE: pieceStr = "s";
                        case PieceType.PENTAGON: pieceStr = "p";
                        case PieceType.ALL: pieceStr = "a";
                    }
                    if (p.isFaction(Faction.BLACK))
                        pieceStr = pieceStr.toUpperCase();
                        row += pieceStr;
                }
                
                row += " \t";
            }
            trace(row);
        }
    }
 
/*  Private Members
 *  =========================================================================*/
    private var board:GameBoard;
    private var currentFaction:Faction;
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  @private
 *  A GameBoard always starts off with each square filled with NONE piecetypes in the NONE faction
 */
    private function initBoard():Void {
        board = new GameBoard();
        for (r in 0...UnisonCore.BOARD_HEIGHT) {
            for (c in 0...UnisonCore.BOARD_WIDTH) {
                var pieceStack = new Array<Piece>();
                pieceStack.push(new Piece(PieceType.NONE, Faction.NONE));
                board.set(TILE(r, c), pieceStack);
            }
        }
    }
    
/**
 *  @private
 *  White only starts off with one move, not 2
 */
    private function initPhase():Void {
        phase = WHITE_B;
        currentFaction = Faction.WHITE;
    }
    
/**
 *  @private
 *  Returns an array of all tiles that contain the given piece type/faction on top
 *  @param pt Piece Type to check
 *  @param f Faction to check
 *  @return Array of Tiles corresponding to moveable pieces.  If empty, the move submitted must be invalid.
 */
    private function tilesForTopPieces(pt:PieceType, f:Faction):Array<Tile> {
        var tiles = new Array<Tile>();
        for (tile in board.keys()) {
            var stack = board.get(tile);
            var topPiece = stack[stack.length - 1];
            if (topPiece.isPieceType(pt) && topPiece.isFaction(f))
                tiles.push(tile);
        }
        
        return tiles;
    }
    
/**
 *  @private
 *  Advances the game given the piece that moves and the direction.
 *  
 *  This one method will execute all of the other methods needed to determine the board's state
 *  after the move is executed.
 * 
 *  In addition, this method will store a list of executable actions into the actions array provided.
 *  That array can then be forwarded to IUnisonUI objects.
 *  @param pt The type of piece moved
 *  @param f The faction of the moved piece
 *  @param dir The direction of movement
 *  @param actions An empty array that actions are stored into as they occur
 */
    private function advance(pt:PieceType, f:Faction, dir:Direction, actions:Array<UnisonAction>):Void {
    /*
     *  1)  Obtain all of the tiles which contain a piece of the given type/faction on top.
     *  2)  Store all of those top pieces.
     *  3)  For each piece:
     *      1)  Get the destination tile based on dir
     *      2)  Put the piece onto that tile
     */
        var tiles = tilesForTopPieces(pt, f);
        var topPieces = new Array<Piece>();
        
        for (tile in tiles) {
        //  Pop all stacks first to make the action simultaneous
            topPieces.push(board.get(tile).pop());
            actions.push(UnisonAction.Remove(tile.getParameters()[0], tile.getParameters()[1]));
        }
        
        var curPiece = 0;
        for (tile in tiles) {
            var p = topPieces[curPiece++];
            var newTile = switch(dir) {
                case NORTH: north(tile);
                case EAST:  east(tile);
                case SOUTH: south(tile);
                case WEST:  west(tile);
            }
            
            switch(newTile) {
                case NONE: board.get(tile).push(p);
                case ALL: board.get(tile).push(p);
                case NBOUND:
                    if (p.isFaction(Faction.WHITE))
                        setWin(Faction.WHITE);
                    else
                        board.get(tile).push(p);
                case SBOUND:
                    if (p.isFaction(Faction.BLACK)) 
                        setWin(Faction.BLACK);
                    else
                        board.get(tile).push(p);
                case TILE(r, c):
                    var oldTileParams = tile.getParameters();
                    actions.push(UnisonAction.MoveTo(oldTileParams[0], oldTileParams[1], r, c));
                    performCaptures(newTile, p, actions);
                    board.get(newTile).push(p);
            }
        }
    }
    
/**
 *  @private
 *  Executes captures when a piece lands on a tile with other pieces on it
 *  @param tile
 *  @param piece
 *  @return Number of pieces captured
 */
    private function performCaptures(tile:Tile, piece:Piece, actions:Array<UnisonAction>):Int {
    //  Precondition: tile is valid
        var pieceStack = board.get(tile);
        var origStackSize = pieceStack.length;
        if (pieceStack.length == 0)
            return 0;
        var topPiece = pieceStack.pop();
        while (pieceStack.length > 0 &&
               !topPiece.isPieceType(PieceType.NONE) &&
               !piece.isFaction(topPiece.faction) &&
               piece.pieceType - topPiece.pieceType > 0) {
            topPiece = pieceStack.pop();
            actions.push(UnisonAction.Capture(tile.getParameters()[0], tile.getParameters()[1]));
        }
        pieceStack.push(topPiece);
        
        return origStackSize - pieceStack.length;
    }
    
/**
 *  Moves the game forward by one phase.
 */
    private function advanceTurn():Void {
        switch(phase) {
            case WHITE_A: phase = WHITE_B;
            case WHITE_B: phase = BLACK_A; currentFaction = Faction.BLACK;
            case BLACK_A: phase = BLACK_B;
            case BLACK_B: phase = WHITE_A; currentFaction = Faction.WHITE;
            default:
        }
    }
    
/**
 *  @private
 *  If someone won, call this function to set the phase accordingly.
 *  @param f Faction of the winner.  In case of a draw, pass Faction.NONE to this method.
 */
    private function setWin(f:Faction):Void {
        switch(f) {
            case Faction.WHITE: phase = WHITE_VICTORY;
            case Faction.BLACK: phase = BLACK_VICTORY;
            case Faction.NONE: phase = DRAW;
            case Faction.ALL: phase = DRAW;
        }
    }
    
/**
 *  @private
 *  Retrieves the tile north of the given tile
 *  @param t 
 */
    private function north(t:Tile):Tile {
        switch(t) {
            case NONE: return NONE;
            case ALL:  return NONE;
            case TILE(r, c):
                if (r == 0)  // at the top of board
                    return NBOUND;
                else
                    return TILE(r - 1, c);
            case _: return t;
        }
    }
    
/**
 *  @private
 *  Retrieves the tile south of the given tile
 *  @param t 
 */
    private function south(t:Tile):Tile {
        switch(t) {
            case NONE: return NONE;
            case ALL:  return NONE;
            case TILE(r, c):
                if (r == UnisonCore.BOARD_HEIGHT - 1)  // at the bottom of board
                    return SBOUND;
                else
                    return TILE(r + 1, c);
            case _: return t;
        }
    }
    
/**
 *  @private
 *  Retrieves the tile east of the given tile
 *  @param t 
 */
    private function east(t:Tile):Tile {
        switch(t) {
            case NONE: return NONE;
            case ALL:  return NONE;
            case TILE(r, c):
                return TILE(r, (c + 1) % UnisonCore.BOARD_WIDTH);
            case _: return t;
        }
    }
    
/**
 *  @private
 *  Retrieves the tile west of the given tile
 *  @param t 
 */
    private function west(t:Tile):Tile {
        switch(t) {
            case NONE: return NONE;
            case ALL:  return NONE;
            case TILE(r, c):
                return TILE(r, (c - 1) + ((c == 0) ? UnisonCore.BOARD_WIDTH : 0));
            case _: return t;
        }
    }
}

/*  Game Board
 *  =========================================================================*/
private typedef GameBoard = Map<Tile, Array<Piece>>;

private enum Tile {
    NONE;
    ALL;
    NBOUND;
    SBOUND;
    TILE(row:Int, column:Int);
}

/*  Piece Representation
 *  =========================================================================*/
private typedef Piece = UnisonPiece;
private typedef PieceType = UnisonPiece.PieceType;
private typedef Faction = UnisonPiece.Faction;

private typedef Direction = UnisonMove.Direction;

/*  Turn Info
 *  =========================================================================*/
enum TurnPhase {
    NO_TURN;
    WHITE_A;
    WHITE_B;
    BLACK_A;
    BLACK_B;
    WHITE_VICTORY;
    BLACK_VICTORY;
    DRAW;
}