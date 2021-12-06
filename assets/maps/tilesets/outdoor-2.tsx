<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="outdoor-2" tilewidth="16" tileheight="16" tilecount="160" columns="8">
 <image source="../../images/outdoor-2.png" width="128" height="320"/>
 <tile id="0" type="Ground"/>
 <tile id="1" type="Ground"/>
 <tile id="2" type="Ground"/>
 <tile id="3" type="Ground"/>
 <tile id="4" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="5" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 0)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="6" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="7" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="8" type="Ground"/>
 <tile id="9" type="Ground"/>
 <tile id="10" type="Ground"/>
 <tile id="11" type="Ground"/>
 <tile id="12" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 2)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="13" type="Ground"/>
 <tile id="14" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 3)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="15" type="Ground"/>
 <tile id="16" type="Ground"/>
 <tile id="17" type="Ground"/>
 <tile id="18" type="Ground"/>
 <tile id="19" type="Ground"/>
 <tile id="20" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="21" type="Solid">
  <properties>
   <property name="action">(if (= (orientation) 1)
    (dialog '((&quot;A rocky wall.&quot;))))</property>
  </properties>
 </tile>
 <tile id="22" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rocky wall.&quot;)))"/>
  </properties>
 </tile>
 <tile id="23" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock.&quot;)))"/>
   <property name="atk" type="int" value="5"/>
  </properties>
 </tile>
 <tile id="24" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="25" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="26" type="Ground"/>
 <tile id="27" type="Ground"/>
 <tile id="28" type="Ground"/>
 <tile id="29" type="Ground"/>
 <tile id="30" type="Ground"/>
 <tile id="31" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock.&quot;)))"/>
   <property name="atk" type="int" value="5"/>
  </properties>
 </tile>
 <tile id="32" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="33" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="34" type="Ground"/>
 <tile id="36" type="Ground"/>
 <tile id="37" type="Ground"/>
 <tile id="38" type="Ground"/>
 <tile id="39" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A rock.&quot;)))"/>
   <property name="atk" type="int" value="5"/>
  </properties>
 </tile>
 <tile id="40" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="41" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="42" type="Ground"/>
 <tile id="43" type="Solid"/>
 <tile id="44" type="Ground"/>
 <tile id="45" type="Ground"/>
 <tile id="46" type="Ground"/>
 <tile id="47" type="Solid">
  <properties>
   <property name="action">(if (has-weapon 1)
    (if (max-pp-snowballs)
        (dialog '((&quot;The snowballs container is full.&quot;))))
    (dialog '((&quot;A snowdrift.&quot;))))</property>
  </properties>
 </tile>
 <tile id="48" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="49" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="50" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="51" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="52" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="53" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="54" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;An empty vase.&quot;)))"/>
  </properties>
 </tile>
 <tile id="55" type="Solid"/>
 <tile id="56" type="Hurdle"/>
 <tile id="57" type="Hurdle"/>
 <tile id="58" type="Hurdle"/>
 <tile id="59" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A plant without berries.&quot;)))"/>
  </properties>
 </tile>
 <tile id="60" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A plant without berries.&quot;)))"/>
  </properties>
 </tile>
 <tile id="61" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A flag.&quot;)))"/>
  </properties>
 </tile>
 <tile id="62" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A vase with many fragrant flowers.&quot;)))"/>
  </properties>
 </tile>
 <tile id="63" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A barrel.&quot;)))"/>
  </properties>
 </tile>
 <tile id="64" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="65" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="66" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="67" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="68" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="69" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="70" type="Solid"/>
 <tile id="71" type="Solid"/>
 <tile id="72" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a common tree in this area.&quot;)))"/>
  </properties>
 </tile>
 <tile id="73" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a common tree in this area.&quot;)))"/>
  </properties>
 </tile>
 <tile id="74" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A street lamp.&quot;)))"/>
  </properties>
 </tile>
 <tile id="75" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="76" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="77" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A little boat.&quot;)))"/>
  </properties>
 </tile>
 <tile id="78" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;A small plant.&quot;)))"/>
  </properties>
 </tile>
 <tile id="79" type="Solid"/>
 <tile id="80" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="81" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="82" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="83" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="84" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="85" type="Solid"/>
 <tile id="86" type="Solid"/>
 <tile id="87" type="Solid"/>
 <tile id="88" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="3"/>
   <property name="priority" type="int" value="500"/>
  </properties>
 </tile>
 <tile id="89" type="Ground"/>
 <tile id="90" type="Hurdle">
  <properties>
   <property name="allowedDirection" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="91" type="Solid"/>
 <tile id="92" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="2"/>
   <property name="priority" type="int" value="500"/>
  </properties>
 </tile>
 <tile id="93" type="Solid"/>
 <tile id="94" type="Solid"/>
 <tile id="95" type="Solid"/>
 <tile id="96" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="3"/>
   <property name="priority" type="int" value="500"/>
  </properties>
 </tile>
 <tile id="97" type="Ground">
  <properties>
   <property name="priority" type="int" value="500"/>
  </properties>
 </tile>
 <tile id="98" type="Ground">
  <properties>
   <property name="blockLeft" type="bool" value="false"/>
   <property name="blockRight" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="99" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="2"/>
   <property name="priority" type="int" value="500"/>
  </properties>
 </tile>
 <tile id="100" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="2"/>
   <property name="priority" type="int" value="500"/>
  </properties>
 </tile>
 <tile id="101" type="Ground"/>
 <tile id="102" type="Solid"/>
 <tile id="103" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;It's not a good thing to look into other people's homes.&quot;)))"/>
  </properties>
 </tile>
 <tile id="104" type="Solid"/>
 <tile id="105" type="Solid"/>
 <tile id="106" type="Solid"/>
 <tile id="107" type="Solid"/>
 <tile id="108" type="Solid"/>
 <tile id="109" type="Solid"/>
 <tile id="110" type="Solid"/>
 <tile id="111" type="Solid"/>
 <tile id="112" type="Solid"/>
 <tile id="113" type="Solid"/>
 <tile id="114" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;It's not a good thing to look into other people's homes.&quot;)))"/>
  </properties>
 </tile>
 <tile id="115" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This door is closed.&quot;)))"/>
  </properties>
 </tile>
 <tile id="116" type="Solid"/>
 <tile id="117" type="Solid"/>
 <tile id="118" type="Solid"/>
 <tile id="119" type="Solid"/>
 <tile id="120" type="Solid"/>
 <tile id="121" type="Solid"/>
 <tile id="122" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="123" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="124" type="Ground">
  <properties>
   <property name="flying" type="bool" value="true"/>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="125" type="Solid"/>
 <tile id="126" type="Solid"/>
 <tile id="127" type="Solid"/>
 <tile id="128" type="Solid"/>
 <tile id="129" type="Solid"/>
 <tile id="130" type="Solid"/>
 <tile id="131" type="Solid"/>
 <tile id="132" type="Solid"/>
 <tile id="133" type="Solid"/>
 <tile id="134" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="3"/>
   <property name="priority" type="int" value="500"/>
  </properties>
 </tile>
 <tile id="135" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;The sea is calm today.&quot;)))"/>
  </properties>
  <animation>
   <frame tileid="135" duration="1000"/>
   <frame tileid="143" duration="1000"/>
  </animation>
 </tile>
 <tile id="136" type="Solid"/>
 <tile id="137" type="Solid"/>
 <tile id="138" type="Solid"/>
 <tile id="139" type="Solid"/>
 <tile id="140" type="Solid"/>
 <tile id="141" type="Solid"/>
 <tile id="142" type="Ground"/>
 <tile id="143" type="Ground"/>
 <tile id="144" type="Ground">
  <properties>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="145" type="Ground">
  <properties>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="146" type="Ground">
  <properties>
   <property name="slippery" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="147" type="Solid"/>
 <tile id="148" type="Solid"/>
 <tile id="149" type="Solid"/>
 <tile id="150" type="Solid"/>
 <tile id="151" type="ThinWall">
  <properties>
   <property name="solidSide" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="152" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a pharmacy.&quot;)))"/>
  </properties>
 </tile>
 <tile id="153" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a pharmacy.&quot;)))"/>
  </properties>
 </tile>
 <tile id="154" type="Solid">
  <properties>
   <property name="action" value="(dialog '((&quot;This is a pharmacy.&quot;)))"/>
  </properties>
 </tile>
 <tile id="155" type="Ground"/>
 <tile id="156" type="Solid"/>
 <tile id="157" type="Solid"/>
 <tile id="158" type="Solid"/>
 <tile id="159" type="Ground"/>
</tileset>
