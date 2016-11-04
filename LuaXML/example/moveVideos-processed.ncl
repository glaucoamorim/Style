<?xml version="1.0" encoding="UTF-8"?>
<!-- Powered by XTemplate. -->
<ncl id="moveVideos-processed" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
	<head>
		<connectorBase>
			<importBase alias="connectors" documentURI="connectorBase.ncl"/>
		</connectorBase>
		<regionBase/>
		<descriptorBase>
			<importBase alias="descriptors" documentURI="descriptorBase.ncl"/>
		</descriptorBase>
		<ruleBase/>
	</head>
	<body>
		<media descriptor="descriptors#dp_video" id="video1" src="video.mp4"/>
		<media descriptor="descriptors#dp_video" id="video2" src="video.mp4"/>
		<media descriptor="descriptors#dp_video" id="video3" src="video.mp4"/>
		<media descriptor="dtmp" id="temp" src="pin.png"/>
		<media descriptor="descriptors#dp_lua" id="mlua" src="foo.lua" type="application/x-ginga-NCLua">
			<area id="area" select="child::*[@xlabel='video']"/>
			<area id="property" select="child::*[@xlabel='video']"/>
		</media>
		<port component="video1" id="port1"/>
		<port component="mlua" id="port2"/>
	</body>
</ncl>
