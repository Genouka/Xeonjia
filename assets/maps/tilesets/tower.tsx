<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="1.9.0" name="tower" tilewidth="16" tileheight="16" tilecount="64" columns="8">
 <image source="../../images/tower.png" width="128" height="128"/>
 <tile id="0" class="Solid">
  <properties>
   <property name="action">(begin
  (dialog '((&quot;A cluster of gems.&quot;)))
  (if (get &quot;the-end&quot;)
    (dialog '((&quot;Is still here.&quot;)))))</property>
  </properties>
 </tile>
 <tile id="1" class="Solid"/>
 <tile id="2" class="Solid"/>
 <tile id="3" class="Solid"/>
 <tile id="4" class="Ground"/>
 <tile id="5" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock.&quot;)))"/>
  </properties>
 </tile>
 <tile id="6" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock.&quot;)))"/>
  </properties>
 </tile>
 <tile id="7" class="Ground"/>
 <tile id="8" class="Ground"/>
 <tile id="9" class="Solid"/>
 <tile id="10" class="Solid"/>
 <tile id="11" class="Solid"/>
 <tile id="16" class="Solid"/>
 <tile id="17" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;The tower is so ugly.&quot;)))"/>
  </properties>
 </tile>
 <tile id="18" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;The tower is so ugly.&quot;)))"/>
  </properties>
 </tile>
 <tile id="19" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;The tower is so ugly.&quot;)))"/>
  </properties>
 </tile>
 <tile id="20" class="Ground"/>
 <tile id="21" class="Solid"/>
 <tile id="22" class="Ground"/>
 <tile id="23" class="Ground"/>
 <tile id="24" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="25" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="26" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="27" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="28" class="Solid"/>
 <tile id="29" class="Solid"/>
 <tile id="30" class="Solid"/>
 <tile id="31" class="Solid"/>
 <tile id="32" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="33" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="34" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="35" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="36" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="37" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="38" class="Ground"/>
 <tile id="39" class="Ground"/>
 <tile id="40" class="Ground"/>
 <tile id="41" class="Ground"/>
 <tile id="42" class="Solid"/>
 <tile id="43" class="Solid"/>
 <tile id="44" class="Solid"/>
 <tile id="45" class="Solid"/>
 <tile id="46" class="Solid"/>
 <tile id="47" class="Solid"/>
 <tile id="48" class="Ground"/>
 <tile id="49" class="Solid"/>
 <tile id="50" class="Ground"/>
 <tile id="52" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="53" class="Solid"/>
 <tile id="54" class="Solid"/>
 <tile id="55" class="Solid"/>
 <tile id="56" class="NPC">
  <properties>
   <property name="name" value="king-of-evil"/>
  </properties>
 </tile>
 <tile id="57" class="NPC">
  <properties>
   <property name="name" value="king-of-evil"/>
   <property name="orientation" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="58" class="NPC">
  <properties>
   <property name="name" value="king-of-evil"/>
   <property name="orientation" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="59" class="NPC">
  <properties>
   <property name="name" value="king-of-evil"/>
   <property name="orientation" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="60" class="Solid"/>
 <tile id="61" class="Solid"/>
 <tile id="62" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="63" class="Solid"/>
</tileset>
