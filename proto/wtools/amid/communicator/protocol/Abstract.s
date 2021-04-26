( function _Abstract_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../../node_modules/Tools' );

  _.include( 'wConsequence' );
  _.include( 'wCopyable' );
  // _.include( 'wCommunicator' );
  // _.include( 'wBaseEncoder' );

}

var Http, Net, SocketIo, Udp;

//

const _ = _global_.wTools;
const Parent = null;
const Self = wCommunicatorProtocolAbstract;
function wCommunicatorProtocolAbstract( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Abstract';

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

function unform()
{
  var self = this;

  self._unform();

}

//

function _unform()
{
  var self = this;

  self.primeStreamLike.destroy();

  if( self.bufferStreamLike )
  self.bufferStreamLike.destroy();

}

//

function form()
{
  var self = this;
  var com = self.communicator;

  _.assert( _.boolLike( com.isMaster ) || _.boolLike( com.isSlave ) );

  if( _.strIs( self._streamDelimeter ) )
  {
    self._streamDelimeterString = self._streamDelimeter;
    self._streamDelimeterBuffer = _.bufferBytesGet( self._streamDelimeter );
  }
  else
  {
    self._streamDelimeterString = _.bufferToStr( self._streamDelimeter );
    self._streamDelimeterBuffer = self._streamDelimeter;
  }

  if( com.isMaster )
  self._formMaster();
  else
  self._formSlave();

}

//

function _formMaster()
{
  var self = this;

  throw _.err( 'abstract' );

}

//

function _formSlave()
{
  var self = this;

  throw _.err( 'abstract' );

}

//

function _formStreams()
{
  var self = this;
  var com = self.communicator;

  /* */

  if( self.bufferStreamLike )
  {

    _.assert( self.bufferStreamLike );
    _.assert( !self._bufferSendAct );

    self._bufferSendAct = function _bufferSendAct( data )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      /* var data = this._packetSendBegin({ data }); */
      this.bufferStreamLike.write( _.bufferNodeFrom( data ) );
    }

    self.bufferStreamLike.on( 'data', function( msg )
    {
      logger.log( com.nameTitle, 'bufferStreamLike:data', msg );
    });

    self.bufferStreamLike.on( 'message', function( msg )
    {
      logger.log( com.nameTitle, 'bufferStreamLike:message', msg );
    });

    self.bufferStreamLike.on( 'readable', function()
    {
    });

    self.bufferStreamLike.on( 'error', function( err )
    {
      self._errorReceive({ err });
    });

    self.bufferStreamLike.on( 'finish', function()
    {
      if( com.verbosity > 1 )
      logger.log( com.nameTitle, 'bufferStreamLike:finish' );
    });

    self.bufferStreamLike.on( 'end', function()
    {
      if( com.verbosity > 1 )
      logger.log( com.nameTitle, 'bufferStreamLike:end' );
    });

  }

  /* */

  _.assert( self.primeStreamLike );

  if( _.routineIs( this.primeStreamLike.send ) )
  self._packetSendAct = function _packetSendAct( data )
  {
    _.assert( arguments.length === 1, 'Expects single argument' );
    this.primeStreamLike.send( data );
  }
  else if( _.routineIs( this.primeStreamLike.write ) )
  self._packetSendAct = function _packetSendAct( data )
  {
    _.assert( arguments.length === 1, 'Expects single argument' );
    // if( !_.bufferNodeIs( data ) && !_.strIs( data ) )
    // data = _.entity.exportJson( data );
    // _.assert( data instanceof U8x );
    data = _.entity.exportJson( data ) + self._streamDelimeterString;
    this.primeStreamLike.write( data );
  }
  else _.assert( 0, 'prime stream does not has "send" neither "write"' );

  if( !self.bufferStreamLike )
  // if( !self._bufferSendAct )
  self._bufferSendAct = self._bufferSendWithTheSameStream;

  self.primeStreamLike.on( 'data', function( data )
  {
    self._rawReceive({ data });
  });

  self.primeStreamLike.on( 'message', function( packet )
  {
    self._packetReceive({ packet });
  });

  self.primeStreamLike.on( 'error', function( err )
  {
    self._errorReceive({ err });
  });

  self.primeStreamLike.on( 'disconnect', function()
  {
    if( com.verbosity > 1 )
    logger.log( com.nameTitle, 'disconnect' );
    self._terminateReceive();
  });

  self.primeStreamLike.on( 'close', function()
  {
    if( com.verbosity > 1 )
    logger.log( com.nameTitle, 'close' );
    self._terminateReceive();
  });

  self.primeStreamLike.on( 'connect', function()
  {
    if( com.verbosity > 1 )
    logger.log( com.nameTitle, 'connect' );
  });

  self.primeStreamLike.on( 'drain', function()
  {
    if( com.verbosity > 1 )
    logger.log( com.nameTitle, 'drain' );
  });

  self.primeStreamLike.on( 'end', function()
  {
    if( com.verbosity > 1 )
    logger.log( com.nameTitle, 'end' );
  });

  self.primeStreamLike.on( 'lookup', function()
  {
    if( com.verbosity > 1 )
    logger.log( com.nameTitle, 'lookup' );
  });

  self.primeStreamLike.on( 'timeout', function()
  {
    if( com.verbosity > 1 )
    logger.log( com.nameTitle, 'timeout' );
  });

  // Event: 'close'
  // Event: 'connect'
  // Event: 'data'
  // Event: 'drain'
  // Event: 'end'
  // Event: 'error'
  // Event: 'lookup'
  // Event: 'timeout'

}

