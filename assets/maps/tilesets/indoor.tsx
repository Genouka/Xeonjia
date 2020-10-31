<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.4" tiledversion="2020.08.05" name="indoor" tilewidth="16" tileheight="16" tilecount="48" columns="8">
 <image source="../../images/indoor.png" width="128" height="96"/>
 <tile id="0" type="Ground"/>
 <tile id="1" type="Solid"/>
 <tile id="2" type="Solid"/>
 <tile id="3" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;&gt;&quot; &quot;A painting that depicts this area long ago.&quot;)))"/>
  </properties>
 </tile>
 <tile id="4" type="Solid"/>
 <tile id="5" type="Solid"/>
 <tile id="6" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;&gt;&quot; &quot;This type of plants resists the cold well.&quot;)))"/>
  </properties>
 </tile>
 <tile id="7" type="Ground"/>
 <tile id="8" type="Solid"/>
 <tile id="9" type="Solid"/>
 <tile id="10" type="Solid"/>
 <tile id="11" type="Solid"/>
 <tile id="12" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;&gt;&quot; &quot;It's full of books here.&quot;)))"/>
  </properties>
 </tile>
 <tile id="13" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;&gt;&quot; &quot;It's full of books here.&quot;)))"/>
  </properties>
 </tile>
 <tile id="14" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="15" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="16" type="Ground"/>
 <tile id="17" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;&gt;&quot; &quot;A closed door.&quot;)))"/>
  </properties>
 </tile>
 <tile id="18" type="Solid"/>
 <tile id="19" type="Solid"/>
 <tile id="20" type="Solid"/>
 <tile id="21" type="Solid"/>
 <tile id="22" type="Solid"/>
 <tile id="23" type="Solid"/>
 <tile id="24" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="25" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="26" type="Solid"/>
 <tile id="27" type="Solid"/>
 <tile id="28" type="Solid"/>
 <tile id="30" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="31" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="32" type="Ground"/>
 <tile id="33" type="Solid"/>
 <tile id="34" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;&gt;&quot; &quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="35" type="Solid"/>
 <tile id="36" type="Solid"/>
 <tile id="39" type="Solid">
  <properties>
   <property name="action">(dialog
    '((&quot;&gt;&quot; &quot;Oink !&quot;)
    (&quot;/hero_happy&quot; &quot;This pig looks very happy.&quot;)))</property>
  </properties>
 </tile>
 <tile id="40" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="42" type="Solid"/>
 <tile id="43" type="Solid"/>
 <tile id="44" type="Solid"/>
</tileset>
