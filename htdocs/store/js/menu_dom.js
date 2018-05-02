//////////////////////////////////////////////////////////////////////
/////////   Dynamic JavaScript Menu For Store   //////////////////////
/////////   rewritten & adapted by Ihar Hrunt, smartcgi@mail.ru //////
/////////   FOR DOM BROWSERS: IE5, IE6, OPERA, Mozilla,    ///////////
/////////                     Netscape, FireFox            ///////////
//////////////////////////////////////////////////////////////////////


var IHAR =0; // keep length of menu for submenu
var prevId = null;
var Timer;
var borderColor ="bordercolor = #1b5665";

//var onStyle="FONT-FAMILY:  Arial, Helvetica, sans-serif; font-size: 9pt; font-weight: normal; color:#ffffff;  background-color:  #468499; cursor:hand;  padding:2";
//var offStyle="FONT-FAMILY: Arial, Helvetica, sans-serif; font-size: 9pt; font-weight: normal; color:#000000;  background-color: #F7FCFF;  cursor:hand;  padding:2";

var onStyle1="FONT-FAMILY:  Arial, Helvetica, sans-serif; font-size: 9pt; font-weight: normal; color:#ffffff;  background-color:  #468499; cursor:hand;  padding:2";
var offStyle1="FONT-FAMILY: Arial, Helvetica, sans-serif; font-size: 9pt; font-weight: normal; color:#000000;  background-color:  #F7FCFF;  cursor:hand;  padding:2";
var onStyle2="FONT-FAMILY:  Arial, Helvetica, sans-serif; font-size: 9pt; font-weight: normal; color:#aaaaaa;  background-color:  #468499; padding:2";
var offStyle2="FONT-FAMILY: Arial, Helvetica, sans-serif; font-size: 9pt; font-weight: normal; color:#aaaaaa;  background-color:  #F7FCFF;  padding:2";

var onStyle =onStyle1;
var offStyle=offStyle1;

var onStyleExpandOver = "FONT-WEIGHT: normal; FONT-SIZE: 12px; COLOR: #FF0000; FONT-FAMILY: Arial, Helvetica, Verdana, sans-serif; TEXT-DECORATION: none; cursor:hand;";
var onStyleExpandOut  = "FONT-WEIGHT: normal; FONT-SIZE: 12px; COLOR: #456789; FONT-FAMILY: Arial, Helvetica, Verdana, sans-serif; TEXT-DECORATION: none; cursor:hand;";



var isDOM = false;
var isIE = false;
var isOpera7 = false;
var isNN4 = false;


var flagMenu = "M";
var flagLink = "L";
var flagCommand = "C";
var flagSeparator = "S";

var charWidth = 5; // item character width
var charWidthAdd = 55;
var charHeight = 19; // item character height
var colorNormal = "#F7FCFF"; // menu pad color
var colorHighlighted = "#5FA0B2"; // menu highlighted item color               
var colorTopLine = "#F7FCFF"; // separator upper line color
var colorBottomLine = "#1b5665"; // separator lower line color


var borderSize = 1;
var marginSize = 4;
var marginString = "&nbsp;&nbsp;";
var subMenuFlagSize = 4;

var menuShown = -1;
var itemOn = false;
var nnWidth = 0, nnHeight = 0;

var menuItemCount = -1;
var menuItem = new Array();
var menuFolderCount = -1;
var menuFolder = new Array();
var menuFolderSwitch = new Array();
var menuWidth = new Array();
var itemLayer = new Array();
var menuLayer = new Array();
var menuHolder = new Array();
var menuDone = new Array();

var focusIt = 0;


