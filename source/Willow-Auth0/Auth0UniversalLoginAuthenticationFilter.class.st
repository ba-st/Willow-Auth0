"
I'm a request filter providing integration with Auth0's Universal Login flow. 
Basically I will perform the required redirections so the end user can be authenticated by the platform.
"
Class {
	#name : #Auth0UniversalLoginAuthenticationFilter,
	#superclass : #WARequestFilter,
	#instVars : [
		'domain',
		'clientId',
		'redirectionURI',
		'nonceProvider',
		'knownStates',
		'jsonWebSignatureProvider',
		'knownNonces'
	],
	#category : #'Willow-Auth0'
}

{ #category : #'instance creation' }
Auth0UniversalLoginAuthenticationFilter class >> withDomain: aDomain clientId: aClientId redirectingTo: aRedirectionURI nonceProvidedBy: aBlock JWSProvidedBy: aDyadicBlock [

	^ self new
		initializeWithDomain: aDomain
		clientId: aClientId
		redirectingTo: aRedirectionURI
		nonceProvidedBy: aBlock
		JWSProvidedBy: aDyadicBlock
]

{ #category : #processing }
Auth0UniversalLoginAuthenticationFilter >> handleFiltered: aRequestContext [

	aRequestContext request isGet then: [ ^ self handleGet: aRequestContext ].
	aRequestContext request isPost then: [ ^ self handlePost: aRequestContext ].
	^ self respondForbidden: aRequestContext
]

{ #category : #processing }
Auth0UniversalLoginAuthenticationFilter >> handleGet: aRequestContext [

	"A Get request including the session information follows the standard path.
	In case the session key is missing perform the Login flow"

	^ self
		sessionKeyFrom: aRequestContext
		ifFound: [ :sessionKey | super handleFiltered: aRequestContext ]
		ifAbsent: [ self redirectToAuthorizeEndpoint: aRequestContext ]
]

{ #category : #processing }
Auth0UniversalLoginAuthenticationFilter >> handlePost: aRequestContext [

	^ self
		sessionKeyFrom: aRequestContext
		ifFound: [ :sessionKey | super handleFiltered: aRequestContext ]
		ifAbsent: [ self
				processStateFieldIn: aRequestContext ifAbsent: [ ^ self respondForbidden: aRequestContext ];
				processTokenIn: aRequestContext ifInvalid: [ ^ self respondForbidden: aRequestContext ].
			super handleFiltered: aRequestContext
			]
]

{ #category : #initialization }
Auth0UniversalLoginAuthenticationFilter >> initializeWithDomain: aDomain clientId: aClientId redirectingTo: aRedirectionURI nonceProvidedBy: aBlock JWSProvidedBy: aDyadicBlock [

	knownStates := Dictionary new.
	knownNonces := 	OrderedCollection new.
	domain := aDomain.
	clientId := aClientId.
	redirectionURI := aRedirectionURI .
	nonceProvider := aBlock.
	jsonWebSignatureProvider := aDyadicBlock
]

{ #category : #private }
Auth0UniversalLoginAuthenticationFilter >> jsonWebSignatureFrom: tokenString ifInvalid: aBlockClosure [

	^ jsonWebSignatureProvider value: tokenString value: aBlockClosure
]

{ #category : #private }
Auth0UniversalLoginAuthenticationFilter >> newNonce [

	^ nonceProvider value
]

{ #category : #'private - processing' }
Auth0UniversalLoginAuthenticationFilter >> processClaimsIn: claimSet ifInvalid: anInvalidAction [

	[ claimSet expirationTime asInteger <= DateAndTime now asUnixTime then: anInvalidAction.
	claimSet issuer ~= ( 'https://<1s>/' expandMacrosWith: domain ) then: anInvalidAction.
	claimSet audiences ~= clientId then: anInvalidAction.
	knownNonces remove: claimSet nonce ifAbsent: anInvalidAction
	]
		on: KeyNotFound
		do: anInvalidAction
]

{ #category : #'private - processing' }
Auth0UniversalLoginAuthenticationFilter >> processStateFieldIn: aRequestContext ifAbsent: anInvalidAction [

	aRequestContext request postFields
		at: 'state'
		ifPresent: [ :state | 
			knownStates
				at: state
				ifPresent: [ :originalUri | 
					self updateUriIn: aRequestContext withPathAndQueryFieldsFrom: originalUri.
					knownStates removeKey: state ifAbsent: anInvalidAction.
					^ self
					]
			].

	^ anInvalidAction value
]

{ #category : #'private - processing' }
Auth0UniversalLoginAuthenticationFilter >> processTokenIn: aRequestContext ifInvalid: anInvalidAction [

	aRequestContext request postFields
		at: 'id_token'
		ifPresent: [ :jwt | 
			| jws |

			jws := self jsonWebSignatureFrom: jwt ifInvalid: anInvalidAction.
			self processClaimsIn: jws payload ifInvalid: anInvalidAction.
			^ self
			].
	anInvalidAction value
]

{ #category : #private }
Auth0UniversalLoginAuthenticationFilter >> redirectToAuthorizeEndpoint: aRequestContext [

	| authorizeEndpoint stateNonce jwtNonce|

	authorizeEndpoint := ( 'https://<1s>/authorize' expandMacrosWith: domain ) seasideUrl.
	authorizeEndpoint addField: 'client_id' value: clientId.
	authorizeEndpoint addField: 'redirect_uri' value: redirectionURI.
	authorizeEndpoint addField: 'scope' value: 'openid email profile'.
	authorizeEndpoint addField: 'response_type' value: 'token id_token'.
	authorizeEndpoint addField: 'response_mode' value: 'form_post'.
	jwtNonce := self newNonce.
	knownNonces add: jwtNonce.
	authorizeEndpoint addField: 'nonce' value: jwtNonce.
	stateNonce := self newNonce.
	knownStates at: stateNonce put: aRequestContext request uri.
	authorizeEndpoint addField: 'state' value: stateNonce.
	aRequestContext responseGenerator
		redirectTo: authorizeEndpoint;
		respond
]

{ #category : #'private - processing' }
Auth0UniversalLoginAuthenticationFilter >> respondForbidden: aRequestContext [

	^ aRequestContext responseGenerator
		forbidden;
		respond
]

{ #category : #private }
Auth0UniversalLoginAuthenticationFilter >> sessionKeyFrom: aRequestContext ifFound: aFoundBlock ifAbsent: aNoneBlock [

	^ ( self handler trackingStrategy keyFromContext: aRequestContext )
		ifNil: aNoneBlock
		ifNotNil: aFoundBlock
]

{ #category : #private }
Auth0UniversalLoginAuthenticationFilter >> updateUriIn: aRequestContext withPathAndQueryFieldsFrom: originalUri [

	originalUri path
		ifNotEmpty: [ :paths | aRequestContext request uri addAllToPath: paths withoutFirst ].
	originalUri queryFields
		keysAndValuesDo: [ :key :value | 
			[ aRequestContext request uri addField: key value: value ]
				unless: ( aRequestContext request uri isSeasideField: key )
			]
]
