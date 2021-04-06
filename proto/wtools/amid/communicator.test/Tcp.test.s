( function _Tcp_test_s_( )
{

/*hhh*/

'use strict';

// !!! disabled because it is experimental functionality
// return;
// console.warn( 'REMINDER : fix me' );
// !!!

if( typeof module === 'undefined' )
return;

if( typeof module !== 'undefined' )
{

  const _ = require( 'Tools' );

  _.include( 'wTesting' );
  // _.include( 'wCommunicator' );
  require( './../communicator/Communicator.s' );
  require( './Abstract.test.s' );

}

const _ = _global_.wTools;
const Parent = wTests[ 'CommunicatorAbstract' ];
_.assert( !!Parent );

// --
// test
// --

// --
// proto
// --

const Proto =
{

  name : 'CommunicatorTcp',
  abstract : 0,
  silencing : 1,
  enabled : 0,
  // verbosity : 7,

  context :
  {
    // communicationUrl : 'tcp://127.0.0.1:5678',
    // communicationUrl : 'tcp://0.0.0.0:5678',
    communicationUrl : 'tcp://localhost:5678',
  },

  tests :
  {

  },

};

const Self = wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