if(typeof HTMLElement!="undefined" && !
HTMLElement.prototype.insertAdjacentElement){


HTMLElement.prototype.insertAdjacentHTML = function (sWhere, sHTML) {
   var df;   // : DocumentFragment
   var r = this.ownerDocument.createRange();

   switch (String(sWhere).toLowerCase()) {  // convert to string and unify case
      case "beforebegin":
         r.setStartBefore(this);
         df = r.createContextualFragment(sHTML);
         this.parentNode.insertBefore(df, this);
         break;

      case "afterbegin":
         r.selectNodeContents(this);
         r.collapse(true);
         df = r.createContextualFragment(sHTML);
         this.insertBefore(df, this.firstChild);
         break;

      case "beforeend":
         r.selectNodeContents(this);
         r.collapse(false);
         df = r.createContextualFragment(sHTML);
         this.appendChild(df);
         break;

      case "afterend":
         r.setStartAfter(this);
         df = r.createContextualFragment(sHTML);
         this.parentNode.insertBefore(df, this.nextSibling);
         break;
   }
 };
}

function outliner(name1,name2,name3) {


 var child = document.getElementById(name1);
 if (null != child)
     child.className = child.className == "collapsed2" ? "expanded2" : "collapsed2";

 var child2 = document.getElementById(name2);
 if (null != child2)
     child2.className = child2.className == "collapsed" ? "expanded" : "collapsed";

 var child3 = document.getElementById(name3);
 if (null != child3)
     child3.className = child3.className == "collapsed" ? "expanded" : "collapsed";

}


function outliner2(name1,name2,name3,name4) {


 var child1 = document.getElementById(name1);
 var child2 = document.getElementById(name2);
 var child3 = document.getElementById(name3);
 var child4 = document.getElementById(name4);


 if (null != child1){
      child1.className = "expanded2"; 
 }
 if (null != child2){
    child2.className = "collapsed2"; 
 }
 if (null != child3){
   child3.className = "collapsed2"; 
 }
 if (null != child4){
   child4.className = "collapsed2"; 
 }

}


function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0

  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}




function launchCommand(commandString) {
  eval(commandString);
}

function launchPage(pageURL) {
  document.location.assign(pageURL);
}

function getLayer(layerID) {
  return (isDOM)?document.getElementById(layerID):document.layers[layerID];
}

function clickMenu(menuNum,itemIndex) {
  var menuIndex = menuItem[menuNum][itemIndex].myFolder;
  var folderIndex = menuItem[menuNum][itemIndex].folder;
  var itemX = menuItem[menuNum][itemIndex].x;
  var itemY = menuItem[menuNum][itemIndex].y;

  var menuID = getMenu(menuNum,menuIndex,0,0,0,0);
  var theLayer = getLayer(menuID);

  if (menuItem[menuNum][itemIndex].type == flagMenu) {
//    if (menuFolderSwitch[menuNum][folderIndex])
//      hideMenu(menuNum,folderIndex)
//    else
//      showMenu(menuNum,folderIndex,itemX + menuWidth[menuNum][menuIndex] * charWidth + subMenuFlagSize,itemY, theLayer.seDimX,theLayer.seDimY, ++focusIt);
    launchPage(menuItem[menuNum][itemIndex].url);
  }
  else if (menuItem[menuNum][itemIndex].type == flagLink) {
    closeMenu(menuNum);
    launchPage(menuItem[menuNum][itemIndex].url);
  }
  else if (menuItem[menuNum][itemIndex].type == flagCommand) {
   // closeMenu(menuNum);
   // launchCommand(menuItem[menuNum][itemIndex].command);
  }
}

