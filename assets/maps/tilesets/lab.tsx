<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.4" tiledversion="2020.08.05" name="lab" tilewidth="16" tileheight="16" tilecount="24" columns="6">
 <image source="../../images/lab.png" width="96" height="64"/>
 <tile id="0" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="1" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="2" type="Solid"/>
 <tile id="3" type="Solid"/>
 <tile id="4" type="Solid"/>
 <tile id="5" type="Solid"/>
 <tile id="6" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;Test tubes and other scientific stuff.&quot;))))</property>
  </properties>
 </tile>
 <tile id="7" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;Test tubes and other scientific stuff.&quot;))))</property>
  </properties>
 </tile>
 <tile id="8" type="Solid"/>
 <tile id="9" type="Solid"/>
 <tile id="10" type="Solid"/>
 <tile id="11" type="Solid"/>
 <tile id="12" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;Someone has turned everything upside down.&quot;))))</property>
  </properties>
 </tile>
 <tile id="13" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;Someone has turned everything upside down.&quot;))))</property>
  </properties>
 </tile>
 <tile id="14" type="Ground"/>
 <tile id="15" type="Ground"/>
 <tile id="16" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A broken monitor.&quot;)))"/>
  </properties>
 </tile>
 <tile id="17" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A broken monitor.&quot;)))"/>
  </properties>
 </tile>
 <tile id="18" type="Solid"/>
 <tile id="19" type="Solid"/>
 <tile id="20" type="Ground"/>
</tileset>