//

function _formTempSend()
{
  var self = this;
  var com = self.communicator;

  function _packetSendAct( data )
  {
    _.assert( arguments.length === 1, 'Expects single argument' );
    self._packetSendLater.push( data );
  }

  function _bufferSendAct( data )
  {
    _.assert( arguments.length === 1, 'Expects single argument' );
    self._bufferSendLater.push( data );
  }

  _.assert( self._packetSendAct === null );
  self._packetSendAct = _packetSendAct;
  _.assert( self._bufferSendAct === null );
  self._bufferSendAct = _bufferSendAct;

  self._conConnect.finally( function()
  {

    var i = 0;

    _.assert( self._packetSendAct !== _packetSendAct );
    for( i = 0 ; i < self._packetSendLater.length ; i++ )
    self._packetSendAct( self._packetSendLater[ i ] );
    self._packetSendLater.splice( 0, self._packetSendLater.length );

    _.assert( self._bufferSendAct !== _bufferSendAct );
    for( i = 0 ; i < self._bufferSendLater.length ; i++ )
    self._bufferSendAct( self._bufferSendLater[ i ] );
    self._bufferSendLater.splice( 0, self._bufferSendLater.length );

  });

}

// --
//
// --

// function _formBufferSend()
// {
//   var self = this;
//   var com = self.communicator;
//
//   _.assert( !self.bufferStreamLike );
//   _.assert( !self._bufferSend );
//
//   self._bufferSend = function _bufferSend( data )
//   {
//     _.assert( arguments.length === 1, 'Expects single argument' );
//     this.packetSpecialSend( 'buffer',{ size : data.byteLength, cls : data.constructor } );
//     // this.primeStreamLike.write( _.bufferNodeFrom( data ) );
//   }
//
// }

//

function _bufferSendWithTheSameStream( buffer )
{
  var self = this;
  var com = self.communicator;
  _.assert( arguments.length === 1, 'Expects single argument' );

  self._packetSpecialSend( 'buffer', { size : buffer.byteLength, cls : buffer.constructor.name } );

  self.primeStreamLike.write( _.bufferNodeFrom( buffer ) );
}

//

function _bufferSend( buffer )
{
  var self = this;
  var com = self.communicator;
  _.assert( arguments.length === 1, 'Expects single argument' );
  self._bufferSendAct( buffer );
}

//