function mouseOver() {
  var menuNum = this.menuNum;
  var itemIndex = this.itemIndex;
  var menuIndex = menuItem[menuNum][itemIndex].myFolder;
  var menuLength = menuFolder[menuNum][menuIndex].length;
  var folderIndex = menuItem[menuNum][itemIndex].folder;
  var itemX = menuItem[menuNum][itemIndex].x;
  var itemY = menuItem[menuNum][itemIndex].y;
  var thisFolder = 0;
  var thisItem = 0;

  var textCSS_1= "CSS1_"  + this.id;
  var textCSS_2= "CSS2_"  + this.id;


  var menuID = getMenu(menuNum,menuIndex,0,0,0,0);
  var theLayer = getLayer(menuID);

  itemOn = true;

  if (menuItem[menuNum][itemIndex].type != flagSeparator) {
   if (isDOM) {

    if (menuItem[menuNum][itemIndex].type == flagCommand) {
      onStyle=onStyle2; offStyle=offStyle2;
    }
    else {
      onStyle=onStyle1;   offStyle=offStyle1;
    }

       if (isOpera7) {
          document.getElementById(textCSS_1).style.backgroundColor = colorHighlighted;
          document.getElementById(textCSS_2).style.backgroundColor = colorHighlighted;
       }
       else {
          document.getElementById(textCSS_1).style.cssText=onStyle;
          document.getElementById(textCSS_2).style.cssText=onStyle;
       }
    }
    else if (isNN4) {
      ///////////////////////////////////////////////////////
      this.document.bgColor = colorHighlighted;
    }
  }

  for (var i = 0; i < menuLength; i++) {
    thisItem = menuFolder[menuNum][menuIndex][i];

    if (thisItem != itemIndex)
      if (menuItem[menuNum][thisItem].type == flagMenu) {
        thisFolder = menuItem[menuNum][thisItem].folder;

        if (menuFolderSwitch[menuNum][thisFolder]) {
           hideMenu(menuNum,thisFolder);
           if (prevId != null) {
               textCSS_1= "CSS1_"  + prevId;
               textCSS_2= "CSS2_"  + prevId;

               if (isOpera7) {
                  document.getElementById(textCSS_1).style.backgroundColor = colorNormal;
                  document.getElementById(textCSS_2).style.backgroundColor = colorNormal;
               }
               else {
                  document.getElementById(textCSS_1).style.cssText=offStyle;
                  document.getElementById(textCSS_2).style.cssText=offStyle;
               }
            }
            prevId = null;
        }
      }
  }

  if (menuItem[menuNum][itemIndex].type == flagMenu)
    if (!menuFolderSwitch[menuNum][folderIndex]) {

      showMenu(menuNum,folderIndex,itemX + menuWidth[menuNum][menuIndex] * charWidth + subMenuFlagSize + charWidthAdd,itemY, theLayer.seDimX,theLayer.seDimY, ++focusIt);

      prevId = this.id;
    }

  if (prevId != null) {
       if (menuItem[menuNum][itemIndex].myFolder != 0 ) {
          textCSS_1= "CSS1_"  + prevId;
          textCSS_2= "CSS2_"  + prevId;
          if (isOpera7) {
             document.getElementById(textCSS_1).style.backgroundColor = colorHighlighted;
             document.getElementById(textCSS_2).style.backgroundColor = colorHighlighted;
          }
          else {
             document.getElementById(textCSS_1).style.cssText=onStyle;
             document.getElementById(textCSS_2).style.cssText=onStyle;
          }

      }
  }

//  window.status = "IHAR = " +IHAR + " menuIndex = " + menuIndex + " itemIndex = " + itemIndex + " itemX = " + itemX + " itemY = " + itemY;

  return true;

}



function mouseOut() {

  itemOn = false;

  var textCSS_1= "CSS1_"  + this.id;
  var textCSS_2= "CSS2_"  + this.id;

  var menuNum = this.menuNum;
  var itemIndex = this.itemIndex;

  if (menuItem[menuNum][itemIndex].type != flagSeparator) {

  if (isDOM) {
    if (isOpera7) {
        document.getElementById(textCSS_1).style.backgroundColor = colorNormal;
        document.getElementById(textCSS_2).style.backgroundColor = colorNormal;
    }
    else {
       document.getElementById(textCSS_1).style.cssText=offStyle;
       document.getElementById(textCSS_2).style.cssText=offStyle;
    }
  }
  else if (isNN4)
    this.document.bgColor = colorNormal;

 }
  window.status = "";
  return true;
}

