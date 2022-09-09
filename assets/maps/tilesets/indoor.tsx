<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="1.9.0" name="indoor" tilewidth="16" tileheight="16" tilecount="56" columns="8">
 <image source="../../images/indoor.png" width="128" height="112"/>
 <tile id="0" class="Ground"/>
 <tile id="1" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;The weather is good today.&quot;)))"/>
  </properties>
 </tile>
 <tile id="2" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A chair.&quot;)))"/>
  </properties>
 </tile>
 <tile id="3" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A painting that depicts this area long ago.&quot;)))"/>
  </properties>
 </tile>
 <tile id="4" class="Solid"/>
 <tile id="5" class="Solid"/>
 <tile id="6" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This plant is very fragrant.&quot;)))"/>
  </properties>
 </tile>
 <tile id="7" class="Ground"/>
 <tile id="8" class="Solid"/>
 <tile id="9" class="Solid"/>
 <tile id="10" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="11" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="12" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;It's full of books here.&quot;))))</property>
  </properties>
 </tile>
 <tile id="13" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;It's full of books here.&quot;))))</property>
  </properties>
 </tile>
 <tile id="14" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="15" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="16" class="Ground"/>
 <tile id="17" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A closed door.&quot;)))"/>
  </properties>
 </tile>
 <tile id="18" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="19" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="20" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
    (dialog '((&quot;There is some food between the mattresses of this sofa.&quot;))))</property>
  </properties>
 </tile>
 <tile id="21" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
    (dialog '((&quot;There is some food between the mattresses of this sofa.&quot;))))</property>
  </properties>
 </tile>
 <tile id="22" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
  (dialog '((&quot;A television.&quot;))))</property>
  </properties>
 </tile>
 <tile id="23" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
  (dialog '((&quot;A television.&quot;))))</property>
  </properties>
 </tile>
 <tile id="24" class="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="25" class="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="26" class="Solid"/>
 <tile id="27" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="28" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="29" class="Solid"/>
 <tile id="30" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="31" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="32" class="Ground"/>
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
 <tile id="37" class="Solid"/>
 <tile id="38" class="Solid"/>
 <tile id="39" class="Solid">
  <properties>
   <property name="action">(dialog
    '((&quot;Oink !&quot;)
    (&quot;/hero_happy&quot; &quot;This pig looks very happy.&quot;)))</property>
  </properties>
 </tile>
 <tile id="40" class="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="41" class="Solid"/>
 <tile id="42" class="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="43" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="44" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="45" class="Solid"/>
 <tile id="46" class="Solid"/>
 <tile id="47" class="Solid"/>
 <tile id="48" class="Ground">
  <properties>
   <property name="action" value="(dialog '((&quot;There are a few sheets of paper here.&quot;)))"/>
  </properties>
 </tile>
</tileset>
