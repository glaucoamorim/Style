<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="descriptorBase" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
<head>

<regionBase>
	<region id="rg_lua" left="0" top="0" width="100%" height="100%" zIndex="1"/>
	<region id="rg_video" left="0" top="0" width="100%" height="100%" zIndex="1"/>
	<region id="rg_quiz" left="0" top="0" width="100%" height="100%" zIndex="2">
		<region id="rg_question" left="5%" top="10%" width="600" height="40" zIndex="3"/>
		<region id="rg_answer_01" left="10%" top="30%" width="180" height="20" zIndex="3"/>
		<region id="rg_answer_02" left="10%" top="40%" width="180" height="20" zIndex="3"/>
		<region id="rg_answer_03" left="10%" top="50%" width="180" height="20" zIndex="3"/>
		<region id="rg_answer_04" left="10%" top="60%" width="180" height="20" zIndex="3"/>
	</region>
</regionBase>

<descriptorBase>
	<descriptor id="dp_lua" region="rg_lua"/>
	<descriptor id="dp_video" region="rg_video"/>
	<descriptor id="dp_quiz" region="rg_quiz"/>
	<descriptor id="dp_question" region="rg_question"/>
	<descriptor id="dp_answer_01" region="rg_answer_01">
		<descriptorParam name="background" value="red"/>
	</descriptor>
	<descriptor id="dp_answer_02" region="rg_answer_02">
		<descriptorParam name="background" value="green"/>
	</descriptor>
	<descriptor id="dp_answer_03" region="rg_answer_03">
		<descriptorParam name="background" value="yellow"/>
	</descriptor>
	<descriptor id="dp_answer_04" region="rg_answer_04">
		<descriptorParam name="background" value="blue"/>
	</descriptor>
</descriptorBase>

</head>
</ncl>
