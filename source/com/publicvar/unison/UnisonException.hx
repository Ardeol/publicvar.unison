package com.publicvar.unison;

/** UnisonException Abstract
 *  @author  Timothy Foster
 *  @version A.00.150629
 * 
 *  Wrapper for errors that occur within the Unision classes.
 *  **************************************************************************/
abstract UnisonException(String) to String {
/**
 *  Creates a new exception.  In debug mode, more info is provided.
 *  @param className Name of the calling class.
 *  @param method Name of the method throwing the error.
 *  @param msg The message.
 */
    public inline function new(className:String, method:String, msg:String) {
    #if debug
        this = 'ERROR in $className $method: $msg';
    #else
        this = 'Unison ERROR: $msg';
    #end
    }
}