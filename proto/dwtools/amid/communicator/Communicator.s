( function _Communicator_s_() {

'use strict';

/**
 * Sketch. Strategy for two points communication. Communicator abstracts details of implementation of communication protocol and provides smooth experience though uniform API. Use the module to make your application more portable and less platform/environment dependent.
  @module Tools/mid/Communicator
*/

/**
 * @file Communicator.s.
 */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wCopyable' );
  _.include( 'wEventHandler' );

}

var Http, Net, SocketIo, Udp;

//

/**
 * @classdesc Abstracts details of implementation of communication protocol and provides smooth experience though uniform API.
 * @class wCommunicator
 * @memberof module:Tools/mid/Communicator
*/

var _ = _global_.wTools;
var Parent = null;
var Self = function wCommunicator( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Communicator';

// --
//
// --

function init( o )
{
  var self = this;

  _.workpiece.initFields( self );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

//

function finit()
{
  var self = this;
  self.unform();
  return _.Copypabe.prototype.finit.call( self );
}

//

function unform()
{
  var self = this;
  var protocolProvider = self.protocolProvider;

  if( protocolProvider )
  protocolProvider.unform();

}

//

/**
 * @summary Prepares fields of current instance.
 * @function form
 * @memberof module:Tools/mid/Communicator.wCommunicator#
*/

function form()
{
  var self = this;

  _.assert( _.boolLike( self.isMaster ) || _.boolLike( self.isSlave ) );

  /* url */

  if( self.url )
  {
    if( self.verbosity )
    logger.log( 'URL :',self.url );
    self.url = _.uri.parse( self.url );
  }

  /* provider */

  var protocol = self.protocolGet();
  if( self.protocolProvider === null )
  if( protocol && _.CommunicatorProtocol[ protocol ] )
  self.protocolProvider = new _.CommunicatorProtocol[ protocol ]
  ({
    communicator : self,
  });

  _.assert( self.protocolProvider );

  /* role */

  if( _.boolLike( self.isMaster ) )
  self.isSlave = !self.isMaster;
  else
  self.isMaster = !self.isSlave;

  /* name */

  if( !self.nameRole )
  if( self.isMaster )
  self.nameRole = 'master';
  else
  self.nameRole = 'slave';

  if( !self.nameTitle )
  self.nameTitle = self.nameRole;

  /* side specific form */

  self.protocolProvider.form();

}

//

function _formPipeMaster()
{
  var self = this;

  /* */

  self.bufferStreamLike = self.slave.process.stdio[ 3 ];
  self.bufferStreamLike.writable = true;
  self.primeStreamLike = self.slave.process;

  self._formStreams();

}

//

function _formPipeSlave()
{
  var self = this;

  /* */

  if( !Net )
  Net = require( 'net' );
  self.bufferStreamLike = new Net.Socket({ fd : 3 });
  self.primeStreamLike = self.slave.process;

  self._formStreams();

}

//

function _formUdpMaster()
{
  var self = this;

  if( !Udp )
  Udp = require( 'dgram' );

  var stream = self.primeStreamLike = Udp.createSocket( 'udp4' );

  stream.on('error', (err) => {
    console.log(`server error:\n${err.stack}`);
  });

  stream.on('message', (msg, rinfo) => {
    console.log(`server got: ${msg} from ${rinfo.address}:${rinfo.port}`);
  });

  stream.on('listening', () => {
    const address = stream.address();
    console.log(`server listening ${address.address}:${address.port}`);
  });

  if( _.strIs( self.url ) )
  self.url = _.uri.parse( self.url );

  var port = self.url ? self.url.port : self.defaultPort;

  _.assert( port,'Expects port, but got',_.strType( port ) );

  stream.bind
  ({
    address : self.host || '127.0.0.1',
    prot : port,
  });

  self._formStreams();

}

//

function _formUdpSlave()
{
  var self = this;

  // client.send( message, 41234, 'localhost', (err) => {
  //
  //   client.close();
  //
  // });

}

//

function _formSocketIoMaster()
{
  var self = this;

  if( !Http )
  require( 'http' );

  /* http server */

  if( !self.server )
  self.server = Http.createServer( function( request, response )
  {
    logger.log( 'master : http requested' );
    response.writeHead( 401, { 'Content-Type' : 'text/html' } );
    response.write( 'x' );
    response.end();
  });

  var lastPort = 1024;
  var port;
  for( var i = 0 ; i <= lastPort ; i++ )
  try
  {
    port = 13000 + i;
    self.server.listen( port );
    self.path = 'http://127.0.0.1:' + ( port );
    logger.log( 'try',self.path );
    break;
  }
  catch( err )
  {
    if( i === lastPort )
    {
      debugger;
      throw _.errLog( err );
    }
  }

  _.assert( self.server.listening );
  logger.log( 'listening',self.path );

  /* pipe */

  // self._formPipeMaster();
  // self.masterReceive( self.path,'url' );

  /* SocketIo */

  // self._masterReceive = self._masterReceiveIo;

  debugger;
  if( !SocketIo )
  SocketIo = require( 'socket.io' );
  var c = self._connection = SocketIo.listen( self.server );

  if( 0 )
  self.logConnection();

  /* */

  c.on( 'connect',_.routineJoin( self,masterConnectEnd ) );
  c.on( 'disconnect',_.routineJoin( self,masterDisconnectEnd ) );
  c.on( 'message',( packet ) => self,_packetReceive({ packet : packet }) );
  c.on( 'error',( err ) => self._errorReceive({ err : err }) );

  logger.log( '_formSocketIoMaster.end' );

  // self._connectedCon.take( null );

/*
SocketIo.on('connection', function(socket){
  fs.readFile('image.png', function(err, buf){
    // it's possible to embed binary data
    // within arbitrarily-complex objects
    socket.emit('image', { image : true, buffer : buf });
  });
});
*/

}

//

function _formNodeIpcMaster()
{
  var self = this;

  // self._masterReceive = self._masterReceiveIpc;

  //self._masterSocketCon = new _.Consequence();

  //

  function masterConnectEnd( socket )
  {
    debugger;
    _.assert( !self._connection );
    self._connection = socket;
    self.masterConnectEnd.apply( self,arguments );
  }

  function masterReceiveMessage( packet,socket )
  {
    _.assert( self._connection === socket );
    self._packetReceive({ packet : packet });
  }

  //

  Ipc.config.id = 'master';
  self.initIpcConfig();

  Ipc.serve( function()
  {

    Ipc.server.on( 'connect',_.routineJoin( self,masterConnectEnd ) );
    Ipc.server.on( 'disconnect',_.routineJoin( self,masterDisconnectEnd ) );
    Ipc.server.on( 'message',_.routineJoin( self,masterReceiveMessage ) );
    Ipc.server.on( 'error',( err ) => self._errorReceive({ err : err }) );

  });

  Ipc.server.start();

}

//

function _formSocketIoSlave()
{
  var self = this;
  var con = new _.Consequence();
  function emptyFunction() {};

  self.provisional( 'workerMessage',function( e )
  {

    debugger;
    if( e.channel !== 'url' )
    return;

    logger.log( '_formSocketIoSlave' );

    self.path = e.data;
    _.assert( _.strIs( self.path ) );

    debugger;
    var SocketIo = require( 'socket.io-client' )/*( 'http://127.0.0.1:30103' )*/;
    var c = self._connection = SocketIo.connect( self.path );

    if( 0 )
    self.logConnection();
    if( 0 )
    _.time.out( 3000,function()
    {
      self.logConnection();
    });

    self.slaveReceive = self._slaveReceiveIo;
    global.postMessage = function( msg )
    {
      self._slaveReceiveIo( msg );
    }

    global.addEventListener = function( eventKind, onEvent )
    {
      if( eventKind === 'message' )
      {
        global.onmessage = onEvent;
      }
      else if( eventKind === 'error' )
      {
        global.onerror = onEvent;
      }
      else throw 'Unexpected eventKind : ' + eventKind;
    }

    c.on( 'connect',_.routineJoin( self,self.slaveConnectEnd ) );
    c.on( 'disconnect',_.routineJoin( self,self.slaveDisconnectEnd ) );
    c.on( 'message',( packet ) => self._packetReceive({ packet : packet }) );

    // c.on( 'error',_.routineJoin( self,self.slaveReceiveError ) );
    // c.on( 'connect_error',_.routineJoin( self,self.slaveReceiveError ) );
    // c.on( 'connect_timeout',_.routineJoin( self,self.slaveReceiveError ) );

    c.on( 'error',( err ) => self._errorReceive({ err : err }) );
    c.on( 'connect_error',( err ) => self._errorReceive({ err : err }) );
    c.on( 'connect_timeout',( err ) => self._errorReceive({ err : err }) );

    global.postMessage( 'hello from _slave' );

    logger.log( '_formSocketIoSlave.end' );

    con.take( null );

    return false;
  });

  return con;
}

//

function _formNodeIpcSlave()
{
  var self = this;
  var con = new _.Consequence();
  function emptyFunction() {};

  self.slaveReceive = self._slaveReceiveIpc;
  global.postMessage = function( msg )
  {
    self._slaveReceiveIpc( msg );
  }

  global.addEventListener = function( eventKind, onEvent )
  {
    if( eventKind === 'message' )
    {
      global.onmessage = onEvent;
    }
    else if( eventKind === 'error' )
    {
      global.onerror = onEvent;
    }
    else throw 'Unexpected eventKind : ' + eventKind;
  }

  Ipc.config.id = '_slave';
  self.initIpcConfig();

  Ipc.connectTo
  (
    'master',
    function()
    {
      Ipc.of.master.on( 'connect',_.routineJoin( self,self.slaveConnectEnd ) );
      Ipc.of.master.on( 'disconnect',_.routineJoin( self,self.slaveDisconnectEnd ) );
      Ipc.of.master.on( 'message',() => self._packetReceive( packet ) );
      /*Ipc.of.master.on( 'data',_.routineJoin( self,self.slaveReceivedPacket ) );*/
      // Ipc.of.master.on( 'error',_.routineJoin( self,self.slaveReceiveError ) );
      Ipc.of.master.on( 'error',( err ) => self._errorReceive({ err : err }) );
      con.take( null );
    }
  );

  return con;
}

//

/**
 * @summary Sends 'data' through specified 'channel'.
 * @param {String} channel Target channel name.
 * @param {} data Entity to send.
 * @function packetSend
 * @memberof module:Tools/mid/Communicator.wCommunicator#
*/

function packetSend( channel,data )
{
  var self = this;
  var protocolProvider = self.protocolProvider;
  protocolProvider.packetSend.apply( protocolProvider,arguments );
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
 * @param {} data Entity to send.
 * @function packetSpecialSend
 * @memberof module:Tools/mid/Communicator.wCommunicator#
*/

function packetSpecialSend( subchannel,data )
{
  var self = this;
  var protocolProvider = self.protocolProvider;
  protocolProvider._packetSpecialSend.apply( protocolProvider,arguments );
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
 * @param {} o.buffer BufferNode to send.
 * @function bufferSend
 * @memberof module:Tools/mid/Communicator.wCommunicator#
*/

function bufferSend( o )
{
  var self = this;
  var protocolProvider = self.protocolProvider;

  if( _.bufferAnyIs( o ) )
  o = { buffer : o };

  _.assert( o.buffer !== undefined );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptions( bufferSend,o );

  protocolProvider._bufferSend( o.buffer );

}

bufferSend.defaults =
{
  buffer : null,
}

// --
//
// --

/**
 * @summary Returns communication protocol used by current instance.
 * @function protocolGet
 * @memberof module:Tools/mid/Communicator.wCommunicator#
*/

function protocolGet()
{
  var self = this;
  var result = null;

  if( self.url )
  result = self.url.protocol;

  if( !result )
  result = self.defaultProtocol;

  if( result )
  return result.toLowerCase();

  return result;
}

//

/**
 * @summary Returns target host name.
 * @function hostGet
 * @memberof module:Tools/mid/Communicator.wCommunicator#
*/

function hostGet()
{
  var self = this;
  var result = null;

  if( self.url )
  result = self.url.host;

  if( !result )
  result = self.defaultHost;

  return result;
}

//

/**
 * @summary Returns target port value.
 * @function hostGet
 * @memberof module:Tools/mid/Communicator.wCommunicator#
*/

function portGet()
{
  var self = this;
  var result = null;

  if( self.url )
  result = self.url.port;

  if( !result )
  result = self.defaultPort;

  if( result )
  result = Number( result );

  return result;
}

// --
// type
// --

var specialChannels =
{
  'terminateReceived' : 'terminateReceived',
}

// --
// relations
// --

var Composes =
{

  verbosity : 0,
  errors : [],

  url : null,
  defaultHost : '127.0.0.1',
  defaultPort : null,
  defaultProtocol : 'tcp',

  nameTitle : null,
  nameRole : null,

  isSlave : null,
  isMaster : null,

}

var Aggregates =
{
  channels : {},
}

var Associates =
{
  protocolProvider : null,
}

var Restricts =
{
}

var Statics =
{
  specialChannels : specialChannels,
}

var Events =
{
  packet : 'packet',
  packetSpecial : 'packetSpecial',
  terminateReceived : 'terminateReceived',
  buffer : 'buffer',
  message : 'message',
}

var Forbids =
{
  bufferStreamLike : 'bufferStreamLike',
  primeStreamLike : 'primeStreamLike',
  _streamDelimeter : '_streamDelimeter',
  _streamBuffer : '_streamBuffer',
  _packetSend : '_packetSend',
  _bufferSend : '_bufferSend',
}

// --
// declare
// --

var Proto =
{

  init : init,
  finit : finit,

  unform : unform,
  form : form,

  _formPipeMaster : _formPipeMaster,
  _formPipeSlave : _formPipeSlave,

  _formUdpMaster : _formUdpMaster,
  _formUdpSlave : _formUdpSlave,

  //

  _formSocketIoMaster : _formSocketIoMaster,
  _formNodeIpcMaster : _formNodeIpcMaster,

  _formSocketIoSlave : _formSocketIoSlave,
  _formNodeIpcSlave : _formNodeIpcSlave,

  //

  packetSend : packetSend,
  packetSpecialSend : packetSpecialSend,
  bufferSend : bufferSend,

  //

  protocolGet : protocolGet,
  hostGet : hostGet,
  portGet : portGet,

  // relations


  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Events : Events,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.EventHandler.mixin( Self );

_.accessor.forbid( Self.prototype,Forbids );

//

_.CommunicatorProtocol = _.CommunicatorProtocol || Object.create( null );

if( typeof module !== 'undefined' )
{

  require( './protocol/Abstract.s' );
  require( './protocol/Tcp.s' );

}

//

_global_[ Self.name ] = _[ Self.shortName ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
