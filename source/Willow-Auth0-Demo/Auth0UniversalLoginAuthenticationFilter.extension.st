Extension { #name : #Auth0UniversalLoginAuthenticationFilter }

{ #category : #'*Willow-Auth0-Demo' }
Auth0UniversalLoginAuthenticationFilter >> useHTTPTransport [

	"This extension is only used for demo purposes so it can used locally
	without configuring certificates. It's not included in the Deployment
	group on purpose, so nobody can use an insecure scheme in production
	by mistake."

	scheme := 'http'
]
