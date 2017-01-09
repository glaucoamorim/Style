<?xml version="1.0" encoding="ISO-8859-1"?>
  <ncl id="moveVideos" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
    <head>
      <templateBase>
        <importBase documenturi="/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/StyleTemplateEx1.xml" alias="mVideos"></importBase>
      </templateBase>
    </head>
    <body xtemplate="mVideos">
          <media xlabel="video" layout="mVideos#videos" src="video.mp4" id="video1">
            <property name="location"></property>
          </media>
          <media xlabel="video" layout="mVideos#videos" src="video2.mp4" id="video2">
            <property name="location"></property>
          </media>
          <media xlabel="video" layout="mVideos#videos" src="video3.mp4" id="video3">
            <property name="location"></property>
          </media>
          <media id="mlua" src="foo.lua">
              <area id="arj1">

              </area>
              <area id="arj2">

              </area>
              <area id="arj3">

              </area>
                <property name="loc1">

                </property>
                <property name="loc2">

                </property>
                <property name="loc3">

                </property>
          </media>
            <link xconnector="onBeginStart">
                <bind component="video1" role="onBegin">

                </bind>
                <bind component="mlua" role="start" interface="arj1">

                </bind>
            </link>
            <link xconnector="onEndStop">
                <bind component="video1" role="onEnd">

                </bind>
                <bind component="mlua" role="stop" interface="arj1">

                </bind>
            </link>
            <link xconnector="onBeginStart">
                <bind component="video2" role="onBegin">

                </bind>
                <bind component="mlua" role="start" interface="arj2">

                </bind>
            </link>
            <link xconnector="onEndStop">
                <bind component="video2" role="onEnd">

                </bind>
                <bind component="mlua" role="stop" interface="arj2">

                </bind>
            </link>
            <link xconnector="onBeginStart">
                <bind component="video3" role="onBegin">

                </bind>
                <bind component="mlua" role="start" interface="arj3">

                </bind>
            </link>
            <link xconnector="onEndStop">
                <bind component="video3" role="onEnd">

                </bind>
                <bind component="mlua" role="stop" interface="arj3">

                </bind>
            </link>
            <link xconnector="para">
                <bind component="mlua" role="onEndAttribution" interface="loc1">

                </bind>
                <bind component="mlua" role="get" interface="loc1">

                </bind>
                <bind component="video1" role="set" interface="location">
                  <bindParam name="var" value="$get"></bindParam>
                </bind>
            </link>
            <link xconnector="para">
                <bind component="mlua" role="onEndAttribution" interface="loc2">

                </bind>
                <bind component="mlua" role="get" interface="loc2">

                </bind>
                <bind component="video2" role="set" interface="location">
                  <bindParam name="var" value="$get"></bindParam>
                </bind>
            </link>
            <link xconnector="para">
                <bind component="mlua" role="onEndAttribution" interface="loc3">

                </bind>
                <bind component="mlua" role="get" interface="loc3">

                </bind>
                <bind component="video3" role="set" interface="location">
                  <bindParam name="var" value="$get"></bindParam>
                </bind>
            </link>
    </body>
  </ncl>