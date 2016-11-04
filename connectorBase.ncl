<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="connectorBase" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
<head>
<connectorBase>
	
	<causalConnector id="onBeginStart">
		<simpleCondition role="onBegin"/>
		<simpleAction role="start" max="unbounded" qualifier="par"/>
	</causalConnector>
	
	<causalConnector id="onEndStop">
		<simpleCondition role="onEnd"/>
		<simpleAction role="stop" max="unbounded" qualifier="par"/>
	</causalConnector>
	
	<!-- Key Pressed and Element never Presented, Start -->
	<causalConnector id="onFirstKeySelectionStart">
		<connectorParam name="keyCode"/>
		<compoundCondition operator="and">
			<simpleCondition role="onSelection" key="$keyCode"/>
			<assessmentStatement comparator="eq">
				<attributeAssessment role="occurrences" eventType="presentation" attributeType="occurrences"/>
				<valueAssessment value="0"/>
			</assessmentStatement>
		</compoundCondition>
		<simpleAction role="start" max="unbounded" qualifier="par"/>
	</causalConnector>
	
	<!-- Key Pressed and Element is Presenting, Stop, Set, Start -->
	<causalConnector id="onKeySelectionPresentingStopSetStart">
		<connectorParam name="keyCode" />
		<connectorParam name="var"/>
		<compoundCondition operator="and">
			<simpleCondition role="onSelection" key="$keyCode"/>
			<assessmentStatement comparator="eq">
				<attributeAssessment role="isPresenting" eventType="presentation" attributeType="state"/>
				<valueAssessment value="occurring"/>
			</assessmentStatement>
		</compoundCondition>
		<compoundAction operator="seq">
			<simpleAction role="stop" min="0" max="unbounded" qualifier="par"/>
			<simpleAction role="set" value="$var" min="0" max="unbounded" qualifier="par"/>
			<simpleAction role="start" min="0" max="unbounded" qualifier="par"/>
		</compoundAction>
	</causalConnector>
	
	<!-- Element ending presentation and Value greater than or equal, Stop, Start -->
	<causalConnector id="onEndTestGTEStopStart">
		<connectorParam name="var"/>
		<compoundCondition operator="and">
			<simpleCondition role="onEnd"/>
			<assessmentStatement comparator="gte">
				<attributeAssessment role="test" eventType="attribution" attributeType="nodeProperty"/>
				<valueAssessment value="$var"/>
			</assessmentStatement>
		</compoundCondition>
		<compoundAction operator="seq">
			<simpleAction role="stop" max="unbounded" qualifier="par"/>
			<simpleAction role="start" max="unbounded" qualifier="par"/>
		</compoundAction>
	</causalConnector>
	
	<!-- Element ending presentation and Value less than or equal, Stop, Start -->
	<causalConnector id="onEndTestLTStopStart">
		<connectorParam name="var"/>
		<compoundCondition operator="and">
			<simpleCondition role="onEnd"/>
			<assessmentStatement comparator="lt">
				<attributeAssessment role="test" eventType="attribution" attributeType="nodeProperty"/>
				<valueAssessment value="$var"/>
			</assessmentStatement>
		</compoundCondition>
		<compoundAction operator="seq">
			<simpleAction role="stop" max="unbounded" qualifier="par"/>
			<simpleAction role="start" max="unbounded" qualifier="par"/>
		</compoundAction>
	</causalConnector>
		
</connectorBase>
</head>
</ncl>
