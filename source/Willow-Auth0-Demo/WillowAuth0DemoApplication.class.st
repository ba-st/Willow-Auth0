"
willow-auth0-demo - A demo web application using Auth0 Universal Login

## Parameters
- `--public-url=<publicURL>` Public location where the app is deployed.
- `--listening-port=<listeningPort>`	Web server's Listening port. Defaults to 3000.
- `--auth0.disable-secure-transport=<disableSecureTransport>` Connect to the authentication provider with HTTP instead of HTTPS. Just for local development. Defaults to false.
- `--auth0.domain=<domain>` Auth0 domain to connect. For example: company.auth0.com.
- `--auth0.client-id=<clientId>` Client ID associated with this application in Auth0.
- `--auth0.client-secret=<clientSecret>` Client secret  associated with this application in Auth0.
## Environment
- `PUBLIC_URL` Public location where the app is deployed.
- `LISTENING_PORT` Web server's Listening port. Defaults to 3000.
- `AUTH0__DISABLE_SECURE_TRANSPORT` Connect to the authentication provider with HTTP instead of HTTPS. Just for local development. Defaults to false.
- `AUTH0__DOMAIN` Auth0 domain to connect. For example: company.auth0.com.
- `AUTH0__CLIENT_ID` Client ID associated with this application in Auth0.
- `AUTH0__CLIENT_SECRET` Client secret  associated with this application in Auth0.

"
Class {
	#name : #WillowAuth0DemoApplication,
	#superclass : #LaunchpadApplication,
	#instVars : [
		'stackTraceDumper'
	],
	#classInstVars : [
		'version'
	],
	#category : #'Willow-Auth0-Demo'
}

{ #category : #accessing }
WillowAuth0DemoApplication class >> commandName [

	^ 'willow-auth0-demo'
]

{ #category : #accessing }
WillowAuth0DemoApplication class >> configurationParameters [

	^ { 
		  MandatoryConfigurationParameter
			    named: 'Public URL'
			    describedBy: 'Public location where the app is deployed'.
		  OptionalConfigurationParameter
			    named: 'Listening port'
			    describedBy: 'Web server''s Listening port'
			    defaultingTo: 3000
			    convertingWith: #asNumber.
		  OptionalConfigurationParameter
			    named: 'Disable secure transport'
			    describedBy:
			    'Connect to the authentication provider with HTTP instead of HTTPS. Just for local development'
			    inside: #( 'Auth0' )
			    defaultingTo: false
			    convertingWith: [ :value | value = 'true' ].
		  MandatoryConfigurationParameter
			    named: 'Domain'
			    describedBy: 'Auth0 domain to connect. For example: company.auth0.com'
			    inside: #( 'Auth0' ).
		  MandatoryConfigurationParameter
			    named: 'Client Id'
			    describedBy: 'Client ID associated with this application in Auth0'
			    inside: #( 'Auth0' ).
		  ( MandatoryConfigurationParameter
			    named: 'Client Secret'
			    describedBy: 'Client secret  associated with this application in Auth0'
			    inside: #( 'Auth0' ) ) asSensitive }
]

{ #category : #accessing }
WillowAuth0DemoApplication class >> description [

	^ 'A demo web application using Auth0 Universal Login'
]

{ #category : #initialization }
WillowAuth0DemoApplication class >> initialize [

	<ignoreForCoverage>
	version := VersionFromRepositoryResolver new valueFor: #BaselineOfWillowAuth0
]

{ #category : #accessing }
WillowAuth0DemoApplication class >> version [

	^ version
]

{ #category : #'private - activation/deactivation' }
WillowAuth0DemoApplication >> basicStartWithin: context [

	LaunchpadLogRecord emitInfo: 'Registering Willow Auth0 web application'.
	WillowAuth0Demo registerAsDeployedApplication.
	LaunchpadLogRecord emitInfo: 'Starting web server'.
	( ZnZincServerAdaptor port: self configuration listeningPort )
		codec: ( GRCodec forEncoding: 'utf8' );
		start.
	LaunchpadLogRecord emitInfo: 'Start up complete'
]

{ #category : #'private - activation/deactivation' }
WillowAuth0DemoApplication >> basicStop [

	ZnServer stopDefault.
	ZnZincServerAdaptor allInstancesDo: [ :each | each shutDown ].
	WillowAuth0Demo unregisterFromApplications.
	super basicStop
]

{ #category : #initialization }
WillowAuth0DemoApplication >> initializeRunningIn: anApplicationMode configuredBy: aConfigurationProvider controlledBy: aCommandServer [

	super
		initializeRunningIn: anApplicationMode
		configuredBy: aConfigurationProvider
		controlledBy: aCommandServer.
	stackTraceDumper := self newStackTraceDumperOnStandardError
]

{ #category : #'error handling' }
WillowAuth0DemoApplication >> stackTraceDumper [

	^ stackTraceDumper
]
