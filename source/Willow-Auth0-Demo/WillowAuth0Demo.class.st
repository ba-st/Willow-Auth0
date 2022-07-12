"
I'm a demo Willow application.
"
Class {
	#name : #WillowAuth0Demo,
	#superclass : #WillowApplicationAuthenticatedByAuth0UniversalLogin,
	#instVars : [
		'postFields',
		'queryFields',
		'uriPath'
	],
	#category : #'Willow-Auth0-Demo'
}

{ #category : #accessing }
WillowAuth0Demo class >> applicationTitle [
	
	^'Willow Auth0 - Demo Application'
]

{ #category : #private }
WillowAuth0Demo class >> auth0Configuration [

	^ self configuration auth0
]

{ #category : #private }
WillowAuth0Demo class >> authenticationCallbackURL [

	^ self configuration publicURL
]

{ #category : #private }
WillowAuth0Demo class >> authenticationDomain [

	^ self auth0Configuration domain
]

{ #category : #private }
WillowAuth0Demo class >> clientId [

	^ self auth0Configuration clientId
]

{ #category : #private }
WillowAuth0Demo class >> configuration [

	^ CurrentApplicationConfiguration value
]

{ #category : #accessing }
WillowAuth0Demo class >> handlerName [

	^ 'willow-auth0-demo'
]

{ #category : #private }
WillowAuth0Demo class >> jsonWebTokenSignatureAlgorithm [

	^ JsonWebAlgorithm named: 'HS256'
]

{ #category : #private }
WillowAuth0Demo class >> logoutReturnUrl [

	^ self authenticationCallbackURL 
]

{ #category : #private }
WillowAuth0Demo class >> materializeAndCheckSignatureOfJsonWebToken: tokenString [

	^ JsonWebSignature materializeCompact: tokenString key: self auth0Configuration clientSecret
]

{ #category : #private }
WillowAuth0Demo class >> newAuthenticationFilter [

	| filter |

	filter := super newAuthenticationFilter.
	self auth0Configuration disableSecureTransport then: [ filter useHTTPTransport ].
	^ filter
]

{ #category : #accessing }
WillowAuth0Demo >> componentSupplierForApplication [

	^ Html5ComponentSupplier new
]

{ #category : #accessing }
WillowAuth0Demo >> contentView [

	^ [ :html | 
		html heading: 'Wow! You''re now logged in.'.
		self
			renderLogoutButtonOn: html;
			renderUriPathOn: html;
			renderPostFieldsOn: html;
			renderQueryFieldsOn: html;
			renderIdTokenOn: html;
			renderAccessTokenClaimsOn: html
		]
]

{ #category : #hooks }
WillowAuth0Demo >> initialRequest: request [

	super initialRequest: request.
	postFields := Dictionary newFrom: request postFields associations.
	queryFields := Dictionary newFrom: request queryFields associations.
	uriPath := request uri path.
]

{ #category : #initialization }
WillowAuth0Demo >> initialize [

	super initialize.
	uriPath := #().
	postFields := Dictionary new.
	queryFields := Dictionary new.
]

{ #category : #accessing }
WillowAuth0Demo >> jQueryLibrary [

	^ JQuery3OnlineLibrary default
]

{ #category : #rendering }
WillowAuth0Demo >> renderAccessTokenClaimsOn: html [

	postFields
		at: 'access_token'
		ifPresent: [ :token | 
			| jwt |
			html heading
				level: 2;
				with: 'Access Token Claims'.
			jwt := JsonWebSignature materializeCompact: token key: '' checkSignature: false.
			self renderDictionary: jwt payload claims asDefinitionListOn: html
			]
]

{ #category : #rendering }
WillowAuth0Demo >> renderDictionary: aDictionary asDefinitionListOn: html [

	html
		definitionList: [ aDictionary keys sorted
				do: [ :key | 
					html
						definitionTerm: key;
						definitionData: ( aDictionary at: key )
					]
			]
]

{ #category : #rendering }
WillowAuth0Demo >> renderIdTokenOn: html [

	postFields
		at: 'id_token'
		ifPresent: [ :token | 
			| jwt |
			html heading
				level: 2;
				with: 'JWT Claims'.
			jwt := self class materializeAndCheckSignatureOfJsonWebToken: token.
			self renderDictionary: jwt payload claims asDefinitionListOn: html
			]
]

{ #category : #rendering }
WillowAuth0Demo >> renderLogoutButtonOn: html [

	| button |

	button := self componentSupplier
		synchronicButtonLabeled: 'Logout'
		applying: [  ]
		evaluating: [ self session logoutFromAuth0: self ].
	html form: button
]

{ #category : #rendering }
WillowAuth0Demo >> renderPostFieldsOn: html [

	html heading
		level: 2;
		with: 'POST fields'.
	self renderDictionary: postFields asDefinitionListOn: html
]

{ #category : #rendering }
WillowAuth0Demo >> renderQueryFieldsOn: html [

	html heading
		level: 2;
		with: 'Query fields'.
	self renderDictionary: queryFields asDefinitionListOn: html
]

{ #category : #rendering }
WillowAuth0Demo >> renderUriPathOn: html [

	html heading
		level: 2;
		with: 'URI'.
	uriPath
		do: [ :path | html render: path ]
		separatedBy: [ html
				space;
				render: '/';
				space
			]
]
