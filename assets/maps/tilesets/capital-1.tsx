<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="capital-1" tilewidth="16" tileheight="16" tilecount="32" columns="8">
 <image source="../../images/capital-1.png" width="128" height="64"/>
 <tile id="0" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="1" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="2" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="3" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="4" type="Solid"/>
 <tile id="5" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (begin
        (dialog-kobi '((&quot;Life always finds a way.&quot;)))
        (dialog '((&quot;/hero&quot; &quot;I don't know what this means.&quot;)))))</property>
  </properties>
 </tile>
 <tile id="6" type="Ground"/>
 <tile id="7" type="Ground"/>
 <tile id="8" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="9" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="10" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="11" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="12" type="Solid"/>
 <tile id="13" type="Solid"/>
 <tile id="14" type="Solid"/>
 <tile id="15" type="Solid"/>
 <tile id="16" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="17" type="Solid"/>
 <tile id="18" type="Solid"/>
 <tile id="19" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="20" type="Ground"/>
 <tile id="21" type="Ground"/>
 <tile id="22" type="Solid"/>
 <tile id="23" type="Solid"/>
 <tile id="29" type="Solid"/>
 <tile id="30" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;I can't go beyond this.&quot;)))"/>
  </properties>
 </tile>
</tileset>
