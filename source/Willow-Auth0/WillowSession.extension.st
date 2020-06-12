Extension { #name : #WillowSession }

{ #category : #'*Willow-Auth0' }
WillowSession >> logoutFromAuth0: aWillowApplication [

	self unregister.
	self requestContext redirectTo: aWillowApplication logoutUrl
]