function menuItemUnit() {
  this.type = "";
  this.name = "";
  this.description = "";
  this.url = "";
  this.command = "";
  this.menu = "";
  this.folder = -1;
  this.myFolder = -1;
  this.x = -1;
  this.y = -1;
}

function readMenu(menuNum,menuName) {
  var menu = eval(menuName);
  var menuLength = menu.length
  var thisFolder = ++menuFolderCount;

  menuFolder[menuNum][thisFolder] = new Array();
  menuFolderSwitch[menuNum][thisFolder] = false;
  menuWidth[menuNum][thisFolder] = 0;
  menuLayer[menuNum][thisFolder] = false;
  menuDone[menuNum][thisFolder] = false;

  for (var i = 0; i < menuLength; i++) {
    menuFolder[menuNum][thisFolder][i] = ++menuItemCount;
    itemLayer[menuNum][menuItemCount] = false;

    menuItem[menuNum][menuItemCount] = new menuItemUnit();
    menuItem[menuNum][menuItemCount].myFolder = thisFolder;
    menuItem[menuNum][menuItemCount].type = menu[i][0];
    menuItem[menuNum][menuItemCount].name = menu[i][1];
    menuItem[menuNum][menuItemCount].description = menu[i][2];

    if (menuWidth[menuNum][thisFolder] < (menuItem[menuNum][menuItemCount].name.length + marginSize))
      menuWidth[menuNum][thisFolder] = menuItem[menuNum][menuItemCount].name.length + marginSize;

    if (menuItem[menuNum][menuItemCount].type == flagMenu) {
      menuItem[menuNum][menuItemCount].menu = menu[i][3];
      menuItem[menuNum][menuItemCount].folder = menuFolderCount + 1;
      menuItem[menuNum][menuItemCount].url = menu[i][2];
      readMenu(menuNum,menuItem[menuNum][menuItemCount].menu);
    }
    else if (menuItem[menuNum][menuItemCount].type == flagLink) {
      menuItem[menuNum][menuItemCount].url = menu[i][3];
    }
    else if (menuItem[menuNum][menuItemCount].type == flagCommand) {
      menuItem[menuNum][menuItemCount].command = menu[i][3];
    }
///    else if (menuItem[menuNum][menuItemCount].type != flagSeparator) {
//////////////////     // alert("Error found in " + menuName);
/////      menuItem[menuNum][menuItemCount].command = menu[i][3];
///    }
  }
}

