( function _BrowserWorker_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../../wtools/Tools.s' );

  _.include( 'wCopyable' );
  _.include( 'wCommunicator' );

  require( './Abstract.s' );

}

//

const _ = _global_.wTools;
const Parent = _.CommunicatorProtocol.Abstract;
const Self = wCommunicatorBrowserWorker;
function wCommunicatorBrowserWorker( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'browser-worker';

// --
//
// --

function init( o )
{
  var self = this;

  Parent.prototype.init.apply( self, arguments );

}

//

function _unform()
{
  var self = this;
  var com = self.communicator;


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


  // if( !Net )
  // Net = require( 'net' );
  // if( !Stream )
  // Stream = require( 'stream' );
  //
  // var server = self._server = Net.createServer( function( socket )
  // {
  //   // if( com.verbosity > 1 )
  //   // logger.log( com.nameTitle, ': new TCP socket', socket );
  //
  //   _.assert( !self.primeStreamLike );
  //   // self.primeStreamLike2 = socket;
  //   // self.primeStreamLike.pipe( socket );
  //   self.primeStreamLike = socket;
  //   self._formStreams();
  //
  //   self._conConnect.take( null );
  // });
  //
  // var port = com.portGet();
  // var host = com.hostGet();
  // _.assert( port, 'Expects port, but got', _.entity.strType( port ) );
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


  // if( !Net )
  // Net = require( 'net' );
  //
  // var stream = self.primeStreamLike = new Net.Socket();
  // var port = com.portGet();
  // var host = com.hostGet();
  //
  // _.assert( port, 'Expects port, but got', _.entity.strType( port ) );
  //
  // // logger.log( 'host',host );
  // // logger.log( 'port',port );
  //
  // stream.connect( port,host, function()
  // {
  //   con.take( null );
  // });
  //
  // self._formStreams();

  return con;
}

//

function _terminateReceiveBefore()
{
  var self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

}

//

function _terminateReceiveAfter()
{
  var self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

}

//

function _packetSendBegin( o )
{
  var self = this;
  var com = self.communicator;


  Parent.prototype._packetSendBegin.call( self, o );

  if( self.primeStreamLike )
  _.assert( !self.primeStreamLike.destroyed, 'socket destroyed' );

  return o;
}

_packetSendBegin.defaults =
{
  channel : null,
  data : null,
}

//

function packetSend( channel, data )
{
  var self = this;
  var o;


  if( arguments.length === 2 )
  o = { channel, data }

  _.assert( o.channel !== undefined && o.channel !== null );
  _.assert( o.data !== undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( packetSend, o );

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

function packetSpecialSend( subchannel, data )
{
  var self = this;
  var o;


  if( arguments.length === 2 )
  o = { subchannel, data }

  _.assert( o.subchannel !== undefined && o.subchannel !== null );
  _.assert( o.data !== undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( packetSpecialSend, o );

  var packet = { subchannel : o.subchannel, data : o.data };
  self.packetSend( 'packetSpecial', packet );

  return self;
}

packetSpecialSend.defaults =
{
  subchannel : null,
  data : null,
}

//

function bufferSend( o )
{
  var self = this;

  _.assert( o.data !== undefined );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptions( bufferSend, o );

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
// declare
// --

const Proto =
{

  init,
  _unform,

  _formMaster,
  _formSlave,

  _terminateReceiveBefore,
  _terminateReceiveAfter,
  _packetSendBegin,

  // relations


  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,

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
