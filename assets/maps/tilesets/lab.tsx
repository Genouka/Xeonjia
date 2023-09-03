<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="1.9.0" name="lab" tilewidth="16" tileheight="16" tilecount="24" columns="6">
 <image source="../../images/lab.png" width="96" height="64"/>
 <tile id="0" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="1" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="2" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="3" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="4" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="5" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A stool.&quot;)))"/>
  </properties>
 </tile>
 <tile id="6" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
  (dialog '((&quot;Test tubes and other scientific stuff.&quot;))))</property>
  </properties>
 </tile>
 <tile id="7" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
  (dialog '((&quot;Test tubes and other scientific stuff.&quot;))))</property>
  </properties>
 </tile>
 <tile id="8" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="9" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="10" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A table.&quot;)))"/>
  </properties>
 </tile>
 <tile id="11" class="Solid"/>
 <tile id="12" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
  (if (!get &quot;024-lab-juice&quot;)
    (begin
      (dialog
        '((&quot;Hey, there's a fruit juice here!\n* {{hero}} puts FRUIT JUICE in the backpack *&quot;)))
      (wait)
      (wait 1)
      (dialog
        '((&quot;…\nNo… I think I'm stealing it.\n* {{hero}} puts FRUIT JUICE back on the shelf *&quot;)
        (&quot;I'm not even sure it's a fruit juice.&quot;)))
      (set &quot;024-lab-juice&quot; #t))
    (dialog '((&quot;Better not to touch anything.&quot;)))))</property>
  </properties>
 </tile>
 <tile id="13" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;Someone has turned everything upside down.&quot;))))</property>
  </properties>
 </tile>
 <tile id="14" class="Ground">
  <properties>
   <property name="action" value="(dialog '((&quot;Someone spilled a green liquid here.&quot;)))"/>
  </properties>
 </tile>
 <tile id="15" class="Ground">
  <properties>
   <property name="action" value="(dialog '((&quot;There are pieces of glass here.&quot;)))"/>
  </properties>
 </tile>
 <tile id="16" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
  (dialog '((&quot;A broken monitor.&quot;)))
  (dialog '((&quot;A table.&quot;))))</property>
  </properties>
 </tile>
 <tile id="17" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
  (dialog '((&quot;A broken monitor.&quot;)))
  (dialog '((&quot;A table.&quot;))))</property>
  </properties>
 </tile>
 <tile id="18" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
  (dialog '((&quot;Test tubes and other scientific stuff.&quot;))))</property>
  </properties>
 </tile>
 <tile id="19" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
  (dialog '((&quot;Test tubes and other scientific stuff.&quot;))))</property>
  </properties>
 </tile>
 <tile id="20" class="Ground">
  <properties>
   <property name="action" value="(dialog '((&quot;Maybe I'd better watch my step.&quot;)))"/>
  </properties>
 </tile>
</tileset>