function getItem(menuNum,itemIndex,itemDimX,itemDimY,menuIndex, myI, myY, myX) {
  var thisItem = null;
  var subMenuFlag = (menuItem[menuNum][itemIndex].type == flagMenu)?"&gt;":"";

  var singleQuote = "'";
  var itemID = "m" + menuNum + "i" + itemIndex;
  var tmpCSS_1= "CSS1_"  + itemID;
  var tmpCSS_2= "CSS2_"  + itemID;

  if (menuItem[menuNum][itemIndex].type == flagCommand) {
     onStyle=onStyle2; offStyle=offStyle2;
  }
  else {
    onStyle=onStyle1;   offStyle=offStyle1;
  }


  // Mozilla
  var myTop= myY + 1 - charHeight + myI*charHeight; 
  var myLeft = myX + 1;

  var layerString = '<div id="' + itemID + '" style="position:absolute; left:' + myLeft + '; top: '+ myTop +'; width:' + itemDimX + '; background-color:' + colorNormal + '; cursor:default; visibility:hidden;" onClick="clickMenu(' + menuNum + ',' + itemIndex + ')"></div>';
  var htmlString = (menuItem[menuNum][itemIndex].type == flagSeparator)?('<table  align= center width=' + (itemDimX)+ 'cellpadding=0 cellspacing=0 border=0><tr><td valign=middle height=' + charHeight + '><table  align= center width=' + (itemDimX-12 )+ ' height=2 cellpadding=0 cellspacing=0 border=0><tr align=left valign=bottom><td height=1 bgcolor=' + colorTopLine + '><img src="/store/img/pix.gif" width=1 height=1 border=0></td></tr><tr align=left valign=top><td height=1 bgcolor=' + colorBottomLine + '><img src="/store/img/pix.gif" width=1 height=1 border=0></td></tr></table></td></tr></table>'):('<table align=center  width=' + (itemDimX )+ ' height=' + itemDimY + ' cellpadding=0 cellspacing=0 border=0 ><tr align=left valign=middle><td ><div id=' + tmpCSS_1 + ' style="' + offStyle + '">'+ marginString + menuItem[menuNum][itemIndex].name + marginString + '</div></td><td align=right  ><div id=' + tmpCSS_2 + ' style="' + offStyle + '">' + subMenuFlag + '&nbsp;&nbsp;</div></td></tr></table>');

  if (!itemLayer[menuNum][itemIndex]) {
    itemLayer[menuNum][itemIndex] = true;

    if (isDOM) {

     document.getElementById(menuHolder[menuNum]).insertAdjacentHTML("BeforeEnd",layerString);

      thisItem = document.getElementById(itemID);
      document.getElementById(itemID).innerHTML = htmlString;

      thisItem.style.zIndex = menuIndex * 2 + 1;

      thisItem.onmouseover = mouseOver;
//////////////// 
//      if (menuItem[menuNum][itemIndex].type != flagSeparator)
        thisItem.onmouseout = mouseOut;
    }
    else if (isNN4) {
      document.layers[itemID] = new Layer(itemDimX,document.layers[menuHolder[menuNum]]);
      thisItem = document.layers[itemID];

      thisItem.visibility = "hidden";
      thisItem.document.open();
      thisItem.document.writeln(htmlString);
      thisItem.document.close();
      thisItem.document.bgColor = colorNormal;
      thisItem.zIndex = menuIndex * 2 + 1;

      thisItem.onmouseover = mouseOver;

      if (menuItem[menuNum][itemIndex].type != flagSeparator)
        thisItem.onmouseout = mouseOut;
    }


    thisItem.itemIndex = itemIndex;
    thisItem.menuNum = menuNum;
  }

  return itemID;
}


function getMenu(menuNum,menuIndex,menuDimX,menuDimY, myY, myX) {
  var menuID = "m" + menuNum + "f" + menuIndex + "";
  var menuPadX = menuDimX + borderSize * 2;
  var menuPadY = menuDimY + borderSize * 2;

   // Mozilla
   myTop = myY - charHeight;
   myLeft = myX;

  var layerString = '<div id="' + menuID + '" style="position:absolute; left:' + myLeft + '; top:' + myTop + '; width:' + menuPadX + '; visibility:hidden;"></div>';

  if ((isIE) || (isOpera7)) {
    var htmlString = '<table width=' + menuPadX + ' height=' + menuPadY +' cellpadding=0 cellspacing=0 ' + borderColor + ' border='+ (borderSize-1) + '  bgcolor=#1b5665 ><tr align=center valign=middle><td align=center valign=middle></td></tr></table>';
  }
  else {
    var htmlString = '<table width=' + menuPadX + ' height=' + menuPadY +' cellpadding=0 cellspacing=0 ' + borderColor + ' border='+ (borderSize-1) + '  bgcolor=#1b5665 ><tr align=center valign=middle><td align=center valign=middle></td></tr></table>';
  }

  var theLayer = null;

  if (!menuLayer[menuNum][menuIndex]) {
    menuLayer[menuNum][menuIndex] = true;

    if (isDOM) {

      document.getElementById(menuHolder[menuNum]).insertAdjacentHTML("afterbegin",layerString);
      theLayer = document.getElementById(menuID);
      document.getElementById(menuID).innerHTML= htmlString;

      theLayer.style.zIndex = menuIndex * 2;
    }
    else if (isNN4) {
      document.layers[menuID] = new Layer(menuPadX,document.layers[menuHolder[menuNum]]);
      theLayer = document.layers[menuID];

      theLayer.visibility = "hidden";
      theLayer.zIndex = menuIndex * 2;
      theLayer.document.open();
      theLayer.document.writeln(htmlString);
      theLayer.document.close();
    }

    theLayer.padWidth = menuPadX;
    theLayer.padHeight = menuPadY;
    theLayer.paDimX = 0; theLayer.paDimY = 0; theLayer.seDimX = 0; theLayer.seDimY = 0;
  }

  return menuID;
}


