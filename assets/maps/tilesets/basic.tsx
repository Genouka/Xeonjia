<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="1.9.0" name="basic" tilewidth="16" tileheight="16" tilecount="24" columns="8">
 <image source="../../images/basic.png" width="128" height="48"/>
 <tile id="0" class="DirectionChanger">
  <properties>
   <property name="forcedDirection" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="1" class="DirectionChanger">
  <properties>
   <property name="forcedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="2" class="DirectionChanger">
  <properties>
   <property name="forcedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="3" class="DirectionChanger">
  <properties>
   <property name="forcedDirection" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="8" class="Modifier"/>
 <tile id="9" class="Modifier"/>
 <tile id="10" class="Modifier"/>
 <tile id="11" class="Modifier">
  <properties>
   <property name="healthPointsDelta" type="int" value="25"/>
  </properties>
 </tile>
 <tile id="12" class="Modifier">
  <properties>
   <property name="healthPointsDelta" type="int" value="50"/>
  </properties>
  <animation>
   <frame tileid="12" duration="750"/>
   <frame tileid="13" duration="750"/>
  </animation>
 </tile>
 <tile id="13" class="Modifier">
  <properties>
   <property name="healthPointsDelta" type="int" value="100"/>
  </properties>
 </tile>
 <tile id="14" class="Ground">
  <properties>
   <property name="actionOnEvent" value="(if (get &quot;xxx&quot;) (delete-me))"/>
   <property name="hideable" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="15" class="Ground">
  <properties>
   <property name="actionOnEvent" value="(if (get &quot;xxx&quot;) (delete-me))"/>
   <property name="hideable" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="16" class="Modifier"/>
 <tile id="17" class="Modifier">
  <animation>
   <frame tileid="17" duration="500"/>
   <frame tileid="16" duration="500"/>
  </animation>
 </tile>
 <tile id="18" class="Modifier"/>
 <tile id="19" class="Modifier"/>
 <tile id="20" class="Modifier"/>
 <tile id="21" class="Modifier"/>
 <tile id="22" class="Ground">
  <properties>
   <property name="actionOnEvent" value="(if (get &quot;xxx&quot;) (delete-me))"/>
   <property name="hideable" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="23" class="Ground">
  <properties>
   <property name="actionOnEvent" value="(if (get &quot;xxx&quot;) (delete-me))"/>
   <property name="hideable" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
</tileset>