function _packetSpecialSend( o )
{
  var self = this;
  var com = self.communicator;
  var o;

  if( arguments.length === 2 )
  o = { channel : arguments[ 0 ], data : arguments[ 1 ] }

  _.assert( o.channel !== undefined && o.channel !== null );
  _.assert( o.data !== undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routine.options_( _packetSpecialSend, o );

  o.subchannel = 'packetSpecial';
  self._packetSend( o );

  return self;
}

_packetSpecialSend.defaults =
{
  channel : null,
  data : null,
}

//

function packetSend( o )
{
  var self = this;
  var com = self.communicator;

  if( arguments.length === 2 )
  o = { channel : arguments[ 0 ], data : arguments[ 1 ] }
  else
  o = { channel : 'message', data : arguments[ 0 ] }

  _.assert( arguments.length === 1 || arguments.length === 2 );

  self._packetSend( o );

  return self;
}

//

function _packetSend( o )
{
  var self = this;
  var com = self.communicator;

  // if( arguments.length === 2 )
  // o = { channel : arguments[ 0 ], data : arguments[ 1 ] }
  // else
  // o = { channel : 'message', data : arguments[ 0 ] }

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( o.channel !== undefined && o.channel !== null );
  _.assert( o.data !== undefined );
  _.routine.options_( _packetSend, o );

  self._packetCounter += 1;

  if( o.encoding === 'complex' )
  {
    o.data = _.cloneDataSeparatingBuffers({ src : o.data });
    // o.encoding = 'complex';
  }

  var packet = Object.create( null );
  packet.channel = o.channel;
  packet.subchannel = o.subchannel;
  packet.packetId = self._packetCounter;
  packet.data = o.data;
  packet.encoding = o.encoding;

  packet = self._packetSendBegin( packet );


  self._packetSendAct( packet );

  return self;
}

_packetSend.defaults =
{
  channel : null,
  subchannel : '',
  // encoding : 'complex',
  encoding : null,
  data : null,
}

//

function _packetSendBegin( o )
{
  var self = this;
  var com = self.communicator;
  _.routine.options_( _packetSendBegin, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strDefined( o.channel ), 'Expects string { channel }, but got', _.entity.strType( o.channel ) );
  return o;
}

_packetSendBegin.defaults =
{
  channel : null,
  subchannel : '',
  data : null,
  packetId : null,
  encoding : null,
}

//

function _rawReceive( o )
{
  var self = this;
  var com = self.communicator;

  _.routine.options_( _rawReceive, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.bufferNodeIs( o.data ) );

  o.data = _.bufferBytesGet( o.data );
  self._streamBuffer = _.bufferJoin( self._streamBuffer, o.data );

  self._rawReceivedProceed();

}

_rawReceive.defaults =
{
  data : null,
}

//

function _rawReceivedProceed()
{
  var self = this;
  var com = self.communicator;

  try
  {

    _.assert( arguments.length === 0, 'Expects no arguments' );

    if( self._receivingBuffer )
    return self._rawRecievedBufferProceed();

    var packets = _.bufferCutOffLeft( self._streamBuffer, self._streamDelimeterBuffer );
    self._streamBuffer = packets[ packets.length-1 ];

    while( packets[ 0 ] )
    {

      var packet = packets[ 0 ];
      _.assert( packet.length );

      var packet = self._packetReceive({ format : 'buffer', packet });
      if( packet )
      if( packet.channel === 'buffer' && packet.subchannel === 'packetSpecial' )
      {
        self._receivingBuffer = _.props.extend( null, packet, packet.data );
        delete self._receivingBuffer.data;
        logger.log( 'receiving\n', self._receivingBuffer );
        self._rawRecievedBufferProceed();
        return;
      }

      var packets1 = _.bufferCutOffLeft( self._streamBuffer, self._streamDelimeterBuffer );
      self._streamBuffer = packets1[ packets1.length-1 ];

    }

  }
  catch( err )
  {
    return self._errorReceive({ err });
  }

}

_rawReceive.defaults =
{
  data : null,
}

//

function _rawRecievedBufferProceed()
{
  var self = this;
  var com = self.communicator;
  var receiving = self._receivingBuffer;

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( receiving );
  _.assert( _global_[ receiving.cls ], 'unknown type of buffer', receiving.cls );
  _.assert( _.bufferBytesIs( self._streamBuffer ) );

  if( self._streamBuffer.length < receiving.size )
  return;

  self._receivingBuffer = null;

  var buffer = self._streamBuffer.subarray( 0, receiving.size );
  self._streamBuffer = self._streamBuffer.subarray( receiving.size )

  if( buffer.constructor.name !== receiving.cls )
  buffer = _.bufferRetype( buffer, _global_[ receiving.cls ] );

  self._bufferReceive({ buffer });
  self._rawReceivedProceed();

}

//

function _bufferReceive( o )
{
  var self = this;
  var com = self.communicator;

  _.routine.options_( _bufferReceive, o );

  com.eventGive({ kind : 'buffer', buffer : o.buffer });

}

_bufferReceive.defaults =
{
  buffer : null,
}

//

function _packetReceive( o )
{
  var self = this;
  var com = self.communicator;

  try
  {

    _.routine.options_( _packetReceive, o );
    _.assert( arguments.length === 1, 'Expects single argument' );

    if( o.format === 'buffer' )
    {
      o.packet = _.bufferNodeFrom( o.packet ).toString( 'utf8' );
      o.format = 'json';
    }


    if( o.format === 'json' )
    {
      o.packet = JSON.parse( o.packet );
      o.format = 'parsed';
    }

    if( com.verbosity > 1 )
    if( o.packet.subchannel === 'packetSpecial' )
    logger.log( com.nameTitle, ':', 'packet received in channel', _.strQuote( o.packet.channel ), 'and subchannel', _.strQuote( o.packet.subchannel ) );
    else
    logger.log( com.nameTitle, ':', 'packet received in channel', _.strQuote( o.packet.channel ) );

    // if( o.packet.channel === 'packetSpecial' )
    // {
    //   // o.packet.subchannel = o.packet.subchannel;
    //   _.assert( o.packet.subchannel );
    // }

    _.assert( o.packet.channel !== undefined );
    _.assert( !com.specialChannels[ o.packet.channel ] );

    if( com.channels[ o.packet.channel ] )
    com.channels[ o.packet.channel ].call( self, o.packet.data, o.packet.channel );

    var e = Object.create( null );
    e.subchannel = o.packet.subchannel;
    e.channel = o.packet.channel;
    e.data = o.packet.data;
    e.kind = 'packet';
    com.eventGive( e );

    if( !o.packet.subchannel )
    {
      e.kind = 'message';
      com.eventGive( e );
    }
    else if( o.packet.subchannel === 'packetSpecial' )
    {
      self._packetSpecialReceive({ format : 'parsed', packet : o.packet });
    }

    return o.packet;
  }
  catch( err )
  {
    err = _.err( err, '\n', o.packet );
    if( com.verbosity )
    _.errLogOnce( err );
    self._errorReceive({ err });
    return null;
  }

}

_packetReceive.defaults =
{
  format : 'parsed',
  packet : null,
}

//

function _packetSpecialReceive( o )
{
  var self = this;
  var com = self.communicator;

  _.routine.options_( _packetSpecialReceive, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( o.packet.subchannel === 'packetSpecial', o.packet );
  _.assert( _.strIs( o.packet.subchannel ), o.packet );

  com.eventGive
  ({
    kind : 'packetSpecial',
    channel : o.packet.channel,
    subchannel : o.packet.subchannel,
    data : o.packet.data,
  });

}

_packetSpecialReceive.defaults =
{
  format : 'parsed',
  packet : null,
}

//

function _errorReceive( o )
{
  var self = this;
  var com = self.communicator;

  com.errors.push( null );

  _.routine.options_( _errorReceive, o );
  _.assert( arguments.length === 1, 'Expects single argument' );

  var err = _.err( com.nameTitle, ':', 'error\n', o.err );

  if( com.verbosity )
  err = _.errLogOnce( err );

  com.errors[ com.errors.length ] = err;

  return err;
}

_errorReceive.defaults =
{
  err : null,
}

//

function _terminateReceive()
{
  var self = this;
  var com = self.communicator;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  self._terminateReceiveBefore();

  // if( com.channels[ 'packetSpecial' ] )
  // com.channels[ 'packetSpecial' ].call( self, { reason : 'terminateReceived', data : null }, 'packetSpecial' );

  self._packetSpecialReceive({ packet : { channel : 'terminateReceived', subchannel : 'packetSpecial' } });

  com.eventGive({ kind : 'terminateReceived' });

  self._terminateReceiveAfter();

}

//

function _terminateReceiveBefore()
{
  var self = this;
  var com = self.communicator;

  _.assert( arguments.length === 0, 'Expects no arguments' );

}

//

function _terminateReceiveAfter()
{
  var self = this;
  var com = self.communicator;

  _.assert( arguments.length === 0, 'Expects no arguments' );

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
  communicator : null,
  bufferStreamLike : null,
  primeStreamLike : null,
}

var Restricts =
{

  _receivingBuffer : 0,
  _packetSendAct : null,
  _bufferSendAct : null,

  _streamDelimeter : '\0\n',
  _streamDelimeterBuffer : null,
  _streamDelimeterString : null,
  _streamBuffer : null,

  _conConnect : _.Consequence(),
  _packetSendLater : [],
  _bufferSendLater : [],
  _packetCounter : 0,

}

var Statics =
{
}

var Forbids =
{
  verbosity : 'verbosity',
  errors : 'errors',
  isMaster : 'isMaster',
  isSlave : 'isSlave',
  nameTitle : 'nameTitle',
  nameRole : 'nameRole',
  url : 'url',
  defaultHost : 'defaultHost',
  defaultPort : 'defaultPort',
  specialChannels : 'specialChannels',
  channels : 'channels',
}

// --
// declare
// --

const Proto =
{

  init,

  unform,
  _unform,

  form,

  _formMaster,
  _formSlave,

  _formStreams,
  _formTempSend,

  //

  _bufferSendWithTheSameStream,
  _bufferSend,

  _packetSpecialSend,

  packetSend,
  _packetSend,
  _packetSendBegin,

  _rawReceive,
  _rawReceivedProceed,
  _rawRecievedBufferProceed,
  _bufferReceive,
  _packetReceive,
  _packetSpecialReceive,
  _errorReceive,
  _terminateReceive,
  _terminateReceiveBefore,
  _terminateReceiveAfter,


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

_.Copyable.mixin( Self );

_.accessor.forbid( Self.prototype, Forbids );

//

// _.assert( _.CommunicatorStream );
_.CommunicatorProtocol[ Self.shortName ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