function showLayer(layerID) {
  if (isDOM)
    document.getElementById(layerID).style.visibility = "visible"
  else if (isNN4)
    document.layers[layerID].visibility = "show";
}

function hideLayer(layerID) {
  if (isDOM)
    document.getElementById(layerID).style.visibility = "hidden"
  else if (isNN4)
    document.layers[layerID].visibility = "hidden";
}

function moveLayerTo(layerID,x,y) {
  if (isDOM) {
    document.getElementById(layerID).style.pixelLeft = x;
    document.getElementById(layerID).style.pixelTop = y;
  }
  else if (isNN4) {
    document.layers[layerID].left = x;
    document.layers[layerID].top = y;
  }
}

function hideMenu(menuNum,menuIndex) {
  var menuLength = menuFolder[menuNum][menuIndex].length;
  var menuID = getMenu(menuNum,menuIndex,0,0,0,0);
  var itemID = "";
  var itemIndex = 0;

  var theLayer = getLayer(menuID);

  for (var i = 0; i < menuLength; i++) {
    itemIndex = menuFolder[menuNum][menuIndex][i];

    if (menuItem[menuNum][itemIndex].type == flagMenu)
      if (menuFolderSwitch[menuNum][menuItem[menuNum][itemIndex].folder])
        hideMenu(menuNum,menuItem[menuNum][itemIndex].folder);

    itemID = getItem(menuNum,itemIndex,0,0,0,0,0,0);
    hideLayer(itemID);
  }

  hideLayer(menuID);

  if (isNN4) { setMenuSize(menuHolder[menuNum],theLayer.paDimX,theLayer.paDimY); }

  menuFolderSwitch[menuNum][menuIndex] = false;
}


function _getLeft(_holder) {
  return (_holder.offsetParent.tagName=="BODY")?(_holder.offsetLeft):(_holder.offsetLeft+_getLeft(_holder.offsetParent));
}

function _getTop(_holder) {
  return (_holder.offsetParent.tagName=="BODY")?(_holder.offsetTop):(_holder.offsetTop+_getTop(_holder.offsetParent));
}

function getLeft(_holder) {
  return (isDOM)?_getLeft(_holder):_holder.pageX;
}

function getTop(_holder) {
  return (isDOM)?_getTop(_holder):_holder.pageY;
}

