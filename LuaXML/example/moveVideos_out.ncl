<?xml version="1.0" encoding="ISO-8859-1"?>
  <ncl id="moveVideos" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
    <head>
      <templateBase>
        <importBase documenturi="/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/StyleTemplateEx1.xml" alias="mVideos"></importBase>
      </templateBase>
    </head>
    <body xtemplate="mVideos">
          <media xlabel="video" id="video1" src="video.mp4" layout="mVideos#videos">
            <property name="location"></property>
          </media>
          <media xlabel="video" id="video2" src="video2.mp4" layout="mVideos#videos">
            <property name="location"></property>
          </media>
          <media xlabel="video" id="video3" src="video3.mp4" layout="mVideos#videos">
            <property name="location"></property>
          </media>
          <media src="foo.lua" id="mlua">
              <property name="loc1">

              </property>
              <property name="loc2">

              </property>
              <property name="loc3">

              </property>
                <area id="arj1">

                </area>
                <area id="arj2">

                </area>
                <area id="arj3">

                </area>
          </media>
    </body>
  </ncl>