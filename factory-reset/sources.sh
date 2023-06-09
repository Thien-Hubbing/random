#!/bin/bash

# Declare a bunch of variables
NORMAL=$(echo "\033[m")
MENU=$(echo "\033[36m") #Blue
NUMBER=$(echo "\033[33m") #yellow
FGRED=$(echo "\033[41m")
RED_TEXT=$(echo "\033[31m")
GRAY_TEXT=$(echo "\033[1;30m")
GREEN_TEXT=$(echo "\033[1;32m")
ENTER_LINE=$(echo "\033[33m")
header='\033[95m===>'
debug='\033[94mDEBUG: '
info='\033[96mINFO: '
success='\033[92mSUCCESS: '
warning='\033[93mWARNING: '
error='\033[91mERROR:'
endnorm='\033[0m'
notice='\033[1mNOTICE: '
menuOption=""
internetAvail=false
homebrewExist=false
which crossystem || sudo crossystem --all
if [[ $? == 0 || -x /usr/bin/crossystem ]]; then
    isChromeOS=true
    _hwid=$(crossystem hwid | sed 's/X86//g' | sed 's/ *$//g' | sed 's/ /_/g')
else
    isChromeOS=false
fi
ping google.com -c 5 &>/dev/null 2>&2
if [[ $? == 0 ]]; then
    internetAvail=true
