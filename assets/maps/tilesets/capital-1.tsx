<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="1.9.0" name="capital-1" tilewidth="16" tileheight="16" tilecount="32" columns="8">
 <image source="../../images/capital-1.png" width="128" height="64"/>
 <tile id="0" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="1" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="2" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="3" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="4" class="Solid"/>
 <tile id="5" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
  (begin
    (dialog-kobi '((&quot;Life always finds a way&quot;)))
    (dialog '((&quot;/hero&quot; &quot;I don't know what this means.&quot;)))))</property>
  </properties>
 </tile>
 <tile id="6" class="Ground"/>
 <tile id="7" class="Ground"/>
 <tile id="8" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="9" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="10" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="11" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="12" class="Solid"/>
 <tile id="13" class="Solid"/>
 <tile id="14" class="Solid"/>
 <tile id="15" class="Solid"/>
 <tile id="16" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="17" class="Solid"/>
 <tile id="18" class="Solid"/>
 <tile id="19" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="20" class="Ground"/>
 <tile id="21" class="Ground"/>
 <tile id="22" class="Solid"/>
 <tile id="23" class="Solid"/>
 <tile id="29" class="Solid"/>
 <tile id="30" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;I can't go beyond this.&quot;)))"/>
  </properties>
 </tile>
</tileset>
