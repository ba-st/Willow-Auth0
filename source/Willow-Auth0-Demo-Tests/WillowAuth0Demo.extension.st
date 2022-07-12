Extension { #name : #WillowAuth0Demo }

{ #category : #'*Willow-Auth0-Demo-Tests' }
WillowAuth0Demo class >> start [

	<ignoreForCoverage>
	self registerAsDevelopmentApplication.
	( ZnZincServerAdaptor port: 3000 )
		codec: ( GRCodec forEncoding: 'utf8' );
		start
]

{ #category : #'*Willow-Auth0-Demo-Tests' }
WillowAuth0Demo class >> stop [

	<ignoreForCoverage>
	ZnServer stopDefault.
	ZnZincServerAdaptor allInstancesDo: [ :each | each shutDown ].
	self unregisterFromApplications
]
