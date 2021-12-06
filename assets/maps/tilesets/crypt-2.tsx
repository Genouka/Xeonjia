<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="crypt-2" tilewidth="16" tileheight="16" tilecount="56" columns="8">
 <image source="../../images/crypt-2.png" width="128" height="112"/>
 <tile id="0" type="Ground"/>
 <tile id="1" type="Ground"/>
 <tile id="2" type="Ground"/>
 <tile id="3" type="Ground"/>
 <tile id="4" type="Ground"/>
 <tile id="5" type="Ground"/>
 <tile id="6" type="Ground"/>
 <tile id="7" type="Solid"/>
 <tile id="8" type="Ground"/>
 <tile id="9" type="Ground"/>
 <tile id="10" type="Ground"/>
 <tile id="11" type="Ground"/>
 <tile id="12" type="Ground"/>
 <tile id="13" type="Ground"/>
 <tile id="14" type="Ground"/>
 <tile id="15" type="Solid"/>
 <tile id="16" type="Ground"/>
 <tile id="17" type="Ground"/>
 <tile id="18" type="Ground"/>
 <tile id="19" type="Ground"/>
 <tile id="20" type="Ground"/>
 <tile id="21" type="Ground"/>
 <tile id="22" type="Ground"/>
 <tile id="23" type="Solid">
  <animation>
   <frame tileid="23" duration="1000"/>
   <frame tileid="31" duration="1000"/>
  </animation>
 </tile>
 <tile id="24" type="Ground"/>
 <tile id="25" type="Ground"/>
 <tile id="26" type="Ground"/>
 <tile id="27" type="Ground"/>
 <tile id="28" type="Ground"/>
 <tile id="29" type="Ground"/>
 <tile id="31" type="Solid"/>
 <tile id="32" type="Solid"/>
 <tile id="33" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="34" type="Solid"/>
 <tile id="35" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="36" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="37" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="38" type="Solid"/>
 <tile id="39" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock covered by moss.&quot;)))"/>
   <property name="atk" type="int" value="5"/>
  </properties>
 </tile>
 <tile id="40" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 3)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="41" type="Ground"/>
 <tile id="42" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 2)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="43" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="44" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="45" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="46" type="Solid"/>
 <tile id="47" type="Solid"/>
 <tile id="48" type="Solid"/>
 <tile id="49" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="50" type="Solid"/>
 <tile id="51" type="Solid"/>
 <tile id="52" type="Solid"/>
 <tile id="55" type="Solid">
  <properties>
   <property name="action">(if (has-weapon 1)
    (if (max-pp-snowballs)
        (dialog '((&quot;The snowballs container is full.&quot;))))
    (dialog '((&quot;A snowdrift.&quot;))))</property>
  </properties>
 </tile>
</tileset>