function showX(menuNum,menuIndex,menuX,menuY,dimX,dimY,fCount) {
  var menuLength = menuFolder[menuNum][menuIndex].length;
  var menuDimX = menuWidth[menuNum][menuIndex] * charWidth + subMenuFlagSize + charWidthAdd;
  var menuID = "";
  var itemID = "";
  var itemIndex = 0;
  var itemDimY = menuY;

  if (fCount == focusIt || fCount < 0) {
    for (var i = 0; i < menuLength; i++) {
       itemID = getItem(menuNum,menuFolder[menuNum][menuIndex][i],0,0,0,0,0,0);

       itemIndex = menuFolder[menuNum][menuIndex][i];
       menuItem[menuNum][itemIndex].x = menuX;
       menuItem[menuNum][itemIndex].y = itemDimY;
//       itemDimY +=  (menuItem[menuNum][itemIndex].type != flagSeparator)?charHeight:2;
       itemDimY +=  charHeight;
       moveLayerTo(itemID,menuItem[menuNum][itemIndex].x,menuItem[menuNum][itemIndex].y);

       showLayer(itemID);
     }

     menuID = getMenu(menuNum,menuIndex,0,0,0,0);
     moveLayerTo(menuID,menuX-borderSize,menuY-borderSize);

    if (isNN4) {
      var theLayer = document.layers[menuID];
      theLayer.paDimX = dimX; theLayer.paDimY = dimY;
      theLayer.seDimX = (dimX < menuX + borderSize + menuDimX)?(menuX + borderSize + menuDimX):dimX;
      theLayer.seDimY = (dimY < itemDimY + borderSize)?(itemDimY + borderSize):dimY;
      setMenuSize(menuHolder[menuNum],theLayer.seDimX,theLayer.seDimY);
    }

    showLayer(menuID);
    menuFolderSwitch[menuNum][menuIndex] = true;
  }
}

function showSubMenu(menuNum,menuIndex,menuX,menuY,dimX,dimY,fCount) {

  var menuLength = menuFolder[menuNum][menuIndex].length;
  var menuDimX = menuWidth[menuNum][menuIndex] * charWidth + subMenuFlagSize + charWidthAdd;
  var menuID = "";
  var itemID = "";
  var theLayer = null;
  var itemIndex = 0;
  var dy=0,dx=0;

  var frameWidth,frameHeight,contentWidth,contentHeight,scrollX,scrollY;

    contentWidth=window.document.body.clientWidth;
    contentHeight=window.document.body.clientHeight;
    scrollX=window.document.body.scrollLeft;
    scrollY=window.document.body.scrollTop;


  menuID = getMenu(menuNum,menuIndex,0,0,0,0);
  theLayer = getLayer(menuID);

  var padLeft=getLeft(theLayer);
  var padRight=padLeft+theLayer.padWidth;
  var padTop=getTop(theLayer);
  var padBottom=padTop+theLayer.padHeight;

  if (padBottom-scrollY>contentHeight) {
    dy=contentHeight+scrollY-padBottom;
    if (padTop+dy<scrollY) { dy=scrollY-padTop; }
  }

  if (padRight-scrollX>contentWidth) {
    dx=contentWidth+scrollX-padRight;
    if (padLeft+dx<scrollX) { dx=scrollX-padLeft; }
  }

  if (dy != 0 || dx != 0) {
    menuX += dx; menuY += dy;
    if (menuX < borderSize) { menuX = borderSize; }
    if (menuY < borderSize) { menuY = borderSize; }
  }

  showX(menuNum,menuIndex,menuX,menuY,dimX,dimY,fCount);

}

function showMenu(menuNum,menuIndex,menuX,menuY,dimX,dimY,fCount) {
  var itemDimY = menuY;
  var menuLength = menuFolder[menuNum][menuIndex].length;
  var menuDimX = menuWidth[menuNum][menuIndex] * charWidth + subMenuFlagSize + charWidthAdd;
  var menuID = "";
  var itemID = "";
  var itemIndex = 0;

  if (menuShown != -1 && menuShown != menuNum)
    hideMenu(menuShown,0);

  menuShown = menuNum;


 if (!menuDone[menuNum][menuIndex]) {
    menuDone[menuNum][menuIndex] = true;

    //Mozilla
    if (menuIndex == 0) {
        IHAR = menuDimX;
        myX=0;
    }
    else {
         myX=IHAR;
    }
    myY=menuY;


    for (var i = 0; i < menuLength; i++) {
      itemIndex = menuFolder[menuNum][menuIndex][i];
//      itemDimY +=  (menuItem[menuNum][itemIndex].type != flagSeparator)?charHeight:2;
      itemDimY +=  charHeight;
      itemID = getItem(menuNum,itemIndex,menuDimX,charHeight,menuIndex, i, myY, myX);
    }

    menuID = getMenu(menuNum,menuIndex,menuDimX,itemDimY-menuY, myY, myX);
  }

  if (menuIndex != 0) {
    menuID = getMenu(menuNum,menuIndex,0,0,0,0);
    moveLayerTo(menuID,menuX-borderSize,menuY-borderSize);
    setTimeout(("showSubMenu("+menuNum+","+menuIndex+","+menuX+","+menuY+","+dimX+","+dimY+","+fCount+")"),0);
    return;
  }
  else {
    showX(menuNum,menuIndex,menuX,menuY,dimX,dimY,fCount);
  }
}

