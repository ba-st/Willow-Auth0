"
An Auth0UniversalLoginAuthenticationFilterTest is a test class for testing the behavior of Auth0UniversalLoginAuthenticationFilter
"
Class {
	#name : #Auth0UniversalLoginAuthenticationFilterTest,
	#superclass : #BWRenderingTest,
	#instVars : [
		'filter'
	],
	#category : #'Willow-Auth0-Tests'
}

{ #category : #'private - asserting' }
Auth0UniversalLoginAuthenticationFilterTest >> assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter [

	self
		use: self requestContext
		during: [ | response |
			self requestContext handler addFilter: filter.
			response := self responseAfter: [ filter handleFiltered: self requestContext ].
			self assertStatusIsForbidden: response
			]
]

{ #category : #'private - asserting' }
Auth0UniversalLoginAuthenticationFilterTest >> assertStatusIsForbidden: response [

	self assert: response status equals: 403
]

{ #category : #'private - accessing' }
Auth0UniversalLoginAuthenticationFilterTest >> callbackURI [

	^ 'https://app.example.com'
]

{ #category : #'private - accessing' }
Auth0UniversalLoginAuthenticationFilterTest >> clientId [

	^ 'XJALSHFnoewhfj98jjds'
]

{ #category : #running }
Auth0UniversalLoginAuthenticationFilterTest >> createHandlers [

	^ Array
		with:
			( WAApplication new
				cache: WABidirectionalCache new;
				yourself )
]

{ #category : #'private - accessing' }
Auth0UniversalLoginAuthenticationFilterTest >> domain [

	^ 'example.auth0.com'
]

{ #category : #'private - accessing' }
Auth0UniversalLoginAuthenticationFilterTest >> expectedIssuer [

	^ 'https://<1s>/' expandMacrosWith: self domain
]

{ #category : #'private - accessing' }
Auth0UniversalLoginAuthenticationFilterTest >> jwtWithClaims: aBlock [

	| claims |

	claims := JWTClaimsSet new.
	aBlock value: claims.

	^ JsonWebSignature new
		algorithm: JWAHMACSHA256;
		payload: claims;
		key: self secret;
		compactSerialized
]

{ #category : #running }
Auth0UniversalLoginAuthenticationFilterTest >> receivePostRequestIncluding: jwt [

	"I will simulate receiving a POST request with a valid state field and a JWT token"

	requestContext := WARequestContext
		request:
			( ( WARequest method: 'POST' uri: WARequest defaultUri )
				setPostFields:
					( WARequestFields new
						at: 'state' put: 2;
						at: 'id_token' put: jwt;
						yourself ) )
		response: WABufferedResponse new
]

{ #category : #running }
Auth0UniversalLoginAuthenticationFilterTest >> receivePostRequestIncludingJWTClaiming: aBlock [

	self receivePostRequestIncluding: ( self jwtWithClaims: aBlock )
]

{ #category : #'private - accessing' }
Auth0UniversalLoginAuthenticationFilterTest >> secret [

	^ 'secret'
]

{ #category : #running }
Auth0UniversalLoginAuthenticationFilterTest >> setUp [

	| count |

	super setUp.
	count := 0.
	filter := Auth0UniversalLoginAuthenticationFilter
		at: self domain
		for: self clientId
		redirectingTo: self callbackURI
		nonceProvidedBy: [ count := count + 1. count ]
		JWSProvidedBy: [ :token :invalidAction | 
			[ JsonWebSignature materializeCompact: token key: self secret ]
				on: Error
				do: [ :error | error return: invalidAction value ]
			]
]

{ #category : #tests }
Auth0UniversalLoginAuthenticationFilterTest >> testGetWithSeasideSessionId [

	| response |

	requestContext := WARequestContext
		request: ( WARequest method: 'GET' uri: ( WARequest defaultUri addField: '_s' value: 666 ) )
		response: WABufferedResponse new.
	self
		use: self requestContext
		during: [ self requestContext handler addFilter: filter.
			response := self responseAfter: [ filter handleFiltered: self requestContext ].

			self assert: response status equals: 200
			]
]

{ #category : #tests }
Auth0UniversalLoginAuthenticationFilterTest >> testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint [

	| response redirectLocation |

	self requestContext handler addFilter: filter.
	response := self responseAfter: [ filter handleFiltered: self requestContext ].

	self assert: response status equals: 302.
	
	redirectLocation := ( response headerAt: 'Location' ) seasideUrl.

	self
		assert: redirectLocation isSsl;
		assert: redirectLocation host equals: self domain;
		assert: ( redirectLocation queryFields at: 'client_id' ) equals: self clientId;
		assert: ( redirectLocation queryFields at: 'redirect_uri' ) equals: self callbackURI;
		assert: ( redirectLocation queryFields at: 'scope' ) equals:  'openid email profile';
		assert: ( redirectLocation queryFields at: 'response_type' ) equals: 'token id_token';
		assert: ( redirectLocation queryFields at: 'response_mode' ) equals: 'form_post';
		assert: ( redirectLocation queryFields at: 'nonce' ) equals: 1
]

{ #category : #tests }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithSeasideSessionId [

	| response |

	requestContext := WARequestContext
		request: ( WARequest method: 'POST' uri: ( WARequest defaultUri addField: '_s' value: 666 ) )
		response: WABufferedResponse new.
	self
		use: self requestContext
		during: [ self requestContext handler addFilter: filter.
			response := self responseAfter: [ filter handleFiltered: self requestContext ].

			self assert: response status equals: 200
			]
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndInvalidAudience [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				expirationTime: DateAndTime tomorrow asUnixTime;
				audiences: 'https://invalid.example.com';
				issuer: self expectedIssuer;
				nonce: 1
			].

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndInvalidExpirationTime [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				expirationTime: DateAndTime yesterday asUnixTime;
				audiences: self clientId;
				issuer: self expectedIssuer;
				nonce: 1
			].

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndInvalidIssuer [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				expirationTime: DateAndTime tomorrow asUnixTime;
				audiences: self clientId;
				issuer: 'invalid';
				nonce: 1
			].

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndInvalidJWT [

	self testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint.

	requestContext := WARequestContext
		request:
			( ( WARequest method: 'POST' uri: WARequest defaultUri )
				setPostFields:
					( WARequestFields new
						at: 'state' put: 2;
						at: 'id_token' put: '';
						yourself ) )
		response: WABufferedResponse new.

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndInvalidNonce [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				expirationTime: DateAndTime tomorrow asUnixTime;
				audiences: self clientId;
				issuer: self expectedIssuer;
				nonce: 666
			].

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndInvalidState [

	self testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint.

	requestContext := WARequestContext
		request:
			( ( WARequest method: 'POST' uri: WARequest defaultUri )
				setPostFields:
					( WARequestFields new
						at: 'state' put: '999';
						yourself ) )
		response: WABufferedResponse new.

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndJWTBadlySigned [

	| jwt |

	self testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint.

	jwt := JsonWebSignature new
		algorithm: JWAHMACSHA256;
		payload:
			( JWTClaimsSet new
				expirationTime: DateAndTime tomorrow asUnixTime;
				audiences: self clientId;
				issuer: self expectedIssuer;
				nonce: 1;
				yourself );
		key: self secret reversed;
		compactSerialized.

	self receivePostRequestIncluding: jwt.

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndJWTMissingAudience [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				expirationTime: DateAndTime tomorrow asUnixTime;
				issuer: self expectedIssuer;
				nonce: 1
			].

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndJWTMissingExpirationTime [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				issuer: self expectedIssuer;
				audiences: self clientId;
				nonce: 1
			].

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndJWTMissingIssuer [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				expirationTime: DateAndTime tomorrow asUnixTime;
				audiences: self clientId;
				nonce: 1
			].

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndJWTMissingNonce [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				expirationTime: DateAndTime tomorrow asUnixTime;
				issuer: self expectedIssuer;
				audiences: self clientId
			].

	self assertResponseStatusIsForbiddenAfterRequestHasBeenHandledByTheFilter
]

{ #category : #tests }
Auth0UniversalLoginAuthenticationFilterTest >> testPostWithoutSeasideSessionIdAndValidJWT [

	self
		testGetWithoutSeasideSessionIdIsRedirectedToAuthorizeEndpoint;
		receivePostRequestIncludingJWTClaiming: [ :claims | 
			claims
				expirationTime: DateAndTime tomorrow asUnixTime;
				issuer: self expectedIssuer;
				audiences: self clientId;
				nonce: 1
			].

	self
		use: self requestContext
		during: [ | response |

			self requestContext handler addFilter: filter.
			response := self responseAfter: [ filter handleFiltered: self requestContext ].
			self assert: response status equals: 200
			]
]

{ #category : #'tests - forbidden cases' }
Auth0UniversalLoginAuthenticationFilterTest >> testUnexpectedRequestIsForbidden [

	| response |

	requestContext := WARequestContext
		request: ( WARequest method: 'PUT' uri: WARequest defaultUri )
		response: WABufferedResponse new.

	response := self responseAfter: [ filter handleFiltered: self requestContext ].

	self assertStatusIsForbidden: response
]

{ #category : #running }
Auth0UniversalLoginAuthenticationFilterTest >> use: aRequestContext during: aBlock [

	WACurrentRequestContext
		use: aRequestContext
		during: [ self pushAll: self createHandlers during: aBlock ]
]
