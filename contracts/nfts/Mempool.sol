pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";
import "../libs/structs/NFTCollection.sol";
import "../libs/structs/NFTProjectData.sol";
import "../interfaces/IParameterControl.sol";
import "../libs/helpers/Base64.sol";
import "../libs/helpers/StringsUtils.sol";
import "../libs/configs/GenerativeProjectDataConfigs.sol";
import "../interfaces/IRandomizer.sol";
import "../services/BFS.sol";

contract Mempool is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, IERC2981Upgradeable {

    address public _admin;
    uint256 private _currentId;
    string public _script; // <script id="snippet-random-code" type="text/javascript">switch(TOKEN_ID){case 1:case 2:case 9:seed="7";break;case 3:seed="20";break;case 4:case 15:seed="4";break;case 5:seed="9";break;case 6:seed="2";break;case 7:seed="5";break;case 8:seed="16";break;case 10:seed="13";break;case 11:seed="3";break;case 12:seed="24";break;case 13:seed="31";break;case 14:seed="32";break;case 16:seed="36";break;case 17:case 20:seed="27";break;case 18:seed="70";break;case 19:seed="23"}if(null==seed){const e="0123456789abcdefghijklmnopqrstuvwsyz";seed=new URLSearchParams(window.location.search).get("seed")||Array(64).fill(0).map((a=>e[Math.random()*e.length|0])).join("")+"i0"}else{let e="seed=";for(let a=0;a<seed.length-e.length;++a)if(seed.substring(a,a+e.length)==e){seed=seed.substring(a+e.length);break}}function cyrb128(e){let a=1779033703,s=3144134277,r=1013904242,t=2773480762;for(let c,d=0;d<e.length;d++)a=s^Math.imul(a^(c=e.charCodeAt(d)),597399067),s=r^Math.imul(s^c,2869860233),r=t^Math.imul(r^c,951274213),t=a^Math.imul(t^c,2716044179);return a=Math.imul(r^a>>>18,597399067),s=Math.imul(t^s>>>22,2869860233),r=Math.imul(a^r>>>17,951274213),t=Math.imul(s^t>>>19,2716044179),[(a^s^r^t)>>>0,(s^a)>>>0,(r^a)>>>0,(t^a)>>>0]}function sfc32(e,a,s,r){return function(){var t=(e>>>=0)+(a>>>=0)|0;return e=a^a>>>9,a=(s>>>=0)+(s<<3)|0,s=(s=s<<21|s>>>11)+(t=t+(r=(r>>>=0)+1|0)|0)|0,(t>>>0)/4294967296}}let mathRand=sfc32(...cyrb128(seed))</script><style>html{font-size:10px}body{background:#000;margin:0;padding:0;color:#fff;position:relative;font-family:Bandeins Strange Variable,sans-serif;font-size:1.6rem}canvas{max-width:100%;max-height:100%;object-fit:contain;position:fixed;display:block;margin:auto;overflow:auto;top:0;bottom:0;left:0;right:0}</style></head><body><script id="core" type="text/javascript">function randomValueIndexArrayInt(t,n){return t%n}function cyrb128(t){let n=1779033703,r=3144134277,o=1013904242,e=2773480762;for(let c,i=0;i<t.length;i++)c=t.charCodeAt(i),n=r^Math.imul(n^c,597399067),r=o^Math.imul(r^c,2869860233),o=e^Math.imul(o^c,951274213),e=n^Math.imul(e^c,2716044179);return n=Math.imul(o^n>>>18,597399067),r=Math.imul(e^r>>>22,2869860233),o=Math.imul(n^o>>>17,951274213),e=Math.imul(r^e>>>19,2716044179),[(n^r^o^e)>>>0,(r^n)>>>0,(o^n)>>>0,(e^n)>>>0]}function sfc32_c(t,n,r,o){let e=(t>>>=0)+(n>>>=0)|0;return t=n^n>>>9,n=(r>>>=0)+(r<<3)|0,e=e+(o=(o>>>=0)+1|0)|0,r=(r=r<<21|r>>>11)+e|0,(e>>>0)/4294967296}function consistentRand(t,n,r){return n+sfc32_c(...cyrb128(t.toString()))*(r-n)}function consistentSeed(t){return sfc32_c(...cyrb128(t.toString()))}function getRandomBool(t,n,r){return sfc32_c(...cyrb128(t.toString()))<.5?n:r}function modifyColor(t,n){return t}function traits(t,n){let r=[],o=0;for(let n=0;n<t.length;n++)o+=t[n][1],r[n]=o;const e=Math.floor(consistentRand(n,0,o));for(let n=0;n<r.length;n++)if(e<r[n])return t[n]}</script><script id="utils" type="text/javascript">function decimalAdjust(e,t,r){if(e=String(e),!["round","floor","ceil"].includes(e))throw new TypeError("The type of decimal adjustment must be one of 'round', 'floor', or 'ceil'.");if(r=Number(r),t=Number(t),r%1!=0||Number.isNaN(t))return NaN;if(0===r)return Math[e](t);const[o,n=0]=t.toString().split("e"),i=Math[e](`${o}e${n-r}`),[u,d=0]=i.toString().split("e");return Number(`${u}e${+d+r}`)}const round10=(e,t)=>decimalAdjust("round",e,t),floor10=(e,t)=>decimalAdjust("floor",e,t),ceil10=(e,t)=>decimalAdjust("ceil",e,t);function getRandomBetween(e,t){return mathRand()*(t-e)+e}</script><script id="traits" type="text/javascript">const chainHash=1e9*mathRand(),ColorPalettes=[["Candy Dream",10,["#34B1F5","#E94787","#F9ED32"]],["24K MAGIC",10,["#b48811","#a2790d","#ebd197","#bb9b49"]],["Enchanted Meadow",10,["#00ff03","#9BF373","#F6E086"]],["Aqua Dream",10,["#2A9ECF","#7CE7F5","#0AB692"]],["B&W",10,["#555","#fff"]],["Fiery Sunset",10,["#E73737","#F3DABD","#F66528"]],["Blooming Romance",10,["#FBD3E9","#BB377D"]],["Kaleidoscope Spectrum",10,["#ff0002","#f26522","#fdff00","#00ff03","#01fffe","#0000ff","#ff00ff"]],["Tropical Zest",10,["#ff0000","#ffcc00","#2dc937","#00ff03"]]],ColorDirections=[["Vertical",100,"vertical"],["Horizontal",10,"horizontal"]],InputLines=[["PEACE",10,"perfect-bezier"],["NOISE",10,"noise-0"],["CHAOS",10,"random-0"]],OutputLines=[["NOISE",10,"noise-0"],["CHAOS",10,"random-0"],["PEACE",10,"perfect-bezier"]],InputDensity=[["88",5,88],["66",10,66]],OutputDensity=[["88",5,88],["66",10,66]],BridgeVerticals=[["CENTER",1,[.5,0]]],BridgeHorizontals=[["CENTER",1,[.5,0]]],BridgeLengths=[["NORMAL",5,[.05,.2]],["SHORT",1,[.001,.05]]],NodeShapes=[["DIAMOND",10,4],["CIRCLE",10,-1],["HEXAGON",10,6],["PYRAMID",10,3]],NodeAligns=[["ALIGN",1e5,!0],["NOT ALIGN",10,!1]],LineTypes=[["NO DASH",1e4,!1],["DASHED",10,!0]],Mirrors=[["TRUE",1,!0],["FALSE",100,!1]];let outx_colors=traits(ColorPalettes,chainHash),outx_colorDirections=traits(ColorDirections,chainHash),outx_inputLines=traits(InputLines,chainHash),outx_outputLines=traits(OutputLines,chainHash),outx_inputDensity=traits(InputDensity,chainHash),outx_outputDensity=traits(OutputDensity,chainHash),outx_bridgeVertical=traits(BridgeVerticals,chainHash),outx_bridgeHorizontal=traits(BridgeHorizontals,chainHash),outx_bridgeLength=traits(BridgeLengths,chainHash),outx_nodeShape=traits(NodeShapes,chainHash),outx_nodeAlign=traits(NodeAligns,chainHash),outx_lineType=traits(LineTypes,chainHash),outx_mirror=traits(Mirrors,chainHash);if(TOKEN_ID<=20||Number(TOKEN_ID)<=20)switch(outx_mirror=["TRUE",1,!0],outx_inputDensity=["88",5,88],outx_outputDensity=["88",5,88],outx_colorDirections=["Vertical",100,"vertical"],TOKEN_ID){case 1:outx_inputLines=InputLines[2],outx_colors=ColorPalettes[7];break;case 2:outx_inputLines=InputLines[1],outx_colors=ColorPalettes[6];break;case 3:outx_inputLines=InputLines[1],outx_colors=ColorPalettes[5];break;case 4:outx_inputLines=InputLines[2],outx_colors=ColorPalettes[0];break;case 5:case 10:outx_inputLines=InputLines[1],outx_colors=ColorPalettes[1];break;case 6:outx_inputLines=InputLines[2],outx_colors=ColorPalettes[2];break;case 7:outx_inputLines=InputLines[2],outx_colors=ColorPalettes[6];break;case 8:outx_inputLines=InputLines[2],outx_colors=ColorPalettes[0],outx_colorDirections=ColorDirections[1];break;case 9:outx_inputLines=InputLines[1],outx_colors=ColorPalettes[7];break;case 11:case 19:outx_inputLines=InputLines[1],outx_colors=ColorPalettes[2];break;case 12:case 17:outx_inputLines=InputLines[1],outx_colors=ColorPalettes[3];break;case 13:outx_inputLines=InputLines[1],outx_colors=ColorPalettes[8];break;case 14:outx_inputLines=InputLines[2],outx_colors=ColorPalettes[4];break;case 15:outx_inputLines=InputLines[2],outx_colors=ColorPalettes[1];break;case 16:outx_inputLines=InputLines[0],outx_colors=ColorPalettes[5],outx_lineType=LineTypes[0];break;case 18:outx_inputLines=InputLines[1],outx_colors=ColorPalettes[4];break;case 20:outx_inputLines=InputLines[2],outx_colors=ColorPalettes[3]}outx_mirror[2]&&(outx_outputLines=outx_inputLines),window.$generativeTraits={"Color Palette":outx_colors[0],"Color Direction":outx_colorDirections[0],"Input Styles":outx_inputLines[0],"Output Styles":outx_outputLines[0],"Input Density":outx_inputDensity[0],"Output Density":outx_outputDensity[0],"Bridge Length":outx_bridgeLength[0],"Node Shape":outx_nodeShape[0],"Node Alignment":outx_nodeAlign[0],"Line Type":outx_lineType[0],Mirror:outx_mirror[0]};for(const t in window.$generativeTraits)console.log(`${t}: ${window.$generativeTraits[t]}`);console.log("--------------------------")</script><script id="index" type="text/javascript">let maxR,vin,vout,inputCount,outputCount,startColor,endColor,gradientColors,inputGradientUnit,outputGradientUnit,mX,mY,gW,gH,stepY,x1,y1,x2,y2,cp1x,cp1y,cp2x,cp2y,x1n,y1n,x2n,y2n,cp1nX,cp1nY,cp2nX,cp2nY,randomBezierX,randomBezierY,xx1,yy1,xx2,yy2,randomX,randomY,nres,namp,r34,n3deg,n4deg,rd3,rd4,inRadius,outRadius,midPointX,midPointY,midRangeYper,midRangeY,inStrokeWeight,outStrokeWeight,isDashed,isMirror=outx_mirror[2],inputs=[],outputs=[],shapeAlpha=1,smooth=Math.round(mathRand()),inputGradientFill=[],outputGradientFill=[],controlPointPercenX=.5,controlPointPercenY=1.15-controlPointPercenX,colorPalette=outx_colors[2],bg="#141725";function generateInputVariables(){if(mX=mY=0,mY=inputCount<20?height*map(inputCount,1,19,.3,.05):0,gW=width-2*mX,gH=height-2*mY,stepY=gH/(inputCount-1),"perfect-bezier"===outx_inputLines[2]){mathRand()<=.5?(yy1=randomStep(-.5,.5,10),xx1=max(randomStep(0,1,10),yy1+.5),yy2=randomStep(-.25,.75,10),xx2=max(randomStep(0,1.25,10),yy2+.5)):(dice2=mathRand(),xx1=dice2<.8?.1*Math.round(10*mathRand()):1.1+.1*Math.round(3*mathRand()),yy1=dice2<.8?xx1+.075*Math.round(15*mathRand()):xx1+.1*Math.round(7*mathRand()),xx2=.1*Math.round(5*mathRand()),yy2=xx2+.25+.15*Math.round(15*mathRand()))}else if("noise-0"===outx_inputLines[2]){let t=.1;mathRand()<=.3?(yy1=randomStep(-.5,.5,10),xx1=max(randomStep(0,1,10),yy1+.5),yy2=randomStep(-.5,.5,10),xx2=max(randomStep(0,1,10),yy2+.5)):t>.5?(xx1=randomStep(0,1.25,10),yy1=max(randomStep(1.5,2.75,10),xx1+1.5),xx2=randomStep(-.125,.5,10),yy2=max(randomStep(1.875,3,10),xx2+2)):(xx2=randomStep(0,1.25,10),yy2=max(randomStep(1.5,3.25,10),xx2+1.5),xx1=randomStep(-.125,.5,10),yy1=max(randomStep(1.875,2.75,10),xx1+2)),r34param=.25*random([-3,-2,-1,0,1,2,3]),n3deg=90*random([1,2,3,4,5,6,7,8]),n4deg=90*random([1,2,3,4,5,6,7,8])}else rd3=1,rd4=1}function generateInput(){generateInputVariables(),inputs=[];for(let t=0;t<inputCount;t++){0==outx_nodeAlign[2]&&(n=map(noise(t),0,1,.5,1.5),mX=n*width*.05,mY=n*height*.05,gH=height-2*mY,stepY=gH/(inputCount-1)*map(n,.5,1.5,.9,1.1)),x1=mX,y1=mY+stepY*t,midStepY=midRangeY/(inputCount-1),x2=midPointX,y2=midPointY-.5*midRangeY+midStepY*t,midIndex=floor((inputCount-1)/2);const o=getHorizontalGradient(x1,y1,x2,y2,colorPalette);switch(outx_inputLines[2]){case"perfect-bezier":1===smooth?(inputCount%2==0?(randomX=t>=inputCount/2?abs(inputCount/2-(t+1)):inputCount/2-t,randomY=randomX):(randomX=abs(floor(inputCount/2)-t),randomY=randomX),randomX*=xx1/inputCount,randomY*=yy1/inputCount):(randomX=0,randomY=0),cp1x=x1+(x2-x1)*(xx1+randomX),cp1y=y1+(y2-y1)*(yy1+randomY),cp2x=x2-(x2-x1)*(xx2+randomX),cp2y=y2-(y2-y1)*(yy2+randomY);break;case"noise-0":1===smooth?(inputCount%2==0?(randomX=t>=inputCount/2?abs(inputCount/2-(t+1)):inputCount/2-t,randomY=randomX):(randomX=abs(floor(inputCount/2)-t),randomY=randomX),randomX*=xx1/inputCount,randomY*=yy1/inputCount):(randomX=0,randomY=0),r34=(y2-y1)*r34param,n3=sin(map(t,0,inputCount,-n3deg,n3deg))*r34,n4=cos(map(t,0,inputCount,-n4deg,n4deg))*r34,cp1x=x1+(x2-x1)*(xx1+randomX)+n3,cp1y=y1+(y2-y1)*(yy1+randomY)+n4,cp2x=x2-(x2-x1)*(xx2+randomX)+n3,cp2y=y2-(y2-y1)*(yy2+randomY)+n4;break;case"random-0":let n=getRandomBezier(inputCount),{rd1:o,rd2:e}=n[t];if(cp1x=x1+(x2-x1)*o*rd3,cp1y=y1+0*(y2-y1),cp2x=x2-(x2-x1)*e*rd4,cp2y=y2-0*(y2-y1),t!=inputCount-1){let o=t+1,e=n[o],a=e.rd1,r=e.rd2;x1n=mX,y1n=mY+stepY*o,x2n=midPointX,y2n=midPointY-.5*midRangeY+midStepY*o,cp1nX=x1n+(x2n-x1n)*a*rd3,cp1nY=y1n+0*(y2n-y1n),cp2nX=x2n-(x2n-x1n)*r*rd4,cp2nY=y2n-0*(y2n-y1n)}}inputs.push({p1:{x:x1,y:y1},p2:{x:x2,y:y2},cp1:{x:cp1x,y:cp1y},cp2:{x:cp2x,y:cp2y},p1n:{x:x1n,y:y1n},p2n:{x:x2n,y:y2n},cp1n:{x:cp1nX,y:cp1nY},cp2n:{x:cp2nX,y:cp2nY},horizontalGrad:o})}}function drawInput(){switch(setLineDash(0==isDashed?[0]:[map(inStrokeWeight/maxR,.1,10,3,30)*maxR]),outx_inputLines[2]){case"noise-0":shapeAlpha=constrain(map(midRangeYper,.01,.4,1,3)/inputCount,.025,.05);break;case"random-0":shapeAlpha=constrain(map(midRangeYper,.01,.4,2,10)/inputCount,.035,.2);break;default:shapeAlpha=constrain(map(midRangeYper,.01,.4,2,4)/inputCount,.015,.075)}for(let t=0;t<inputs.length;t++){let{p1:n,p2:o,cp1:e,cp2:a,p1n:r,p2n:i,cp1n:d,cp2n:u,horizontalGrad:p}=inputs[t];push(),strokeWeight(inStrokeWeight),"vertical"==outx_colorDirections[2]?(stroke(inputGradientFill[t]),t<inputs.length-1&&drawGradientShape(n,o,e,a,0,0,0,0,inputGradientFill[t],shapeAlpha),noFill(),drawLine(n,o,e,a),setLineDash([0]),drawStartEndPoint(n,o,inRadius,inputGradientFill[t],inputGradientFill[t],bg,inStrokeWeight,t,inputs.length)):"horizontal"==outx_colorDirections[2]&&(drawingContext.strokeStyle=p,t<inputs.length-1&&drawGradientShape(n,o,e,a,0,0,0,0,p,shapeAlpha/1.25),drawLine(n,o,e,a),setLineDash([0]),drawStartEndPoint(n,o,inRadius,startColor,endColor,bg,inStrokeWeight,t,inputs.length)),pop()}}function generateOutputVariables(){if(mX=mY=0,gW=width-2*mX,gH=height-2*mY,stepY=gH/(outputCount-1),"perfect-bezier"===outx_outputLines[2]){mathRand()<=.5?(yy2=randomStep(-.5,.5,10),xx2=max(randomStep(0,1,10),yy2+.5),yy1=randomStep(-.5,.5,10),xx1=max(randomStep(0,1,10),yy1+.5)):(dice2=mathRand(),xx2=dice2<.8?.1*Math.round(10*mathRand()):1.1+.1*Math.round(3*mathRand()),yy2=dice2<.8?xx2+.075*Math.round(15*mathRand()):xx2+.125*Math.round(7*mathRand()),xx1=.1*Math.round(5*mathRand()),yy1=xx1+.25+.15*Math.round(15*mathRand()))}else if("noise-0"===outx_outputLines[2]){let t=mathRand(),n=mathRand();t<=.3?(yy2=randomStep(-.5,.5,10),xx2=max(randomStep(0,1,10),yy2+.5),yy1=randomStep(-.5,.5,10),xx1=max(randomStep(0,1,10),yy1+.5)):n>.5?(xx1=randomStep(0,1.25,10),yy1=max(randomStep(1.5,2.75,10),xx1+1.5),xx2=randomStep(-.125,.5,10),yy2=max(randomStep(1.875,3,10),xx2+2)):(xx2=randomStep(0,1.25,10),yy2=max(randomStep(1.5,3.25,10),xx2+1.5),xx1=randomStep(-.125,.5,10),yy1=max(randomStep(1.875,2.75,10),xx1+2)),r34param=.25*random([-3,-2,-1,0,1,2,3]),n3deg=90*random([1,2,3,4,5,6,7,8]),n4deg=90*random([1,2,3,4,5,6,7,8])}else rd4=.1*(5+Math.round(5*mathRand())),rd3=.1*Math.round(5*mathRand())}function generateOutput(){generateOutputVariables(),outputs=[];for(let t=0;t<outputCount;t++){0==outx_nodeAlign[2]&&(n=map(noise(t),0,1,.5,1.5),mX=n*width*.05,mY=n*height*.05,gH=height-2*mY,stepY=gH/(outputCount-1)*map(n,.5,1.5,.9,1.1)),x2=width-mX,y2=mY+stepY*t,midStepY=midRangeY/(outputCount-1),x1=midPointX,y1=midPointY-.5*midRangeY+midStepY*t,midIndex=floor((outputCount-1)/2);const o=getHorizontalGradient(x2,y2,x1,y1,colorPalette);switch(outx_outputLines[2]){case"perfect-bezier":1===smooth?(outputCount%2==0?(randomX=t>=outputCount/2?abs(outputCount/2-(t+1)):outputCount/2-t,randomY=randomX):(randomX=abs(floor(outputCount/2)-t),randomY=randomX),randomX*=xx2/outputCount,randomY*=yy2/outputCount):(randomX=0,randomY=0),cp1x=x1+(x2-x1)*(xx1+randomX),cp1y=y1+(y2-y1)*(yy1+randomY),cp2x=x2-(x2-x1)*(xx2+randomX),cp2y=y2-(y2-y1)*(yy2+randomY);break;case"noise-0":1===smooth?(outputCount%2==0?(randomX=t>=outputCount/2?abs(outputCount/2-(t+1)):outputCount/2-t,randomY=randomX):(randomX=abs(floor(outputCount/2)-t),randomY=randomX),randomX*=xx1/outputCount,randomY*=yy1/outputCount):(randomX=0,randomY=0),r34=(y1-y2)*r34param,n3=sin(map(t,0,outputCount,-n3deg,n3deg))*r34,n4=cos(map(t,0,outputCount,-n4deg,n4deg))*r34,cp1x=x1+(x2-x1)*(xx1+randomX)+n3,cp1y=y1+(y2-y1)*(yy1+randomY)+n4,cp2x=x2-(x2-x1)*(xx2+randomX)+n3,cp2y=y2-(y2-y1)*(yy2+randomY)+n4;break;case"random-0":let n=getRandomBezier(outputCount),{rd1:o,rd2:e}=n[t];if(cp1x=x1+(x2-x1)*o*1,cp1y=y1+0*(y2-y1),cp2x=x2-(x2-x1)*e*1,cp2y=y2-0*(y2-y1),t!=outputCount-1){let o=t+1,e=n[o],a=e.rd1,r=e.rd2;x2n=width-mX,y2n=mY+stepY*o,x1n=midPointX,y1n=midPointY-.5*midRangeY+midStepY*o,cp1nX=x1n+(x2n-x1n)*a*1,cp1nY=y1n+0*(y2n-y1n),cp2nX=x2n-(x2n-x1n)*r*1,cp2nY=y2n-0*(y2n-y1n)}}outputs.push({p1:{x:x1,y:y1},p2:{x:x2,y:y2},cp1:{x:cp1x,y:cp1y},cp2:{x:cp2x,y:cp2y},p1n:{x:x1n,y:y1n},p2n:{x:x2n,y:y2n},cp1n:{x:cp1nX,y:cp1nY},cp2n:{x:cp2nX,y:cp2nY},horizontalGrad:o})}}function drawOutput(){switch(setLineDash(0==isDashed?[0]:[map(outStrokeWeight/maxR,.1,10,3,30)*maxR]),outx_outputLines[2]){case"noise-0":shapeAlpha=constrain(map(midRangeYper,.01,.4,1,3)/outputCount,.025,.05);break;case"random-0":shapeAlpha=constrain(map(midRangeYper,.01,.4,2,10)/outputCount,.035,.2);break;default:shapeAlpha=constrain(map(midRangeYper,.01,.4,2,4)/outputCount,.015,.075)}if(isMirror)for(let t=0;t<outputs.length;t++){let{p1:n,p2:o,cp1:e,cp2:a,p1n:r,p2n:i,cp1n:d,cp2n:u,horizontalGrad:p}=inputs[t];n.x=width-n.x,r.x=width-r.x,e.x=width-e.x,d.x=width-d.x,a.x=width-a.x,u.x=width-u.x,push(),strokeWeight(outStrokeWeight),"vertical"==outx_colorDirections[2]?(stroke(outputGradientFill[t]),t<outputs.length-1&&drawGradientShape(o,n,a,e,0,0,0,0,outputGradientFill[t],shapeAlpha),noFill(),drawLine(o,n,a,e),setLineDash([0]),drawStartEndPoint(o,n,outRadius,outputGradientFill[t],outputGradientFill[t],bg,outStrokeWeight,t,outputs.length)):"horizontal"==outx_colorDirections[2]&&(drawingContext.strokeStyle=p,t<outputs.length-1&&drawGradientShape(o,n,a,e,0,0,0,0,p,shapeAlpha/1.25),drawLine(o,n,a,e),setLineDash([0]),drawStartEndPoint(o,n,outRadius,startColor,endColor,bg,outStrokeWeight,t,outputs.length)),pop()}else for(let t=0;t<outputs.length;t++){let{p1:n,p2:o,cp1:e,cp2:a,p1n:r,p2n:i,cp1n:d,cp2n:u,horizontalGrad:p}=outputs[t];push(),strokeWeight(outStrokeWeight),"vertical"==outx_colorDirections[2]?(stroke(outputGradientFill[t]),t<outputs.length-1&&drawGradientShape(n,o,e,a,0,0,0,0,outputGradientFill[t],shapeAlpha),noFill(),drawLine(n,o,e,a),setLineDash([0]),drawStartEndPoint(n,o,outRadius,outputGradientFill[t],outputGradientFill[t],bg,outStrokeWeight,t,outputs.length)):"horizontal"==outx_colorDirections[2]&&(drawingContext.strokeStyle=p,t<outputs.length-1&&drawGradientShape(n,o,e,a,0,0,0,0,p,shapeAlpha/1.25),drawLine(n,o,e,a),setLineDash([0]),drawStartEndPoint(n,o,outRadius,startColor,endColor,bg,outStrokeWeight,t,outputs.length)),pop()}}function generateColor(){startColor=outx_colors[2][0],endColor=outx_colors[2][outx_colors[2].length-1],gradientColors=[],gradientColors=getGradientColors(startColor,endColor,outx_colors[2],height),inputGradientUnit=height/(inputCount-1),outputGradientUnit=height/(outputCount-1),inputGradientFill=[];for(let t=0;t<inputCount;t++)inputGradientFill.push(getGradientColorAtPosition(gradientColors,inputGradientUnit*t/height));for(let t=0;t<outputCount;t++)outputGradientFill.push(getGradientColorAtPosition(gradientColors,outputGradientUnit*t/height))}function setup(){noLoop(),createCanvas(windowWidth,windowHeight),randomSeed(consistentSeed(chainHash)),noiseSeed(consistentSeed(chainHash)),rectMode(CENTER),angleMode(DEGREES),maxR=Math.max(Math.min(width,height)/1024,1);let t=outx_bridgeHorizontal[2];midPointX=width*(t[0]+.1*t[1]*mathRand());let n=outx_bridgeVertical[2];midPointY=height*(n[0]+.2*n[1]*mathRand());let o=outx_bridgeLength[2];midRangeYper=randomStep(o[0],o[1],20),midRangeY=height*midRangeYper,vin=outx_inputDensity[2],vout=outx_outputDensity[2],inputCount=Math.min(Math.max(vin,0),88),outputCount=Math.min(Math.max(vout,0),88),inStrokeWeight=constrain(40/inputCount,.1,10)*maxR,outStrokeWeight=constrain(40/outputCount,.1,10)*maxR,inRadius=constrain(1*height/(inputCount-1),.01,50)*maxR,outRadius=constrain(1*height/(outputCount-1),.01,50)*maxR,isDashed=outx_lineType[2],generateColor(),background(bg),generateInput(),drawInput(),generateOutput(),drawOutput()}function draw(){}function windowResized(){resizeCanvas(windowWidth,windowHeight)}function getGradientColors(t,n,o,e){let a=[],r=e/(o.length+1),i=color(t),d=color(n);a.push(i);for(let t=0;t<o.length;t++){let n=color(o[t]);for(let t=1;t<=r;t++){let o=lerpColor(i,n,t/r);a.push(o)}i=n}for(let t=1;t<r;t++){let n=lerpColor(i,d,t/r);a.push(n)}if(a.push(d),a.length>e)a.splice(e);else if(a.length<e){let t=a[a.length-1];for(;a.length<e;)a.push(t)}return a}function getGradientColorAtPosition(t,n){let o=t.length,e=Math.floor(n*o);return e>=o&&(e=o-1),t[e]}function hexToRgb(t){t=t.replace("#","");var n=parseInt(t,16);return color(n>>16&255,n>>8&255,255&n)}function getHorizontalGradient(t,n,o,e,a){var r=drawingContext.createLinearGradient(t,n,o,e);let i=0;for(let t=0;t<a.length;t++)r.addColorStop(i,a[t]),i+=1/(a.length-1);return r}function drawStartEndPoint(t,n,o,e,a,r,i,d,u){let p=outx_nodeShape[2];fill(r),stroke(e),-1===p?ellipse(t.x,t.y,o):drawShape(t.x,t.y,p,o,e,i,d,u),stroke(a),-1===p?ellipse(n.x,n.y,o):drawShape(n.x,n.y,p,o,a,i,d,u)}function drawShape(t,n,o,e,a,i,d,u){let p=0,x=1,l=u>22?(30*TAU-2*PI)/u:30*TAU/u;switch(o){case 3:p=-90,x=.75;break;case 4:p=0,x=.65;break;case 6:p=-90,x=.5}push(),stroke(a),strokeWeight(i),beginShape(),translate(t,n);for(let t=0;t<o+1;t++)angle=360/o*t+p+d*l,r=e*x,vertex(r*cos(angle),r*sin(angle));endShape(),pop()}function drawControlPoint(t,n,o=5){stroke("white"),ellipse(t.x,t.y,o),ellipse(n.x,n.y,o)}function drawGradientShape(t,n,o,e,a,r,i,d,u,p){push(),translate(0,0),blendMode(ADD),drawingContext.fillStyle=u,drawingContext.globalAlpha=p,noStroke(),beginShape(),vertex(t.x,t.y),bezierVertex(o.x,o.y,e.x,e.y,n.x,n.y),vertex(r.x,r.y),bezierVertex(d.x,d.y,i.x,i.y,a.x,a.y),endShape(CLOSE),drawingContext.globalAlpha=1,pop()}function drawLine(t,n,o,e){noFill(),beginShape(),vertex(t.x,t.y),bezierVertex(o.x,o.y,e.x,e.y,n.x,n.y),endShape()}function getRandomBezier(t){let n,o,e=[];for(let a=0;a<t;a++)t%2==0?(n=a>=t/2?abs(t/2-(a+1)):t/2-a,o=n):(n=abs(floor(t/2)-a),o=n),n*=.001,o*=.001,n+=.1*Math.round(12*mathRand()),o+=.1*Math.round(12*mathRand()),e.push({rd1:n,rd2:o});return e}function randomStep(t,n,o){let e=t+mathRand()*(n-t),a=round10((n-t)/(o-1),-10);return e=t+Math.round((e-t)/a)*a,e}function makeFilter(){colorMode(HSB,360,100,100,100),drawingContext.shadowColor=color(0,0,5,95),overAllTexture=createGraphics(windowWidth,windowHeight),overAllTexture.loadPixels();for(var t=0;t<width;t++)for(var n=0;n<height;n++)overAllTexture.set(t,n,color(0,0,70,noise(t/3,n/3,t*n/50)*random(10,25)*1.5));overAllTexture.updatePixels()}async function keyPressed(){"s"!==key&&"S"!==key||save("mempool.png"),"Enter"===key&&location.reload()}function setLineDash(t){drawingContext.setLineDash(t)}function getRandomInt(t,n){return t+Math.floor(mathRand()*(n-t+1))}function windowResized(){window.location.reload(),resizeCanvas(windowWidth,windowHeight,!0)}"B&W"==outx_colors[0]&&(bg="#161616")</script><main></main></body></html>

    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;

    function initialize(
        string memory name,
        string memory symbol,
        address admin
    ) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;

        __ERC721_init(name, symbol);
        __ReentrancyGuard_init();
        __ERC721Pausable_init();
        __Ownable_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeScript(string memory newScript) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _script = newScript;
    }

    /* @Mint */
    function tokenIdToHash(uint256 tokenId) external view returns (bytes32) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        if (_ownersAndHashSeeds[tokenId]._seed == 0) {
            return 0;
        }
        return keccak256(abi.encode(_ownersAndHashSeeds[tokenId]._seed));
    }

    function mint(address to) public payable nonReentrant returns (uint256 tokenId) {
        require(_currentId < 512, Errors.REACH_MAX);
        //        require(msg.sender == _admin);
        _currentId++;
        tokenId = _currentId;
        _safeMint(to, tokenId);

        bytes32 seed = generateTokenHash(tokenId);
        _setTokenSeed(tokenId, seed);
    }

    function generateTokenHash(uint256 tokenId) internal returns (bytes32 tokenHash) {
        tokenHash = keccak256(
            abi.encodePacked(
                tokenId,
                block.number,
                blockhash(block.number - 1),
                block.timestamp
            )
        );
    }

    function _setTokenSeed(uint256 tokenId, bytes32 seed) internal {
        require(_ownersAndHashSeeds[tokenId]._seed == bytes12(0), Errors.TOKEN_HAS_SEED);
        require(seed != bytes12(0), Errors.ZERO_SEED);
        _ownersAndHashSeeds[tokenId]._seed = bytes12(seed);
    }

    /* @Override on ERC-721*/

    function tokenURI(uint256 tokenId) override public view returns (string memory result) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        result = string(abi.encodePacked("https://api-moderator.foc.gg/dgame-moderator/api/mempool/?address=", StringsUpgradeable.toHexString(address(this)), "&token=", StringsUpgradeable.toString(tokenId)));
    }

    function variableScript(bytes32 seed, uint256 tokenId) public view returns (string memory result) {
        result = '<script id="snippet-contract-code" type="text/javascript">';
        result = string(abi.encodePacked(result, "let seed='", StringsUtils.toHex(seed), "';"));
        result = string(abi.encodePacked(result, "let TOKEN_ID='", StringsUpgradeable.toString(tokenId), "';"));
        result = string(abi.encodePacked(result, "</script>"));
    }

    function tokenHTML(uint256 tokenId) external view returns (string memory result) {
        result = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>The Mempool Collection</title><script sandbox="allow-scripts" type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.5.0/p5.min.js"></script>';
        result = string(abi.encodePacked(result, variableScript(this.tokenIdToHash(tokenId), tokenId)));
        result = string(abi.encodePacked(result, _script));
    }

    /** @dev EIP2981 royalties implementation. */
    // EIP2981 standard royalties return.
    function royaltyInfo(uint256 projectId, uint256 _salePrice) external view override
    returns (address receiver, uint256 royaltyAmount){
        receiver = _admin;
        royaltyAmount = (_salePrice * 500) / Royalty.MINT_PERCENT_ROYALTY;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._transfer(from, to, tokenId);
        _ownersAndHashSeeds[tokenId]._owner = to;
    }

    function ownerOf(uint256 tokenId)
    public
    view
    virtual
    override
    returns (address)
    {
        return _ownersAndHashSeeds[tokenId]._owner;
    }

    function _exists(uint256 tokenId) internal view virtual override returns (bool) {
        return _ownersAndHashSeeds[tokenId]._owner != Errors.ZERO_ADDR;
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        super._mint(to, tokenId);
        _ownersAndHashSeeds[tokenId]._owner = to;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        delete _ownersAndHashSeeds[tokenId]._owner;
    }
}
