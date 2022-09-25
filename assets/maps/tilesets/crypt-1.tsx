<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="1.9.0" name="crypt-1" tilewidth="16" tileheight="16" tilecount="56" columns="8">
 <image source="../../images/crypt-1.png" width="128" height="112"/>
 <tile id="0" class="Ground"/>
 <tile id="1" class="Ground"/>
 <tile id="2" class="Ground"/>
 <tile id="3" class="Ground"/>
 <tile id="4" class="Ground"/>
 <tile id="5" class="Ground"/>
 <tile id="6" class="Ground"/>
 <tile id="7" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A sharp and pointed rock covered by moss. It hurts.&quot;)))"/>
   <property name="atk" type="int" value="15"/>
  </properties>
 </tile>
 <tile id="8" class="Ground"/>
 <tile id="9" class="Ground"/>
 <tile id="10" class="Ground"/>
 <tile id="11" class="Ground"/>
 <tile id="12" class="Ground"/>
 <tile id="13" class="Ground"/>
 <tile id="14" class="Ground"/>
 <tile id="15" class="Solid"/>
 <tile id="16" class="Ground"/>
 <tile id="17" class="Ground"/>
 <tile id="18" class="Ground"/>
 <tile id="19" class="Ground"/>
 <tile id="20" class="Ground"/>
 <tile id="21" class="Ground"/>
 <tile id="22" class="Ground"/>
 <tile id="23" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock covered by moss.&quot;)))"/>
  </properties>
 </tile>
 <tile id="24" class="Ground"/>
 <tile id="25" class="Ground"/>
 <tile id="26" class="Ground"/>
 <tile id="27" class="Ground"/>
 <tile id="28" class="Ground"/>
 <tile id="29" class="Ground"/>
 <tile id="31" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock covered by moss.&quot;)))"/>
  </properties>
 </tile>
 <tile id="32" class="Solid"/>
 <tile id="33" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="34" class="Solid"/>
 <tile id="35" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="36" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="37" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="38" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 2)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="39" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock covered by moss.&quot;)))"/>
  </properties>
 </tile>
 <tile id="40" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 3)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="41" class="Ground"/>
 <tile id="42" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 2)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="43" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="44" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="45" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="46" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 3)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="47" class="Solid">
  <properties>
   <property name="action">(if (and (has-weapon 1) (&gt; (enemies-count) 0))
    (if (max-pp-snowballs)
        (dialog '((&quot;The snowballs container is full.&quot;))))
    (dialog '((&quot;A snowdrift.&quot;))))</property>
  </properties>
 </tile>
 <tile id="48" class="Solid"/>
 <tile id="49" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="50" class="Solid"/>
 <tile id="51" class="Solid"/>
 <tile id="52" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="53" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="54" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall covered by moss.&quot;))))</property>
  </properties>
 </tile>
 <tile id="55" class="Solid"/>
</tileset>
