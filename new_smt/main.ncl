<ncl>
    <head>
        <regionBase>
            <region id='rrj' top='0'  left='0' width='240' height='135'/>
            <region id='rpr' top='0'  left='0' width='160' height='90'/>
            <region id='rtr' top='0'  left='0' width='80' height='53'/>
            <region id='rtmp' bottom='0'  right='0' width='30' height='30'/>
        </regionBase>
        
        <descriptorBase>
            <descriptor id='drj' region='rrj' explicitDur='6s'>
                <descriptorParam name='soundLevel' value='0'/>
            </descriptor>
            <descriptor id='dpr' region='rpr' explicitDur='6s'>
                <descriptorParam name='soundLevel' value='0'/>
            </descriptor>
            <descriptor id='dtr' region='rtr' explicitDur='6s'>
                <descriptorParam name='soundLevel' value='0'/>
            </descriptor>
            <descriptor id='dtmp' region='rtmp' explicitDur='12s'/>
        </descriptorBase>
        
        <connectorBase>
            <causalConnector id='onBeginStart'>
                <simpleCondition role='onBegin'/>
                <simpleAction role='start'/>
            </causalConnector>
            
            <causalConnector id='onEndStop'>
                <simpleCondition role='onEnd'/>
                <simpleAction role='stop'/>
            </causalConnector>

            <causalConnector id='para'>
                <connectorParam name='var'/>
                <simpleCondition role='onEndAttribution'/>
                <simpleAction role='set' value='$var'/>
            </causalConnector>
            
            <causalConnector id='delayedStart'>
                <simpleCondition role='onBegin'/>
                <simpleAction role='start' delay='2s'/>
            </causalConnector>
			
			<causalConnector id="onBeginStartNSetN">
				<connectorParam name="var"/>
				<simpleCondition role="onBegin"/>
				<compoundAction operator="seq">
					<simpleAction role="star" max="unbounded" qualifier="par"/>
					<simpleAction role="set" value="$var" max="unbounded" qualifier="par"/>
				</compoundAction>
			</causalConnector>
			
			<causalConnector id="onEndStopNSetN">
				<connectorParam name="var"/>
				<simpleCondition role="onEnd"/>
				<compoundAction operator="seq">
					<simpleAction role="stop" max="unbounded" qualifier="par"/>
					<simpleAction role="set" value="$var" max="unbounded" qualifier="par"/>
				</compoundAction>
			</causalConnector>
        </connectorBase>
    </head>
    
    <body>
        <port id='p1' component='mlua'/>
        <port id='p2' component='imgRJ'/>
        <port id='p5' component='temp'/>

        <media id='mlua' src='foo.lua'>
            <area id='arj'/>
            <area id='apr'/>
            <area id='atr'/>
            <property name='event'/>
			<property name='result'/>
        </media>
        
        <!-- <media id='imgRJ' src='imgRJ.png' descriptor='drj'> -->
        <media id='imgRJ' src='videoRJ.mp4' descriptor='drj'>
            <property name='location'/>
        </media>
        
        <!-- <media id='imgPR' src='imgPR.png' descriptor='dpr'> -->
        <media id='imgPR' src='videoPR.mp4' descriptor='dpr'>
            <property name='location'/>
        </media>
        
        <!-- <media id='imgTR' src='imgTR.png' descriptor='dtr'> -->
        <media id='imgTR' src='videoTR.mp4' descriptor='dtr'>
            <property name='location'/>
        </media>
        
        <media id='temp' src='pin.png' descriptor='dtmp'/>
        
        <link xconnector='delayedStart'>
            <bind role='onBegin' component='imgRJ'/>
            <bind role='start' component='imgPR'/>
        </link>
        <link xconnector='delayedStart'>
            <bind role='onBegin' component='imgPR'/>
            <bind role='start' component='imgTR'/>
        </link>
        
        <link xconnector='onBeginStartNSetN'>
            <bind role='onBegin' component='imgRJ'/>
            <bind role='start' component='mlua' interface='arj'/>
			<bind role='set' component='mlua' interface='event'>
				<bindParam name='var' value='imgRJ.start'/>
			</bind>
        </link>
        
        <link xconnector='onBeginStartNSetN'>
            <bind role='onBegin' component='imgPR'/>
            <bind role='start' component='mlua' interface='apr'/>
			<bind role='set' component='mlua' interface='event'>
				<bindParam name='var' value='imgPR.start'/>
			</bind>
        </link>
		
        <link xconnector='onBeginStartNSetN'>
            <bind role='onBegin' component='imgTR'/>
            <bind role='start' component='mlua' interface='atr'/>
			<bind role='set' component='mlua' interface='event'>
				<bindParam name='var' value='imgTR.start'/>
			</bind>
        </link>
        
		
        <link xconnector='onEndStopNSetN'>
            <bind role='onEnd' component='imgRJ'/>
            <bind role='stop' component='mlua' interface='arj'/>
			<bind role='set' component='mlua' interface='event'>
				<bindParam name='var' value='imgRJ.stop'/>
			</bind>
        </link>
        
		<link xconnector='onEndStop'>
            <bind role='onBegin' component='imgPR'/>
            <bind role='start' component='mlua' interface='apr'/>
			<bind role='set' component='mlua' interface='event'>
				<bindParam name='var' value='imgPR.stop'/>
			</bind>
        </link>
        
		<link xconnector='onEndStop'>
            <bind role='onBegin' component='imgTR'/>
            <bind role='start' component='mlua' interface='atr'/>
			<bind role='set' component='mlua' interface='event'>
				<bindParam name='var' value='imgTR.stop'/>
			</bind>
        </link>
        
		<link xconnector='onEndStop'>
            <bind role='onEnd' component='temp'/>
            <bind role='stop' component='mlua'/>
        </link>
        
        
        <link xconnector='para'>
            <bind role='onEndAttribution' component='mlua' interface='locrj'/>
            <bind role='get' component='mlua' interface='loc'/>
            <bind role='set' component='imgRJ' interface='location'>
                <bindParam name='var' value='$get'/>
            </bind>
        </link>
        <link xconnector='para'>
            <bind role='onEndAttribution' component='mlua' interface='locpr'/>
            <bind role='get' component='mlua' interface='loc'/>
            <bind role='set' component='imgPR' interface='location'>
                <bindParam name='var' value='$get'/>
            </bind>
        </link>
        <link xconnector='para'>
            <bind role='onEndAttribution' component='mlua' interface='loctr'/>
            <bind role='get' component='mlua' interface='loc'/>
            <bind role='set' component='imgTR' interface='location'>
                <bindParam name='var' value='$get'/>
            </bind>
        </link>
    </body>
</ncl>