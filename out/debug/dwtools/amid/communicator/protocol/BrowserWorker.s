 ( function _BrowserWorker_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

var _ = _global_.wTools;

  _.include( 'wCopyable' );
  _.include( 'wCommunicator' );

  require( './Abstract.s' );

}

//

/**
 * @classdesc Communicator protocol for communication between main process and worker in a browser.
 * @class wCommunicatorBrowserWorker
 * @memberof module:Tools/mid/Communicator
*/

var _ = _global_.wTools;
var Parent = _.CommunicatorProtocol.Abstract;
var Self = function wCommunicatorBrowserWorker( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'browser-worker';

// --
//
// --

function init( o )
{
  var self = this;

  Parent.prototype.init.apply( self,arguments );

}

//

function _unform()
{
  var self = this;
  var com = self.communicator;

  debugger;

  // if( com.isMaster )
  // {
  //
  //   if( self.primeStreamLike )
  //   self.primeStreamLike.destroy();
  //   self._server.close( function ()
  //   {
  //     console.log( 'server unformed' );
  //     self._server.unref();
  //   });
  //
  // }
  // else
  // {
  //
  //   self.primeStreamLike.destroy();
  //
  //   if( self.bufferStreamLike )
  //   self.bufferStreamLike.destroy();
  //
  // }

}

//

function _formMaster()
{
  var self = this;
  var com = self.communicator;

  debugger;

  // if( !Net )
  // Net = require( 'net' );
  // if( !Stream )
  // Stream = require( 'stream' );
  //
  // var server = self._server = Net.createServer( function( socket )
  // {
  //   // if( com.verbosity > 1 )
  //   // logger.log( com.nameTitle,': new TCP socket',socket );
  //
  //   _.assert( !self.primeStreamLike );
  //   // self.primeStreamLike2 = socket;
  //   // self.primeStreamLike.pipe( socket );
  //   self.primeStreamLike = socket;
  //   self._formStreams();
  //
  //   self._conConnect.give( null );
  // });
  //
  // var port = com.portGet();
  // var host = com.hostGet();
  // _.assert( port,'expects port, but got',_.strType( port ) );
  //
  // try
  // {
  //
  //   server.listen( port,host );
  //
  // }
  // catch( err )
  // {
  //   if( com.verbosity )
  //   throw _.errLogOnce( err );
  //   else
  //   throw _.err( err );
  // }
  //
  // // self.primeStreamLike = new _.CommunicatorStream();
  // // self.primeStreamLike = new Stream.PassThrough();
  //
  // // self._formStreams();
  // self._formTempSend();
  // // self._formBufferSend();

}

//

function _formSlave()
{
  var self = this;
  var com = self.communicator;
  var con = new _.Consequence();

  debugger;

  // if( !Net )
  // Net = require( 'net' );
  //
  // var stream = self.primeStreamLike = new Net.Socket();
  // var port = com.portGet();
  // var host = com.hostGet();
  //
  // _.assert( port,'expects port, but got',_.strType( port ) );
  //
  // // logger.log( 'host',host );
  // // logger.log( 'port',port );
  //
  // stream.connect( port,host, function()
  // {
  //   con.give( null );
  // });
  //
  // self._formStreams();

  return con;
}

//

function _terminateReceiveBefore()
{
  var self = this;

  _.assert( arguments.length === 0 );

}

//

function _terminateReceiveAfter()
{
  var self = this;

  _.assert( arguments.length === 0 );

}

//

function _packetSendBegin( o )
{
  var self = this;
  var com = self.communicator;

  debugger;

  Parent.prototype._packetSendBegin.call( self,o );

  if( self.primeStreamLike )
  _.assert( !self.primeStreamLike.destroyed,'socket destroyed' );

  return o;
}

_packetSendBegin.defaults =
{
  channel : null,
  data : null,
}

//

/**
 * @summary Sends 'data' through specified 'channel'.
 * @param {String} channel Target channel.
 * @param {} data Data to send.
 * @function packetSend
 * @memberof module:Tools/mid/Communicator.wCommunicatorBrowserWorker#
*/

function packetSend( channel,data )
{
  var self = this;
  var o;

  debugger;

  if( arguments.length === 2 )
  o = { channel : channel, data : data }

  _.assert( o.channel !== undefined && o.channel !== null );
  _.assert( o.data !== undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( packetSend,o );

  var packet = { channel : o.channel, data : o.data };
  packet = self._packetSendBegin( packet );
  self._packetSend( packet );

  return self;
}

packetSend.defaults =
{
  channel : null,
  data : null,
}

//

/**
 * @summary Sends 'data' through specified 'subchannel'.
 * @param {String} subchannel Target channel name.
 * @param {} data Data to send.
 * @function packetSpecialSend
 * @memberof module:Tools/mid/Communicator.wCommunicatorBrowserWorker#
*/

function packetSpecialSend( subchannel,data )
{
  var self = this;
  var o;

  debugger;

  if( arguments.length === 2 )
  o = { subchannel : subchannel, data : data }

  _.assert( o.subchannel !== undefined && o.subchannel !== null );
  _.assert( o.data !== undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( packetSpecialSend,o );

  var packet = { subchannel : o.subchannel, data : o.data };
  self.packetSend( 'packetSpecial',packet );

  return self;
}

packetSpecialSend.defaults =
{
  subchannel : null,
  data : null,
}

//

/**
 * @descriptionNeeded
 * @param {Object} o Options map.
 * @param {} o.buffer Buffer to send.
 * @function bufferSend
 * @memberof module:Tools/mid/Communicator.wCommunicatorBrowserWorker#
*/

function bufferSend( o )
{
  var self = this;

  _.assert( o.data !== undefined );
  _.assert( arguments.length === 1 );
  _.routineOptions( bufferSend,o );

  debugger;

  self._bufferSend( o.data );

}

bufferSend.defaults =
{
  data : null,
}

// --
// relations
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
  primeStreamLike2 : null,
}

var Restricts =
{
  _server : [],
}

var Statics =
{
}

// --
// prototype
// --

var Proto =
{

  init : init,
  _unform : _unform,

  _formMaster : _formMaster,
  _formSlave : _formSlave,

  _terminateReceiveBefore : _terminateReceiveBefore,
  _terminateReceiveAfter : _terminateReceiveAfter,
  _packetSendBegin : _packetSendBegin,

  // relations

  /* constructor * : * Self, */
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

wTools.CommunicatorProtocol[ Self.shortName ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();