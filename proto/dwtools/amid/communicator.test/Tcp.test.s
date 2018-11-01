( function _Tcp_test_s_( ) {

'use strict';

// !!! disabled because it is experimental functionality
// return;
// console.warn( 'REMINDER : fix me' );
// !!!

if( typeof module === 'undefined' )
return;

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
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

  _.include( 'wTesting' );
  _.include( 'wCommunicator' );

  require( './Abstract.test.s' );

}

var _ = _global_.wTools;
var Parent = wTests[ 'CommunicatorAbstract' ];
_.assert( Parent );

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

var Self = new wTestSuit( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})();
