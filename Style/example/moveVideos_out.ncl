<?xml version="1.0" encoding="ISO-8859-1"?>
  <ncl id="moveVideos" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
    <head>
      <templateBase>
        <importBase alias="mVideos" documenturi="/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/StyleTemplateEx1.xml"></importBase>
      </templateBase>
    </head>
    <body xtemplate="mVideos">
          <media src="video.mp4" item="item1" layout="mVideos#videos" xlabel="video" id="video1">
            <property name="location"></property>
          </media>
          <media src="video2.mp4" item="item2" layout="mVideos#videos" xlabel="video" id="video2">
            <property name="location"></property>
          </media>
          <media src="video3.mp4" item="item1" layout="mVideos#videos" xlabel="video" id="video3">
            <property name="location"></property>
          </media>
          <media id="mlua" src="foo.lua">
              <area id="area1">

              </area>
              <area id="area2">

              </area>
              <area id="area3">

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
                <bind interface="area1" component="mlua" role="start">

                </bind>
            </link>
            <link xconnector="onEndStop">
                <bind component="video1" role="onEnd">

                </bind>
                <bind interface="area1" component="mlua" role="stop">

                </bind>
            </link>
            <link xconnector="onBeginStart">
                <bind component="video2" role="onBegin">

                </bind>
                <bind interface="area2" component="mlua" role="start">

                </bind>
            </link>
            <link xconnector="onEndStop">
                <bind component="video2" role="onEnd">

                </bind>
                <bind interface="area2" component="mlua" role="stop">

                </bind>
            </link>
            <link xconnector="onBeginStart">
                <bind component="video3" role="onBegin">

                </bind>
                <bind interface="area3" component="mlua" role="start">

                </bind>
            </link>
            <link xconnector="onEndStop">
                <bind component="video3" role="onEnd">

                </bind>
                <bind interface="area3" component="mlua" role="stop">

                </bind>
            </link>
            <link xconnector="para">
                <bind interface="loc1" component="mlua" role="onEndAttribution">

                </bind>
                <bind interface="loc1" component="mlua" role="get">

                </bind>
                <bind interface="location" component="video1" role="set">
                  <bindParam name="var" value="$get"></bindParam>
                </bind>
            </link>
            <link xconnector="para">
                <bind interface="loc2" component="mlua" role="onEndAttribution">

                </bind>
                <bind interface="loc2" component="mlua" role="get">

                </bind>
                <bind interface="location" component="video2" role="set">
                  <bindParam name="var" value="$get"></bindParam>
                </bind>
            </link>
            <link xconnector="para">
                <bind interface="loc3" component="mlua" role="onEndAttribution">

                </bind>
                <bind interface="loc3" component="mlua" role="get">

                </bind>
                <bind interface="location" component="video3" role="set">
                  <bindParam name="var" value="$get"></bindParam>
                </bind>
            </link>
    </body>
  </ncl>