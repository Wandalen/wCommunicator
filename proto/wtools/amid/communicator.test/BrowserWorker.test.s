( function _BrowserWorker_test_s_( )
{

'use strict';

return;

// !!! disabled because it is experimental functionality
// return;
// console.warn( 'REMINDER : fix me' );
// !!!

if( typeof module !== 'undefined' )
{

  require( './Abstract.test.s' );

  const _ = _global_.wTools;

  _.include( 'wTesting' );
  _.include( 'wCommunicator' );

}

const _ = _global_.wTools;
let Parent = wTests[ 'CommunicatorAbstract' ];
_.assert( !!Parent );

// --
//
// --

function onSuiteBegin()
{
  var suit = this;

  var worker = new Worker( './BrowserWorker.slave.test.s' );

}

// --
// test
// --

// --
// declare
// --

var Proto =
{

  name : 'CommunicatorBrowserWorker',
  abstract : 0,
  silencing : 1,
  // verbosity : 9,
  enabled : 0,

  onSuiteBegin,

  context :
  {
    // communicationUrl : 'worker://127.0.0.1:5678',
    // communicationUrl : 'worker://0.0.0.0:5678',
    communicationUrl : 'browser-worker://',
  },

  tests :
  {

  },

};

const Self = wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