fi
if [[ "$isChromeOS" == "true" ]]; then
    case "${_hwid}" in
        AKALI*)                 model='KBL|Acer Chromebook 13 / Spin 13' ; device="nami" ;;
        AKEMI*)                 model='CML|Lenovo Ideapad Flex 5 Chromebook' ;;
        ALEENA*)                model='STR|Acer Chromebook 315' ;;
        AMPTON*)                model='GLK|Asus Chromebook Flip C214/C234' ;;
        ANAHERA*)               model='ADL|HP Elite c640 14 inch G3 Chromebook'; device="anahera" ;;
        APELE*)                 model='GLK|Asus Chromebook CX1101CMA' ;;
        APEL*)                  model='GLK|Asus Chromebook Flip C204' ;;
        ARCADA*)                model='WHL|Dell Latitude 5300' ; device="sarien" ;;
        ASTRONAUT*)             model='APL|Acer Chromebook 11 (C732*)' ;;
        ASUKA*)                 model='SKL|Dell Chromebook 13 (3380)' ;;
        ATLAS*)                 model='KBL|Google Pixelbook Go' ;;
        AURON_PAINE*)           model='BDW|Acer Chromebook 11 (C740)' ;;
        AURON_YUNA*)            model='BDW|Acer Chromebook 15 (CB5-571, C910)' ;;
        BABYMEGA*)              model='APL|Asus Chromebook C223NA' ;;
        BABYTIGER*)             model='APL|Asus Chromebook C523NA' ;;
        BANJO*)                 model='BYT|Acer Chromebook 15 (CB3-531)' ;;
        BANON*)                 model='BSW|Acer Chromebook 15 (CB3-532)' ;;
        BANSHEE*)               model='ADL|Framework Chromebook' ;;
        BARD*)                  model='KBL|Acer Chromebook 715 (CB715)' ; device="nami" ;;
        BARLA*)                 model='STR|HP Chromebook 11A G6 EE' ;;
        BERKNIP*)               model='ZEN2|HP Pro c645 Chromebook Enterprise' ;;
        BLACKTIP*)              model='APL|White Label Chrombook' ;;
        BLEEMO*)                model='KBL|Asus Chromebox 3 / CN65 (Core i7)' ; device="fizz" ;;
        BEETLEY*)               model='JSL|Lenovo Flex 3i/3i-15 Chromebook' ;;
        BLIPPER*)               model='JSL|Lenovo 3i-15 Chromebook	';;
        BLOOGLET*)              model='GLK|HP Chromebook 14a';;
        BLOOGUARD*)             model='GLK|HP Chromebook x360 14a/14b';;
        BLOOG*)                 model='GLK|HP Chromebook x360 12b';;
        BLORB*)                 model='GLK|Acer Chromebook 315';;
        BLUEBIRD*)              model='GLK|Samsung Chromebook 4' ;;
        BLUE*)                  model='APL|Acer Chromebook 15 [CB315-1H*]' ;;
        BOBBA360*)              model='GLK|Acer Chromebook Spin 311/511' ;;
        BOBBA*)                 model='GLK|Acer Chromebook 311' ;;
        BOOKEM*)                model='JSL|Lenovo 100e Chromebook Gen 3' ;;
        BOTENFLEX*)             model='JSL|Lenovo Flex 3i/3i-11 Chromebook' ;;
        BOTEN*)                 model='JSL|Lenovo 500e Chromebook Gen 3' ;;
        BRUCE*)                 model='APL|Acer Chromebook Spin 15 [CP315]' ;;
        BUDDY*)                 model='BDW|Acer Chromebase 24' ;;
        BUGZZY*)                model='JSL|Samsung Galaxy Chromebook 2 360' ;;
        BUTTERFLY*)             model='SNB|HP Pavilion Chromebook 14' ;;
        CANDY*)                 model='BYT|Dell Chromebook 11' ;;
        CAREENA*)               model='STR|HP Chromebook 14' ;;
        CAROLINE*)              model='SKL|Samsung Chromebook Pro' ;;
        CASTA*)                 model='GLK|Samsung Chromebook 4+';;
        CAVE*)                  model='SKL|ASUS Chromebook Flip C302' ;;
        CELES*)                 model='BSW|Samsung Chromebook 3' ;;
        CHELL*)                 model='SKL|HP Chromebook 13 G1' ;;
        CHRONICLER*)            model='TGL|FMV Chromebook 14F' ;;
        CLAPPER*)               model='BYT|Lenovo N20/N20P Chromebook' ;;
        COLLIS*)                model='TGL|AAsus Chromebook Flip CX3' ;;
        COPANO*)                model='TGL|Asus Chromebook Flip CX5 (CX5400)' ;;
        CORAL*)                 model='APL|Incorrectly identified APL Chromebook' ;;
        CRET360*)               model='JSL|Dell Chromebook 3110 2-in-1' ;;
        CRET*)                  model='JSL|Dell Chromebook 3110' ;;
        CROTA360*)              model='ADL|Dell Latitude 5430 2-in-1 Chromebook'; device="crota360" ;;
        CROTA*)                 model='ADL|Dell Latitude 5430 Chromebook'; device="crota" ;;
        CYAN*)                  model='BSW|Acer Chromebook R11 (C738T)' ;;
        DELBIN*)                model='TGL|ASUS Chromebook Flip CX55/CX5500/C536' ;;
        DIRINBOZ*)              model='ZEN2|HP Chromebook 14a' ;;
        DOOD*)                  model='GLK|NEC Chromebook Y2';;
        DOOLY*)                 model='CML|HP Chromebase 21.5' ;;
        DORP*)                  model='GLK|HP Chromebook 14 G6';;
        DRAGONAIR*)             model='CML|HP Chromebook x360 14c' ;;
        DRALLION*)              model='CML|Dell Latitude 7410 Chromebook Enterprise' ; device="drallion" ;;
        DRATINI*)               model='CML|HP Pro c640 Chromebook' ;;
        DRAWCIA*)               model='JSL|HP Chromebook x360 11 G4 EE' ;;
        DRAWLAT*)               model='JSL|HP Chromebook 11 G9 EE' ;;
        DRAWMAN*)               model='JSL|HP Chromebook 14 G7' ;;
        DRAWPER*)               model='JSL|HP Fortis 14 G10 Chromebook' ;;
        DROBIT*)                model='TGL|ASUS Chromebook CX9 (CX9400)' ;;
        DROID*)                 model='GLK|Acer Chromebook 314';;
        DUFFY*)                 model='CML|ASUS Chromebox 4' ;;
        EDGAR*)                 model='BSW|Acer Chromebook 14 (CB3-431)' ;;
        EKKO*)                  model='KBL|Acer Chromebook 714 (CB714)' ; device="nami" ;;
        ELDRID*)                model='TGL|HP Chromebook x360 14c' ;;
        ELECTRO*)               model='APL|Acer Chromebook Spin 11 (R751T)' ;;
        ELEMI*)                 model='TGL|HP Pro c640 G2 Chromebook' ;;
        ENGUARDE_???-???-??A*)  model='BYT|CTL N6 Education Chromebook' ;;
        ENGUARDE_???-???-??B*)  model='BYT|M&A Chromebook' ;;
        ENGUARDE_???-???-??C*)  model='BYT|Senkatel C1101 Chromebook' ;;
        ENGUARDE_???-???-??D*)  model='BYT|Edxis Education Chromebook' ;;
        ENGUARDE_???-???-??E*)  model='BYT|Lenovo N21 Chromebook' ;;
        ENGUARDE_???-???-??F*)  model='BYT|RGS Education Chromebook' ;;
        ENGUARDE_???-???-??G*)  model='BYT|Crambo Chromebook' ;;
        ENGUARDE_???-???-??H*)  model='BYT|True IDC Chromebook' ;;
        ENGUARDE_???-???-??I*)  model='BYT|Videonet Chromebook' ;;
        ENGUARDE_???-???-??J*)  model='BYT|eduGear Chromebook R' ;;
        ENGUARDE_???-???-??K*)  model='BYT|ASI Chromebook' ;;
        ENGUARDE*)              model='BYT|(multiple device matches)' ;;
        EPAULETTE*)             model='APL|UNK Acer Chromebook ' ;;
        EVE*)                   model='KBL|Google Pixelbook' ;;
        EXCELSIOR-URAR*)        model='KBL|Asus Google Meet kit (KBL)'; device="fizz" ;;
        EZKINIL*)               model='ZEN2|Acer Chromebook Spin 514' ;;
        FAFFY*)                 model='CML|ASUS Fanless Chromebox' ;;
        FALCO*)                 model='HSW|HP Chromebook 14' ;;
        FELWINTER*)             model='ADL|ASUS Chromebook Flip CX5(CX5601)'; device="felwinter" ;;
        FIZZ)                   model='KBL|TBD KBL Chromebox' ;;
        FLEEX*)                 model='GLK|Dell Chromebook 3100';;
        FOOB*)                  model='GLK|CTL Chromebook VX11/VT11T';;
        GALITH360*)             model='JSL|ASUS Chromebook CX1500FKA' ;;
        GALITH*)                model='JSL|ASUS Chromebook CX1500CKA' ;;
        GALLOP*)                model='JSL|ASUS Chromebook CX1700CKA' ;;
        GALNAT360*)             model='JSL|ASUS Chromebook Flip CX1102' ;;
        GALNAT*)                model='JSL|ASUS Chromebook CX1102' ;;
        GALTIC360*)             model='JSL|ASUS Chromebook CX1400FKA' ;;
        GALTIC*)                model='JSL|ASUS Chromebook CX1' ;;
        GANDOF*)                model='BDW|Toshiba Chromebook 2 (2015) CB30/CB35' ;;
        GARFOUR*)               model='GLK|CTL Chromebook NL81/NL81T';;
        GARG360*)               model='GLK|CTL Chromebook NL71T/TW/TWB';;
        GARG*)                  model='GLK|CTL Chromebook NL71/CT/LTE';;
        GLIMMER*)               model='BYT|Lenovo ThinkPad 11e/Yoga Chromebook' ;;
        GLK360*)                model='GLK|Acer Chromebook Spin 311';;
        GLK*)                   model='GLK|Acer Chromebook 311';;
        GNAWTY*)                model='BYT|Acer Chromebook 11 (CB3-111/131,C730/C730E/C735)' ;;
        GRABBITER*)             model='GLK|Dell Chromebook 3100 2-in-1';;
        GUADO*)                 model='BDW|ASUS Chromebox 2 / CN62' ;;
        HELIOS*)                model='CML|ASUS Chromebook Flip C436FA' ;;
        HELI*)                  model='BYT|Haier Chromebook G2' ;;
        JAX*)                   model='KBL|AOpen Chromebox Commercial 2' ; device="fizz";;
        JINLON*)                model='CML|HP Elite c1030 Chromebook / HP Chromebook x360 13c';;
        KAISA*)                 model='CML|Acer Chromebox CXI4' ;;
        KANO*)                  model='ADL|Acer Chromebook Spin 714 [CP714-1WN]'; device="kano" ;;
        KARMA*)                 model='KBL|Acer Chromebase 24I2' ;;
        KASUMI*)                model='STR|Acer Chromebook 311' ; device="kasumi" ;;
        KEFKA*)                 model='BSW|Dell Chromebook 11 (3180,3189)' ;;
        KENCH*)                 model='KBL|HP Chromebox G2' ; device="fizz" ;;
        KINDRED*)               model='CML|Acer Chromebook 712 (C871)' ;;
        KIP*)                   model='BYT|HP Chromebook 11 G3/G4, 14 G4' ;;
        KLED*)                  model='CML|Acer Chromebook Spin 713 (CP713-2W)' ;;
        KOHAKU*)                model='CML|Samsung Galaxy Chromebook' ;;
        KRACKO360-BLXA*)        model='JSL|CTL Chromebook NL72T' ;;
        KRACKO360*)             model='JSL|LG Chromebook 11TC50Q/11TQ50Q' ;;
        KRACKO*)                model='JSL|CTL Chromebook NL72' ;;
        LANDIA*)                model='JSL|HP Chromebook x360 14a' ;;
        LANDRID*)               model='JSL|HP Chromebook 15a' ;;
        LANTIS*)                model='JSL|HP Chromebook 14a' ;;
        LARS_???-???-???-?3?*)  model='SKL|Acer Chromebook 11 (C771, C771T)' ;;
        LARS*)                  model='SKL|Acer Chromebook 14 for Work' ;;
        LASER14*)               model='GLK|Lenovo Chromebook S340 / IdeaPad 3';;
        LASER*)                 model='GLK|Lenovo Chromebook C340';;
        LAVA*)                  model='APL|Acer Chromebook Spin 11 CP311' ;;
        LEONA*)                 model='KBL|Asus Chromebook C425TA' ;;
        LEON*)                  model='HSW|Toshiba CB30/CB35 Chromebook' ;;
        LIARA*)                 model='STR|Lenovo 14e Chromebook' ;;
        LIBREM_13_V1)           model='BDW|Purism Librem 13 v1' ; device="librem13v1" ;;
        LIBREM13V1)             model='BDW|Purism Librem 13 v1' ;;
        LIBREM_13_V2)           model='SKL|Purism Librem 13 v2' ; device="librem13v2" ;;
        LIBREM13V2)             model='SKL|Purism Librem 13 v2' ;;
        LIBREM_13_V3)           model='SKL|Purism Librem 13 v3' ; device="librem13v2" ;;
        LIBREM13V3)             model='SKL|Purism Librem 13 v3' ;;
        LIBREM_13_V4)           model='KBL|Purism Librem 13 v4' ; device="librem13v4" ;;
        LIBREM13V4)             model='KBL|Purism Librem 13 v4' ;;
        LIBREM_14)              model='CML|Purism Librem 14' ; device="librem_14" ;;
        LIBREM_15_V2)           model='BDW|Purism Librem 15 v2' ; device="librem15v2" ;;
        LIBREM15V2)             model='BDW|Purism Librem 15 v2' ;;
        LIBREM_15_V3)           model='SKL|Purism Librem 15 v3' ; device="librem15v3" ;;
        LIBREM15V3)             model='SKL|Purism Librem 15 v3' ;;
        LIBREM_15_V4)           model='KBL|Purism Librem 15 v4' ; device="librem15v4" ;;
        LIBREM15V4)             model='KBL|Purism Librem 15 v4' ;;
        LIBREM_MINI)            model='WHL|Purism Librem Mini' ; device="librem_mini" ;;
        LIBREM_MINI_V2)         model='CML|Purism Librem Mini v2' ; device="librem_mini_v2" ;;
        LICK*)                  model='GLK|Lenovo Ideapad 3 Chromebook' ;;
        LILLIPUP*)              model='TGL|Lenovo IdeaPad Flex 5i Chromebook' ; device="lillipup" ;;
        LINDAR-EDFZ*)           model='TGL|Lenovo 5i-14 Chromebook' ; device="lindar" ;;
        LINDAR-LCDF*)           model='TGL|Lenovo Slim 5 Chromebook' ; device="lindar" ;;
        LINDAR*)                model='TGL|Lenovo Slim 5/5i/Flex 5i Chromebook' ; device="lindar" ;;
        LINK*)                  model='IVB|Google Chromebook Pixel 2013' ;;
        LULU*)                  model='BDW|Dell Chromebook 13 (7310)' ;;
        MADOO*)                 model='JSL|HP Chromebook x360 14b' ;;
        MAGISTER*)              model='JSL|Acer Chromebook Spin 314' ;;
        MAGLET*)                model='JSL|Acer Chromebook 512 (C852)' ;;
        MAGLIA*)                model='JSL|Acer Chromebook Spin 512' ;;
        MAGLITH*)               model='JSL|Acer Chromebook 511' ;;
        MAGMA*)                 model='JSL|Acer Chromebook 315' ;;
        MAGNETO-BWYB*)          model='JSL|Acer Chromebook 314' ;;
        MAGNETO-SGGB*)          model='JSL|Packard Bell Chromebook 314' ;;
        MAGOLOR*)               model='JSL|Acer Chromebook Spin 511 [R753T]' ;;
        MAGPIE*)                model='JSL|Acer Chromebook 317 [CB317-1H]' ;;
        METAKNIGHT*)            model='JSL|NEC Chromebook Y3' ;;
        LUMPY*)                 model='SNB|Samsung Chromebook Series 5 550' ;;
        MCCLOUD*)               model='HSW|Acer Chromebox CXI' ;;
        MEEP*)                  model='GLK|HP Chromebook x360 11 G2 EE' ;;
        MIMROCK*)               model='GLK|HP Chromebook 11 G7 EE' ;;
        MONROE*)                model='HSW|LG Chromebase' ;;
        MORPHIUS*)              model='ZEN2|Lenovo ThinkPad C13 Yoga Chromebook' ;;
        NAUTILUS*)              model='KBL|Samsung Chromebook Plus V2' ;;
        NASHER360*)             model='APL|Dell Chromebook 11 2-in-1 5190' ;;
        NASHER*)                model='APL|Dell Chromebook 11 5190' ;;
        NIGHTFURY*)             model='CML|Samsung Galaxy Chromebook 2' ;;
        NINJA*)                 model='BYT|AOpen Chromebox Commercial' ;;
        NOCTURNE*)              model='KBL|Google Pixel Slate' ;;
        NOIBAT*)                model='CML|HP Chromebox G3' ;;
        NOSPIKE*)               model='GLK|ASUS Chromebook C424';;
        ORCO*)                  model='BYT|Lenovo Ideapad 100S Chromebook' ;;
        ORBATRIX*)              model='GLK|Dell Chromebook 3400';;
        OSIRIS*)                model='ADL|Acer Chromebook 516 GE [CBG516-1H]'; device="osiris" ;;
        PAINE*)                 model='BDW|Acer Chromebook 11 (C740)' ; device="auron_paine" ;;
        PANTHEON*)              model='KBL|Lenovo Yoga Chromebook C630'  ; device="nami" ;;
        PANTHER*)               model='HSW|ASUS Chromebox CN60' ;;
        PARROT*)                model='SNB|Acer C7/C710 Chromebook' ;;
        PASARA*)                model='JSL|Gateway Chromebook 15' ;;
        PEPPY*)                 model='HSW|Acer C720/C720P Chromebook' ;;
        PHASER360*)             model='GLK|Lenovo 300e/500e Chromebook 2nd Gen' ;;
        PHASER*)                model='GLK|Lenovo 100e Chromebook 2nd Gen' ;;
        PIRETTE-LLJI*)          model='JSL|Axioo Chromebook P11' ;;
        PIRETTE-NGVJ*)          model='JSL|SPC Chromebook Z1 Mini' ;;
        PIRETTE-RVKU*)          model='JSL|CTL Chromebook PX11E' ;;
        PIRETTE-UBKE*)          model='JSL|Zyrex Chromebook M432-2' ;;
        PIRIKA-BMAD*)           model='JSL|CTL Chromebook PX14E/PX14EX/PX14EXT' ;;
        PIRIKA-NPXS*)           model='JSL|Axioo Chromebook P14' ;;
        PIRIKA-XAJY*)           model='JSL|Gateway Chromebook 14' ;;
        PRIMUS*)                model='ADL|Lenovo ThinkPad C14 Gen 1 Chromebook'; device="primus" ;;
        PYRO*)                  model='APL|Lenovo Thinkpad 11e/Yoga Chromebook (G4)' ;;
        QUAWKS*)                model='BYT|ASUS Chromebook C300' ;;
        RABBID*)                model='APL|ASUS Chromebook C423' ;;
        RAMMUS*)                model='KBL|Asus Chromebook C425/C433/C434' ;;
        REDRIX*)                model='ADL|HP Elite Dragonfly Chromebook'; device="redrix" ;;
        REEF_???-C*)            model='APL|ASUS Chromebook C213NA' ;;
        REEF*)                  model='APL|Acer Chromebook Spin 11 (R751T)' ; device="electro" ;;
        REKS_???-???-???-B*)    model='BSW|2016|Lenovo N42 Chromebook' ;;
        REKS_???-???-???-C*)    model='BSW|2017|Lenovo N23 Chromebook (Touch)';;
        REKS_???-???-???-D*)    model='BSW|2017|Lenovo N23 Chromebook' ;;
        REKS_???-???-???-*)     model='BSW|2016|Lenovo N22 Chromebook' ;;
        REKS*)                  model='BSW|2016|(unknown REKS)' ;;
        RELM_???-B*)            model='BSW|CTL NL61 Chromebook' ;;
        RELM_???-C*)            model='BSW|Edxis Education Chromebook' ;;
        RELM_???-F*)            model='BSW|Mecer V2 Chromebook' ;;
        RELM_???-G*)            model='BSW|HP Chromebook 11 G5 EE' ;;
        RELM_???-H*)            model='BSW|Acer Chromebook 11 N7 (C731)' ;;
        RELM_???-Z*)            model='BSW|Quanta OEM Chromebook' ;;
        RELM*)                  model='BSW|(unknown RELM)' ;;
        RIKKU*)                 model='BDW|Acer Chromebox CXI2' ;;
        ROBO360*)               model='APL|Lenovo 500e Chromebook' ;;
        ROBO*)                  model='APL|Lenovo 100e Chromebook' ;;
        SAMUS*)                 model='BDW|Google Chromebook Pixel 2015' ;;
        SAND*)                  model='APL|Acer Chromebook 15 (CB515-1HT)' ;;
        SANTA*)                 model='APL|Acer Chromebook 11 (CB311-8H)' ;;
        SARIEN*)                model='WHL|Dell Latitude 5400' ;;
        SASUKE*)                model='JSL|Samsung Galaxy Chromebook Go' ;;
        SENTRY*)                model='SKL|Lenovo Thinkpad 13 Chromebook' ;;
        SETZER*)                model='BSW|HP Chromebook 11 G5' ;;
        SHYVANA*)               model='KBL|Asus Chromebook Flip C433/C434' ;;
        SION*)                  model='KBL|Acer Chromebox CXI3' ; device="fizz" ;;
        SNAPPY_???-A*)          model='APL|HP Chromebook x360 11 G1 EE' ;;
        SNAPPY_???-B*)          model='APL|HP Chromebook 11 G6 EE' ;;
        SNAPPY_???-C*)          model='APL|HP Chromebook 14 G5' ;;
        SNAPPY*)                model='APL|HP Chromebook x360 11 G1/11 G6/14 G5' ;;
        SPARKY360*)             model='GLK|Acer Chromebook Spin 512 (R851TN)' ;;
        SPARKY*)                model='GLK|Acer Chromebook 512 (C851/C851T)' ;;
        SONA*)                  model='KBL|HP Chromebook x360 14' ; device="nami" ;;
        SORAKA*)                model='KBL|HP Chromebook x2' ;;
        SQUAWKS*)               model='BYT|ASUS Chromebook C200' ;;
        STORO360*)              model='JSL|ASUS Chromebook Flip CR1100FKA' ;;
        STORO*)                 model='JSL|ASUS Chromebook CR1100CKA' ;;
        STOUT*)                 model='IVB|Lenovo Thinkpad X131e Chromebook' ;;
        STUMPY*)                model='SNB|Samsung Chromebox Series 3' ;;
        SUMO*)                  model='BYT|AOpen Chromebase Commercial' ;;
        SWANKY*)                model='BYT|Toshiba Chromebook 2 (2014) CB30/CB35' ;;
        SYNDRA*)                model='KBL|HP Chromebook 15 G1' ; device="nami" ;;
        TAEKO*)                 model='ADL|Lenovo Lenovo Flex 5i Chromebook 14"'; device="taeko" ;;
        TANIKS*)                model='ADL|Lenovo IdeaPad Gaming Chromebook 16'; device="tankis" ;;
        TEEMO*)                 model='KBL|Asus Chromebox 3 / CN65' ; device="fizz" ;;
        TERRA_???-???-???-A*)   model='BSW|ASUS Chromebook C202SA' ;;
        TERRA_???-???-???-B*)   model='BSW|ASUS Chromebook C300SA/C301SA' ;;
        TERRA*)                 model='BSW|ASUS Chromebook C202SA, C300SA/C301SA' ; device="terra" ;;
        TIDUS*)                 model='BDW|Lenovo ThinkCentre Chromebox' ;;
        TREEYA360*)             model='STR|Lenovo 300e Chromebook 2nd Gen AMD' ; device="treeya" ;;
        TREEYA*)                model='STR|Lenovo 100e Chromebook 2nd Gen AMD' ; device="treeya" ;;
        TRICKY*)                model='HSW|Dell Chromebox 3010' ;;
        ULTIMA*)                model='BSW|Lenovo ThinkPad 11e/Yoga Chromebook (G3)' ;;
        VAYNE*)                 model='KBL|Dell Inspiron Chromebook 14 (7486)'  ; device="nami" ;;
        VILBOZ360*)             model='ZEN2|Lenovo 300e Chromebook Gen 3'; device="vilboz" ;;
        VILBOZ14*)              model='ZEN2|Lenovo 14e Chromebook Gen 2'; device="vilboz" ;;
        VILBOZ*)                model='ZEN2|Lenovo 100e Chromebook Gen 3'; device="vilboz" ;;
        VOEMA*)                 model='TGL|Acer Chromebook Spin 514 (CB514-2H)' ;;
        VOLET*)                 model='TGL|Acer Chromebook 515 (CB515-1W, CB515-1WT)' ;;
        VOLMAR*)                model='ADL|Acer Chromebook Vero 514'; device="volmar" ;;
        VOLTA*)                 model='TGL|Acer Chromebook 514 (CB514-1W, CB514-1WT)' ;;
        VORTICON*)              model='GLK|HP Chromebook 11 G8 EE' ;;
        VORTININJA*)            model='GLK|HP Chromebook x360 11 G3 EE' ;;
        VOXEL*)                 model='TGL|Acer Chromebook Spin 713 (CP713-3W)' ;;
        WHITETIP*)              model='APL|CTL Chromebook J41/J41T' ;;
        WINKY*)                 model='BYT|Samsung Chromebook 2 (XE500C12)' ;;
        WIZPIG_???-???-??A*)    model='BSW|CTL Chromebook J5' ;;
        WIZPIG_???-???-??B*)    model='BSW|Edugear CMT Chromebook' ;;
        WIZPIG_???-???-??C*)    model='BSW|Haier Convertible Chromebook 11 C' ;;
        WIZPIG_???-???-??D*)    model='BSW|Viglen Chromebook 360' ;;
        WIZPIG_???-???-??G*)    model='BSW|Prowise ProLine Chromebook' ;;
        WIZPIG_???-???-??H*)    model='BSW|PCMerge Chromebook PCM-116T-432B' ;;
        WIZPIG_???-???-??I*)    model='BSW|Multilaser M11C Chromebook' ;;
        WIZPIG*)                model='BSW|(unknown WIZPIG)' ;;
        WOLF*)                  model='HSW|Dell Chromebook 11' ;;
        WOOMAX*)                model='ZEN2|ASUS Chromebook Flip CM5' ;;
        WUKONG_???-???-???-??C*) model='KBL|ViewSonic NMP660 Chromebox' ; device="fizz" ;;
        WUKONG*)                model='KBL|CTL Chromebox CBx1' ; device="fizz" ;;
        WYVERN*)                model='CML|CTL Chromebox CBx2' ;;
        YUNA*)                  model='BDW|Acer Chromebook 15 (CB5-571, C910)' ; device="auron_yuna" ;;
        ZAKO*)                  model='HSW|HP Chromebox CB1' ;;
        ZAVALA*)                model='ADL|Acer Chromebook Vero 712'; device="zavala" ;;
        *)                      model='UNK|ERROR: unknown or unidentifiable device' ;; 
    esac
    hwid_simple="${_hwid%_*}"
    deviceDesc=$(echo $model | cut -d\| -f2-)
fi