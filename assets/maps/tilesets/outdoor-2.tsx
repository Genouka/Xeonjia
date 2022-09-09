<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.9" tiledversion="1.9.0" name="outdoor-2" tilewidth="16" tileheight="16" tilecount="160" columns="8">
 <image source="../../images/outdoor-2.png" width="128" height="320"/>
 <tile id="0" class="Ground"/>
 <tile id="1" class="Ground"/>
 <tile id="2" class="Ground"/>
 <tile id="3" class="Ground"/>
 <tile id="4" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="5" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="6" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="7" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="8" class="Ground"/>
 <tile id="9" class="Ground"/>
 <tile id="10" class="Ground"/>
 <tile id="11" class="Ground"/>
 <tile id="12" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 2)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="13" class="Ground"/>
 <tile id="14" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 3)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="15" class="Ground"/>
 <tile id="16" class="Ground"/>
 <tile id="17" class="Ground"/>
 <tile id="18" class="Ground"/>
 <tile id="19" class="Ground"/>
 <tile id="20" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="21" class="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="22" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="23" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock.&quot;)))"/>
  </properties>
 </tile>
 <tile id="24" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 3))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="25" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 2))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="26" class="Ground"/>
 <tile id="27" class="Ground"/>
 <tile id="28" class="Ground"/>
 <tile id="29" class="Ground"/>
 <tile id="30" class="Ground"/>
 <tile id="31" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock.&quot;)))"/>
  </properties>
 </tile>
 <tile id="32" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 3))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="33" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 2))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="34" class="Ground"/>
 <tile id="36" class="Ground"/>
 <tile id="37" class="Ground"/>
 <tile id="38" class="Ground"/>
 <tile id="39" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock.&quot;)))"/>
  </properties>
 </tile>
 <tile id="40" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 3))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="41" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 2))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="42" class="Ground"/>
 <tile id="43" class="Solid"/>
 <tile id="44" class="Ground"/>
 <tile id="45" class="Ground"/>
 <tile id="46" class="Ground"/>
 <tile id="47" class="Solid">
  <properties>
   <property name="action">(if (and (has-weapon 1) (&gt; (enemies-count) 0))
    (if (max-pp-snowballs)
        (dialog '((&quot;The snowballs container is full.&quot;))))
    (dialog '((&quot;A snowdrift.&quot;))))</property>
  </properties>
 </tile>
 <tile id="48" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 1))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="49" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 1))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="50" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 1))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
   <property name="allowedDirection" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="51" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="52" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="53" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="54" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;An empty vase.&quot;)))"/>
  </properties>
 </tile>
 <tile id="55" class="Solid"/>
 <tile id="56" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 0))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
  </properties>
 </tile>
 <tile id="57" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 0))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
  </properties>
 </tile>
 <tile id="58" class="Hurdle">
  <properties>
   <property name="action">(if (not (= (orientation) 0))
  (dialog '((&quot;There is a small difference in height here… I can't climb over it on this side.&quot;))))</property>
  </properties>
 </tile>
 <tile id="59" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A plant without berries.&quot;)))"/>
  </properties>
 </tile>
 <tile id="60" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A plant without berries.&quot;)))"/>
  </properties>
 </tile>
 <tile id="61" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A flag.&quot;)))"/>
  </properties>
 </tile>
 <tile id="62" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A vase with many fragrant flowers.&quot;)))"/>
  </properties>
 </tile>
 <tile id="63" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A barrel.&quot;)))"/>
  </properties>
 </tile>
 <tile id="64" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="65" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="66" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="67" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="68" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="69" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="70" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;/_2&quot; &quot;text&quot;)))"/>
   <property name="name" value="signpost"/>
  </properties>
 </tile>
 <tile id="71" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A sharp and pointed rock.&quot;)))"/>
   <property name="atk" type="int" value="15"/>
  </properties>
 </tile>
 <tile id="72" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a common tree in this area.&quot;)))"/>
  </properties>
 </tile>
 <tile id="73" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a common tree in this area.&quot;)))"/>
  </properties>
 </tile>
 <tile id="74" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A street lamp.&quot;)))"/>
  </properties>
 </tile>
 <tile id="75" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="76" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="77" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="78" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A small plant.&quot;)))"/>
  </properties>
 </tile>
 <tile id="79" class="Solid"/>
 <tile id="80" class="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="81" class="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="82" class="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="83" class="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="84" class="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="85" class="Solid"/>
 <tile id="86" class="Solid"/>
 <tile id="87" class="Solid"/>
 <tile id="88" class="ThinWall">
  <properties>
   <property name="priority" type="int" value="500"/>
   <property name="solidSide" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="89" class="Ground"/>
 <tile id="90" class="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="91" class="Solid"/>
 <tile id="92" class="ThinWall">
  <properties>
   <property name="priority" type="int" value="500"/>
   <property name="solidSide" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="93" class="Solid"/>
 <tile id="94" class="Solid"/>
 <tile id="95" class="Solid"/>
 <tile id="96" class="ThinWall">
  <properties>
   <property name="priority" type="int" value="500"/>
   <property name="solidSide" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="97" class="Ground">
  <properties>
   <property name="priority" type="int" value="500"/>
  </properties>
 </tile>
 <tile id="98" class="Ground">
  <properties>
   <property name="blockLeft" type="bool" value="false"/>
   <property name="blockRight" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="99" class="ThinWall">
  <properties>
   <property name="priority" type="int" value="500"/>
   <property name="solidSide" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="100" class="ThinWall">
  <properties>
   <property name="priority" type="int" value="500"/>
   <property name="solidSide" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="101" class="Ground"/>
 <tile id="102" class="Solid"/>
 <tile id="103" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;It's not a good thing to look into other people's homes.&quot;)))"/>
  </properties>
 </tile>
 <tile id="104" class="Solid"/>
 <tile id="105" class="Solid"/>
 <tile id="106" class="Solid"/>
 <tile id="107" class="Solid"/>
 <tile id="108" class="Solid"/>
 <tile id="109" class="Solid"/>
 <tile id="110" class="Solid"/>
 <tile id="111" class="Solid"/>
 <tile id="112" class="Solid"/>
 <tile id="113" class="Solid"/>
 <tile id="114" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;It's not a good thing to look into other people's homes.&quot;)))"/>
  </properties>
 </tile>
 <tile id="115" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This door is closed.&quot;)))"/>
  </properties>
 </tile>
 <tile id="116" class="Solid"/>
 <tile id="117" class="Solid"/>
 <tile id="118" class="Solid"/>
 <tile id="119" class="Solid"/>
 <tile id="120" class="Solid"/>
 <tile id="121" class="Solid"/>
 <tile id="122" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="123" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="124" class="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="125" class="Solid"/>
 <tile id="126" class="Solid"/>
 <tile id="127" class="Solid"/>
 <tile id="128" class="Solid"/>
 <tile id="129" class="Solid"/>
 <tile id="130" class="Solid"/>
 <tile id="131" class="Solid"/>
 <tile id="132" class="Solid"/>
 <tile id="133" class="Solid"/>
 <tile id="134" class="ThinWall">
  <properties>
   <property name="priority" type="int" value="500"/>
   <property name="solidSide" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="135" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;The sea is calm today.&quot;)))"/>
  </properties>
  <animation>
   <frame tileid="135" duration="1000"/>
   <frame tileid="143" duration="1000"/>
  </animation>
 </tile>
 <tile id="136" class="Solid"/>
 <tile id="137" class="Solid"/>
 <tile id="138" class="Solid"/>
 <tile id="139" class="Solid"/>
 <tile id="140" class="Solid"/>
 <tile id="141" class="Solid"/>
 <tile id="142" class="Ground"/>
 <tile id="143" class="Ground"/>
 <tile id="144" class="Ground">
  <properties>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="145" class="Ground">
  <properties>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="146" class="Ground">
  <properties>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="147" class="Solid"/>
 <tile id="148" class="Solid"/>
 <tile id="149" class="Solid"/>
 <tile id="150" class="Solid"/>
 <tile id="151" class="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="152" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a pharmacy.&quot;)))"/>
  </properties>
 </tile>
 <tile id="153" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a pharmacy.&quot;)))"/>
  </properties>
 </tile>
 <tile id="154" class="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a pharmacy.&quot;)))"/>
  </properties>
 </tile>
 <tile id="155" class="Ground"/>
 <tile id="156" class="Solid"/>
 <tile id="157" class="Solid"/>
 <tile id="158" class="Solid"/>
 <tile id="159" class="Ground"/>
</tileset>
