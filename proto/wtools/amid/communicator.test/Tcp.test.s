( function _Tcp_test_s_( ) {

'use strict'; /*hhh*/

// !!! disabled because it is experimental functionality
// return;
// console.warn( 'REMINDER : fix me' );
// !!!

if( typeof module === 'undefined' )
return;

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../../wtools/Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wCommunicator' );

  require( './Abstract.test.s' );

}

let _ = _global_.wTools;
let Parent = wTests[ 'CommunicatorAbstract' ];
_.assert( !!Parent );

// --
// test
// --

// --
// proto
// --

var Proto =
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

let Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
