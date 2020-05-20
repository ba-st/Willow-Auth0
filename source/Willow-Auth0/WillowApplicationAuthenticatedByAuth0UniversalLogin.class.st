"
I'm a Willow application that integrates its authentication with Auth0 Universal Login.
I will provide a request filter performing the needed authentication redirections, and facilities to obtain the user profile and logout.

I'm an abstract class, my subclasses must provide the following information: Auth0 domain, the client id, the redirection URI and a nonce generation strategy.
"
Class {
	#name : #WillowApplicationAuthenticatedByAuth0UniversalLogin,
	#superclass : #WillowApplication,
	#category : #'Willow-Auth0'
}

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> authenticationCallbackURL [

	"The URL to which Auth0 will redirect the browser after authorization has been granted by the user.
	Usually the URL where you're serving your app.
	Do not forget to add it to: Auth0 Dashboard -> Applications -> Your app -> Allowed Callback URLs"

	^ self subclassResponsibility
]

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> authenticationDomain [

	"I must return the domain to be used for redirecting the authentication requests.
	Usually is something like: 'my-tenant.auth0.com' if you're not using a custom domain.
	You can copy it from Auth0 Dashboard -> Applications -> Your app -> Domain"

	^ self subclassResponsibility
]

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> clientId [

	"You can copy it from Auth0 Dashboard -> Applications -> Your app -> Client ID"

	^ self subclassResponsibility
]

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> jsonWebTokenSignatureAlgorithm [

	"You can copy it from Auth0 Dashboard -> Applications -> Your app -> Advanced Settings -> OAuth ->  JsonWebToken Signature Algorithm
	and use JsonWebAlgorithm named: 'algorithm name' with the copied value"

	^ self subclassResponsibility
]

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> logoutReturnUrl [

	"This URL must be configured in Allowed Logout URLs on the Auth0 Dashboard"

	^ self subclassResponsibility
]

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> logoutUrl [

	^ ( 'https://<1s>/v2/logout' expandMacrosWith: self authenticationDomain ) seasideUrl
		addField: 'client_id' value: self clientId;
		addField: 'returnTo' value: self logoutReturnUrl;
		yourself
]

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> materializeAndCheckSignatureOfJsonWebToken: tokenString [

	"This is the materialization hook. It needs to be in corcondance with the algorithm declared in #jsonWebTokenSignatureAlgorithm.
	You can do something like:
	JsonWebSignature materializeCompact: tokenString key: self yourSecretKeyOrPublicKey	"

	^ self subclassResponsibility
]

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> newAuthenticationFilter [

	^ Auth0UniversalLoginAuthenticationFilter
		withDomain: self authenticationDomain
		clientId: self clientId
		redirectingTo: self authenticationCallbackURL
		nonceProvidedBy: self nonceProvider
		JWSProvidedBy: [ :token :invalidAction | 
			[ 
			| jws |
			jws := self materializeAndCheckSignatureOfJsonWebToken: token.
			jws algorithm = self jsonWebTokenSignatureAlgorithm
				ifFalse: invalidAction.
			jws
			]
				on: Error
				do: [ :error | error return: invalidAction value ]
			]
]

{ #category : #private }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> nonceProvider [

	"The login flow needs to provide some nonces used in the Authentication API"

	^ [ ZnDigestAuthenticator new createNonce ]
]

{ #category : #utility }
WillowApplicationAuthenticatedByAuth0UniversalLogin class >> registerAsApplicationUsing: deploymentModeClass [

	^ ( super registerAsApplicationUsing: deploymentModeClass )
		addFilter: self newAuthenticationFilter;
		yourself
]

{ #category : #hooks }
WillowApplicationAuthenticatedByAuth0UniversalLogin >> initialRequest: request [

	"The only kind of initial request that is valid in this scheme is a POST"

	request isPost
		ifFalse: [ 
			self requestContext responseGenerator
				forbidden;
				respond
			].
	super initialRequest: request
]
