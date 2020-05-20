"
A WillowAuth0DemoTest is a test class for testing the behavior of WillowAuth0Demo
"
Class {
	#name : #WillowAuth0DemoTest,
	#superclass : #BWRenderingTest,
	#instVars : [
		'session'
	],
	#category : #'Willow-Auth0-Tests'
}

{ #category : #running }
WillowAuth0DemoTest >> createHandlers [

	| registry |

	session := WillowSession new.
	registry := WARegistry new
		cache:
			( WABulkReapingCache
				initialSize: 13
				maximumSize: 0
				maximumAbsoluteAge: 0
				maximumRelativeAge: 0
				overflowAction: WAHashCache signalError );
		yourself.
	session key: ( registry register: session ).
	^ Array with: registry with: session
]

{ #category : #tests }
WillowAuth0DemoTest >> testInitialRequest [

	| response |

	response := self responseAfter: [ WillowAuth0Demo new initialRequest: self requestContext request ].

	self assert: response status equals: 403
]

{ #category : #tests }
WillowAuth0DemoTest >> testLogoutFromAuth0 [

	| response redirectLocation |

	response := self
		responseAfter: [ | app |

			app := WillowAuth0Demo new.
			app session logoutFromAuth0: app
			].

	self assert: response status equals: 302.
	redirectLocation := ( response headerAt: 'Location' ) seasideUrl.

	self
		assert: redirectLocation isSsl;
		assert: redirectLocation host equals: WillowAuth0Demo authenticationDomain;
		assert: redirectLocation path asArray equals: #('v2' 'logout');
		assert: ( redirectLocation queryFields at: 'client_id' ) equals: WillowAuth0Demo clientId;
		assert: ( redirectLocation queryFields at: 'returnTo' ) equals: WillowAuth0Demo logoutReturnUrl
]

{ #category : #tests }
WillowAuth0DemoTest >> testRegistration [

	self should: [ WADispatcher default handlerAt: WillowAuth0Demo handlerName ] raise: WAError.

	[ WillowAuth0Demo registerAsDevelopmentApplication.
	self shouldnt: [ WADispatcher default handlerAt: WillowAuth0Demo handlerName ] raise: WAError
	]
		ensure: [ WillowAuth0Demo unregisterFromApplications ]
]

{ #category : #tests }
WillowAuth0DemoTest >> testRenderContentOn [

	| application html |

	application := WillowAuth0Demo new.
	session startUpApplicationContextFor: application.
	html := self render: application.

	self
		assert: html
		equals:
			'<h1>Wow! You''re now logged in.</h1><form accept-charset="utf-8" method="post" action="/"><button name="1" type="submit">Logout</button></form><h2>URI</h2><h2>POST fields</h2><dl></dl><h2>Query fields</h2><dl></dl><div id="willow-dialog-section" class="willow-dialog-container"></div><div id="willow-notification-section"></div>'
]
