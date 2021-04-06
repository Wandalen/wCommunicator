( function _Abstract_test_s_( )
{

'use strict';

// if( typeof module === 'undefined' )
// return;

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );
  // _.include( 'wCommunicator' );

}

const _ = _global_.wTools;

// --
// test
// --

function trivial( test )
{
  var self = this;
  var bits = 13;

  var expectedByMaster = [ 'from slave a', 'from slave b', _.strDup( 'from slave c', 1 << bits ), null ];
  var expectedBySlave = [ 'from master a', 'from master b', _.strDup( 'from master c', 1 << bits ), null ];

  test.case = 'trivial';

  /* */

  var con = new _.Consequence().give( 1 );

  con.finally( function( err, arg )
  {
    test.identical( master.errors.length, 0 );
    test.identical( slave.errors.length, 0 );
  });

  /* */

  var master = new wCommunicator
  ({
    verbosity : 9,
    isMaster : 1,
    url : self.communicationUrl,
  });

  master.form();
  master.packetSend( 'from master a' );
  master.packetSend( 'from master b' );
  master.packetSend( _.strDup( 'from master c', 1 << bits ) );
  master.packetSend( null );

  master.on( 'terminateReceived', () => con.take( null ) );
  master.on( 'message', function( e )
  {
    test.identical( e.data, expectedByMaster[ 0 ] );
    expectedByMaster.splice( 0, 1 );
    if( expectedBySlave.length === 0 && expectedByMaster.length === 0 )
    {
      slave.unform();
      master.unform();
    }
  });

  /* */

  function slaveRun()
  {

    // var expectedBySlave = [ 'from master a', 'from master b', _.strDup( 'from master c', 1 << bits ), null ];
    // var bits = 13;

    var slave = new wCommunicator
    ({
      verbosity : 9,
      isMaster : 0,
      url : self.communicationUrl,
    });

    slave.form();
    slave.packetSend( 'from slave a' );
    slave.packetSend( 'from slave b' );
    slave.packetSend( _.strDup( 'from slave c', 1 << bits ) );
    slave.packetSend( null );

    slave.on( 'terminateReceived', function()
    {
      if( typeof con !== 'undefined' )
      con.take( null );
    });

    slave.on( 'message', function( e )
    {
      if( typeof test !== 'undefined' )
      test.identical( e.data, expectedBySlave[ 0 ] );
      expectedBySlave.splice( 0, 1 );
      if( expectedBySlave.length === 0 && expectedByMaster.length === 0 )
      {
        slave.unform();
        master.unform();
      }
    });

    return slave;
  }

  var slave = slaveRun();

  return con;
}

trivial.timeOut = 30000;

//

function buffer( test )
{
  var self = this;

  var expectedPacketsByMaster = [ 'from slave a' ];
  var expectedBuffersByMaster = [ new F32x([ 1, 2, 3 ]), new F32x([ 4, 5, 6 ]) ];
  var expectedPacketsBySlave = [ 'from master a' ];
  var expectedBuffersBySlave = [ new F32x([ 7, 8, 9 ]), new F32x([ 10, 11, 12 ]), new F32x([ 13, 14, 15 ]) ];

  test.case = 'buffer';

  /* */

  var con = new _.Consequence().give( 1 );

  con.finally( function( err, arg )
  {
    test.identical( expectedPacketsByMaster.length, 0 );
    test.identical( expectedBuffersByMaster.length, 0 );
    test.identical( expectedPacketsBySlave.length, 0 );
    test.identical( master.errors.length, 0 );
    test.identical( slave.errors.length, 0 );
  });

  /* */

  function maybeEnd()
  {
    if
    (
      expectedPacketsBySlave.length === 0
      && expectedBuffersByMaster.length === 0
      && expectedPacketsByMaster.length === 0
      && expectedBuffersBySlave.length === 0
    )
    {
      slave.unform();
      master.unform();
    }
  }

  /* */

  var master = new wCommunicator
  ({
    verbosity : 9,
    isMaster : 1,
    url : self.communicationUrl,
  });

  master.form();

  master.bufferSend( new F32x([ 7, 8, 9 ]) );
  master.bufferSend( new F32x([ 10, 11, 12 ]) );
  master.bufferSend( new F32x([ 13, 14, 15 ]) );

  master.packetSend( 'from master a' );

  master.on( 'terminateReceived', function()
  {
    logger.log( master.nameTitle, 'terminateReceived' );
    con.take( null );
  });

  master
  .on( 'terminateReceived', () => con.take( null ) )
  .on( 'message', function( e )
  {
    test.identical( e.data, expectedPacketsByMaster[ 0 ] );
    expectedPacketsByMaster.splice( 0, 1 );
    maybeEnd();
  })
  .on( 'packetSpecial', function( e )
  {
    logger.log( 'packetSpecial', e );
  })
  .on( 'buffer', function( e )
  {
    logger.log( 'buffer', e.buffer );
    test.identical( e.buffer, expectedBuffersByMaster[ 0 ] );
    expectedBuffersByMaster.splice( 0, 1 );
    maybeEnd();
  });

  /* */

  var slave = new wCommunicator
  ({
    verbosity : 9,
    isMaster : 0,
    url : self.communicationUrl,
  });

  slave.form();
  slave.packetSend( 'from slave a' );

  slave.bufferSend( new F32x([ 1, 2, 3 ]) );
  slave.bufferSend( new F32x([ 4, 5, 6 ]) );

  slave
  .on( 'terminateReceived', function()
  {
    logger.log( slave.nameTitle, 'terminateReceived' );
    con.take( null );
  })
  .on( 'packetSpecial', function( e )
  {
    logger.log( 'packetSpecial', e );
  })
  .on( 'message', function( e )
  {
    test.identical( e.data, expectedPacketsBySlave[ 0 ] );
    expectedPacketsBySlave.splice( 0, 1 );
    maybeEnd();
  })
  .on( 'buffer', function( e )
  {
    logger.log( 'buffer', e.buffer );
    test.identical( e.buffer, expectedBuffersBySlave[ 0 ] );
    expectedBuffersBySlave.splice( 0, 1 );
    maybeEnd();
  });

  return con;
}

buffer.timeOut = 30000;

// --
// declare
// --

const Proto =
{

  name : 'CommunicatorAbstract',
  abstract : 1,
  silencing : 1,
  // verbosity : 7,

  tests :
  {

    trivial,
    buffer,

  },

};

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
