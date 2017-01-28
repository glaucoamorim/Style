<?xml version="1.0" encoding="ISO-8859-1"?>
  <ncl xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile" id="moveVideos">
    <head>
      <templateBase>
        <importBase alias="mVideos" documenturi="/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/StyleTemplateEx1.xml"></importBase>
      </templateBase>
    </head>
    <body xtemplate="mVideos">
          <link xconnector="onBeginStart">
              <bind component="video1" role="onBegin">

              </bind>
              <bind component="mlua" interface="area1" role="start">

              </bind>
          </link>
          <link xconnector="onEndStop">
              <bind component="video1" role="onEnd">

              </bind>
              <bind component="mlua" interface="area1" role="stop">

              </bind>
          </link>
          <link xconnector="onBeginStart">
              <bind component="video2" role="onBegin">

              </bind>
              <bind component="mlua" interface="area2" role="start">

              </bind>
          </link>
          <link xconnector="onEndStop">
              <bind component="video2" role="onEnd">

              </bind>
              <bind component="mlua" interface="area2" role="stop">

              </bind>
          </link>
          <link xconnector="onBeginStart">
              <bind component="video3" role="onBegin">

              </bind>
              <bind component="mlua" interface="area3" role="start">

              </bind>
          </link>
          <link xconnector="onEndStop">
              <bind component="video3" role="onEnd">

              </bind>
              <bind component="mlua" interface="area3" role="stop">

              </bind>
          </link>
          <link xconnector="para">
              <bind component="mlua" interface="loc1" role="onEndAttribution">

              </bind>
              <bind component="mlua" interface="loc1" role="get">

              </bind>
              <bind component="video1" interface="location" role="set">
                <bindParam name="var" value="$get"></bindParam>
              </bind>
          </link>
          <link xconnector="para">
              <bind component="mlua" interface="loc2" role="onEndAttribution">

              </bind>
              <bind component="mlua" interface="loc2" role="get">

              </bind>
              <bind component="video2" interface="location" role="set">
                <bindParam name="var" value="$get"></bindParam>
              </bind>
          </link>
          <link xconnector="para">
              <bind component="mlua" interface="loc3" role="onEndAttribution">

              </bind>
              <bind component="mlua" interface="loc3" role="get">

              </bind>
              <bind component="video3" interface="location" role="set">
                <bindParam name="var" value="$get"></bindParam>
              </bind>
          </link>
            <media src="video.mp4" layout="mVideos#videos" xlabel="video" id="video1">
              <property name="location"></property>
            </media>
            <media src="video2.mp4" layout="mVideos#videos" xlabel="video" id="video2">
              <property name="location"></property>
            </media>
            <media src="video3.mp4" layout="mVideos#videos" xlabel="video" id="video3">
              <property name="location"></property>
            </media>
            <media id="mlua" src="foo.lua">
                <property name="loc1">

                </property>
                <property name="loc2">

                </property>
                <property name="loc3">

                </property>
                  <area id="area1">

                  </area>
                  <area id="area2">

                  </area>
                  <area id="area3">

                  </area>
            </media>
    </body>
  </ncl>