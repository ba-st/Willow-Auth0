"
Metacello Baseline definition for Willow-Auth0
"
Class {
	#name : #BaselineOfWillowAuth0,
	#superclass : #BaselineOf,
	#category : #BaselineOfWillowAuth0
}

{ #category : #baselines }
BaselineOfWillowAuth0 >> baseline: spec [

	<baseline>
	spec for: #pharo do: [ 
		self
			setUpDependencies: spec;
			setUpPackages: spec.
		spec
			group: 'CI' with: 'Tests';
			group: 'Dependent-SUnit-Extensions' with: 'Willow-SUnit';
			group: 'Tools' with: 'Willow-Tools';
			group: 'Development' with: #( 'Tests' 'Demo' )
		]
]

{ #category : #accessing }
BaselineOfWillowAuth0 >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #initialization }
BaselineOfWillowAuth0 >> setUpDependencies: spec [

	spec
		baseline: 'Willow' with: [ spec repository: 'github://ba-st/Willow:v15' ];
		project: 'Willow-Deployment' copyFrom: 'Willow' with: [ spec loads: 'Deployment' ];
		project: 'Willow-SUnit' copyFrom: 'Willow' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Willow-Tools' copyFrom: 'Willow' with: [ spec loads: 'Tools' ].

	spec
		baseline: 'JSONWebToken' with: [ spec repository: 'github://noha/JSONWebToken:0.3/source' ];
		project: 'JSONWebToken-Deployment' copyFrom: 'JSONWebToken' with: [ spec loads: 'Core' ].

	spec
		baseline: 'Launchpad' with: [ spec repository: 'github://ba-st/Launchpad:v4' ];
		project: 'Launchpad-Deployment' copyFrom: 'Launchpad' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'Hyperspace' with: [ spec repository: 'github://ba-st/Hyperspace:v4' ];
		project: 'Hyperspace-SUnit'
		copyFrom: 'Hyperspace'
		with: [ spec loads: 'Dependent-SUnit-Extensions' ]
]

{ #category : #initialization }
BaselineOfWillowAuth0 >> setUpPackages: spec [

	spec
		package: 'Willow-Auth0'
		with: [ spec requires: #( 'Willow-Deployment' 'JSONWebToken-Deployment' ) ];
		group: 'Deployment' with: 'Willow-Auth0';
		package: 'Willow-Auth0-Tests'
		with: [ spec requires: #( 'Willow-Auth0' 'Willow-Tools' 'Willow-SUnit' ) ];
		group: 'Tests' with: 'Willow-Auth0-Tests'.

	spec
		package: 'Willow-Auth0-Demo' with: [ spec requires: #( 'Willow-Auth0' 'Launchpad-Deployment' ) ];
		group: 'Demo' with: 'Willow-Auth0-Demo';
		package: 'Willow-Auth0-Demo-Tests'
		with: [ spec requires: #( 'Willow-Auth0-Demo' 'Willow-SUnit' 'Hyperspace-SUnit' ) ];
		group: 'Tests' with: 'Willow-Auth0-Demo-Tests'
]
