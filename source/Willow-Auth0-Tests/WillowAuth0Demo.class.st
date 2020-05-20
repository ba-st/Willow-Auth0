"
I'm a demo Willow application.
For running I will need some environment variables available that can be obtained on the Auth0 Dashboard, for the Regular Web Application you must have created:
- WA0_DOMAIN : Domain 
- WA0_CLIENT_ID : Client ID
- WA0_CLIENT_SECRET : Client Secret
"
Class {
	#name : #WillowAuth0Demo,
	#superclass : #WillowApplicationAuthenticatedByAuth0UniversalLogin,
	#instVars : [
		'postFields',
		'queryFields',
		'uriPath'
	],
	#category : #'Willow-Auth0-Tests'
}

{ #category : #accessing }
WillowAuth0Demo class >> applicationTitle [
	
	^'Willow Auth0 - Demo Application'
]

{ #category : #private }
WillowAuth0Demo class >> authenticationCallbackURL [

	"This is a demo app, in a real scenario you will need a public URL and https"

	^ 'http://localhost:3000/<1s>' expandMacrosWith: self handlerName
]

{ #category : #private }
WillowAuth0Demo class >> authenticationDomain [

	^ OSEnvironment current
		at: 'WA0_DOMAIN'
		ifAbsent: [ Error signal: 'Missing required environment variable' ]
]

{ #category : #private }
WillowAuth0Demo class >> clientId [

	^ OSEnvironment current
		at: 'WA0_CLIENT_ID'
		ifAbsent: [ Error signal: 'Missing required environment variable' ]
]

{ #category : #accessing }
WillowAuth0Demo class >> handlerName [

	^'willow-auth0-demo'
]

{ #category : #private }
WillowAuth0Demo class >> jsonWebTokenSignatureAlgorithm [

	^JsonWebAlgorithm named: 'HS256'
]

{ #category : #private }
WillowAuth0Demo class >> logoutReturnUrl [

	^ 'http://localhost:3000/willow-auth0-demo'
]

{ #category : #private }
WillowAuth0Demo class >> materializeAndCheckSignatureOfJsonWebToken: tokenString [

	^ OSEnvironment current
		at: 'WA0_CLIENT_SECRET'
		ifPresent: [ :variable | 
			| jws |
			jws := JsonWebSignature materializeCompact: tokenString key: variable.
			variable atAllPut: Character null.
			jws
			]
		ifAbsent: [ Error signal: 'Missing required environment variable' ]
]

{ #category : #utility }
WillowAuth0Demo class >> start [

	<ignoreForCoverage>
	self registerAsDevelopmentApplication filter configuration
		at: #exceptionHandler
		put: WADebugErrorHandler.
	( ZnZincServerAdaptor port: 3000 )
		codec: GRPharoUtf8Codec new;
		start
]

{ #category : #utility }
WillowAuth0Demo class >> stop [

	<ignoreForCoverage>
	ZnServer stopDefault.
	ZnZincServerAdaptor allInstancesDo: [ :each | each shutDown ].
	self unregisterFromApplications.
	GRPlatform current seasideGarbageCollect
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
		renderJWTOn: html
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
WillowAuth0Demo >> renderJWTOn: html [

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