function setMenuSize(menuHolderID,menuDimX,menuDimY) {
  document.layers[menuHolderID].clip.width=menuDimX;
  document.layers[menuHolderID].clip.height=menuDimY;
}



function buildMenu(menuArrayName) {

  isIE  = document.all;
  isDOM = document.getElementById
  isOpera7=window.opera //Opera
  isNN4 = document.layers;


  var menuArray = eval(menuArrayName);
  var menuCount = menuArray.length;
  var menuSizeX = 0;
  var menuSizeY = 0;

  if (isDOM || isNN4) {
    for (var i = 0; i < menuCount; i++) {
      menuItemCount = -1;
      menuFolderCount = -1;

      menuItem[i] = new Array();
      menuFolder[i] = new Array();
      menuFolderSwitch[i] = new Array();
      menuWidth[i] = new Array();

      itemLayer[i] = new Array();
      menuLayer[i] = new Array();
      menuDone[i] = new Array();

      menuHolder[i] = menuArray[i][1];

      readMenu(i,menuArray[i][0]);
    }

    if (isNN4) {
      nnWidth = window.innerWidth;
      nnHeight = window.innerHeight;
      window.onResize = reloadMenu;
    }

  }
}



function switchMenu() {

  if (!itemOn)
    if (menuShown != -1)
       Timer = window.setTimeout('switchMenuTimer();', 350);
   return true;

}

function switchMenuTimer() {
  if (!itemOn)
    if (menuShown != -1)
        closeMenu(menuShown);

}


function reloadMenu() {
  if (nnWidth != window.innerWidth || nnHeight != window.innerHeight)
    document.location.reload();
}

function overMenu(menuNum) {

   itemOn = true;

   if (menuShown != -1 && menuShown != menuNum)
       closeMenu(menuShown);

   menuShown = menuNum
   openMenu(menuNum);

}


function outMenu(menuNum) {

   itemOn = false;

}


function openMenu(menuNum) {

   itemOn = true;

   if ((menuNum == 0) ||(menuNum == 4) || (menuNum == 7)) {
     if (menuShown != -1)
        closeMenu(menuShown);
   }
   else {

     var addOffSetX=0;
     var addOffSetY=0;



      var addOffSetX =0;
      var addOffSetY =21;

      if (isIE) 
        addOffSetY =24;


      if( menuNum == 1)
          addOffSetX=-131;
      if( menuNum == 2)
          addOffSetX=-181;
      if( menuNum == 3)
          addOffSetX=-150;
      if( menuNum == 5)
          addOffSetX=-145;
      if( menuNum == 6)
          addOffSetX=-115;

      if (isOpera7) {
        addOffSetX =0;
        addOffSetY =0;
      }

    showMenu(menuNum,0,borderSize + addOffSetX,borderSize + addOffSetY,0,0, -1);
   }
}

function closeMenu(menuNum) {

  if (prevId !=null) {

     var textCSS_1= "CSS1_"  + prevId;
     var textCSS_2= "CSS2_"  + prevId;
      document.getElementById(textCSS_1).style.cssText=offStyle;
      document.getElementById(textCSS_2).style.cssText=offStyle;
  }

  menuShown = -1;
  hideMenu(menuNum,0);
  MM_swapImgRestore();

}

sc1=1;