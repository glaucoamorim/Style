<?xml version="1.0" encoding="ISO-8859-1"?>
  <ncl id="moveVideos" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
    <body xtemplate="mVideos">
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
              <bindParam value="$get" name="var"></bindParam>
            </bind>
        </link>
        <link xconnector="para">
            <bind interface="loc2" component="mlua" role="onEndAttribution">

            </bind>
            <bind interface="loc2" component="mlua" role="get">

            </bind>
            <bind interface="location" component="video2" role="set">
              <bindParam value="$get" name="var"></bindParam>
            </bind>
        </link>
        <link xconnector="para">
            <bind interface="loc3" component="mlua" role="onEndAttribution">

            </bind>
            <bind interface="loc3" component="mlua" role="get">

            </bind>
            <bind interface="location" component="video3" role="set">
              <bindParam value="$get" name="var"></bindParam>
            </bind>
        </link>
          <media layout="mVideos#videos" xlabel="video" id="video1" src="video.mp4">
            <property name="location"></property>
          </media>
          <media layout="mVideos#videos" xlabel="video" id="video2" src="video2.mp4">
            <property name="location"></property>
          </media>
          <media layout="mVideos#videos" xlabel="video" id="video3" src="video3.mp4">
            <property name="location"></property>
          </media>
          <media src="foo.lua" id="mlua">
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
    <head>
        <templateBase>
          <importBase documenturi="/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/StyleTemplateEx1.xml" alias="mVideos"></importBase>
        </templateBase>
    </head>
  </ncl>