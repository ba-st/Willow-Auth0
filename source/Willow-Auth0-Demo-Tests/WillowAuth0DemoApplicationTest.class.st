"
A WillowAuth0DemoApplicationTest is a test class for testing the behavior of WillowAuth0DemoApplication
"
Class {
	#name : #WillowAuth0DemoApplicationTest,
	#superclass : #TestCase,
	#instVars : [
		'application',
		'port'
	],
	#category : #'Willow-Auth0-Demo-Tests'
}

{ #category : #running }
WillowAuth0DemoApplicationTest >> runCase [

	self shouldnt: [ super runCase ] raise: Exit
]

{ #category : #running }
WillowAuth0DemoApplicationTest >> setUp [

	super setUp.
	port := self freeListeningTCPPort
]

{ #category : #running }
WillowAuth0DemoApplicationTest >> start: aLaunchpadApplication withAll: arguments [

	String streamContents: [ :stream | 
		| context rootCommand |

		rootCommand := LaunchpadRootCommand new.
		context := LaunchpadCommandLineProcessingContext
			           handling: ( CommandLineArguments withArguments: { 
						             'launchpad'.
						             'start'.
						             '--debug-mode'.
						             aLaunchpadApplication commandName } , arguments )
			           writingTo: stream.
		self assert: ( rootCommand canHandle: ( context nextCommandLineArgumentIfNone: [ self fail ] ) ).
		rootCommand evaluateWithin: context.
		application := LaunchpadApplication currentlyRunning
		]
]

{ #category : #running }
WillowAuth0DemoApplicationTest >> tearDown [ 

	application ifNotNil: #stop.
	super tearDown
]

{ #category : #running }
WillowAuth0DemoApplicationTest >> testActivationWithAllArguments [

	self
		shouldnt: [ 
			self
				start: WillowAuth0DemoApplication
				withAll: #( '--public-url=http://localhost' '--auth0.domain=auth0.example.com'
					   '--auth0.client-id=id' '--auth0.client-secret=secret' )
					, { '--listening-port=<1p>' expandMacrosWith: port }
			]
		raise: Exit.

	self
		assert: application configuration publicURL equals: 'http://localhost';
		assert: application configuration listeningPort equals: port;
		deny: application configuration auth0 disableSecureTransport;
		assert: application configuration auth0 domain equals: 'auth0.example.com';
		assert: application configuration auth0 clientId equals: 'id';
		assert: application configuration auth0 clientSecret equals: 'secret'.

	[ 1 / 0 ]
		on: Error
		do: [ :error | application stackTraceDumper dumpStackTraceFor: error ]
]

{ #category : #tests }
WillowAuth0DemoApplicationTest >> testPrintHelpOn [

	| help |

	help := String streamContents: [ :s | WillowAuth0DemoApplication printHelpOn: s ].
	self assert: help notEmpty
]
