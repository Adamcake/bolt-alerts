import{a7 as Xo,a8 as Co,M as Ko,N as No,Z as k,g as o,x as n,O as Jo,Q as Qo,T as Yo,U as w,$ as j,Y as g,V as e,a0 as U,a9 as N,W as _,X as Zo,_ as x,a2 as re,a3 as zo}from"./legacy-QOGUSj2l.js";import{b as z}from"./input-DTNHJt4B.js";import{i as $o,R as a}from"./interfaces-GTu-jGPm.js";function Ro(t,r,l){if(t.multiple)return oa(t,r);for(var u of t.options){var f=ie(u);if($o(f,r)){u.selected=!0;return}}(!l||r!==void 0)&&(t.selectedIndex=-1)}function ea(t,r){Co(()=>{var l=new MutationObserver(()=>{var u=t.__value;Ro(t,u)});return l.observe(t,{childList:!0,subtree:!0,attributes:!0,attributeFilter:["value"]}),()=>{l.disconnect()}})}function J(t,r,l=r){var u=!0;Xo(t,"change",f=>{var T=f?"[selected]":":checked",A;if(t.multiple)A=[].map.call(t.querySelectorAll(T),ie);else{var pe=t.querySelector(T)??t.querySelector("option:not([disabled])");A=pe&&ie(pe)}l(A)}),Co(()=>{var f=r();if(Ro(t,f,u),u&&f===void 0){var T=t.querySelector(":checked");T!==null&&(f=ie(T),l(f))}t.__value=f,u=!1}),ea(t)}function oa(t,r){for(var l of t.options)l.selected=~r.indexOf(ie(l))}function ie(t){return"__value"in t?t.__value:t.value}const aa=(t,r,l,u,f,T,A)=>{switch(o(r)){case a.afktimer:n(l,60*14),n(u,o(l));break;case a.buff:n(f,null),n(u,null),n(T,null);break;case a.chat:n(A,null);break;case a.model:n(f,null);break;case a.popup:n(A,null);break;case a.stat:n(f,null),n(u,null);break;case a.xpgain:n(u,null);break}},ta=(t,r)=>fetch("https://bolt-api/send-message",{method:"POST",body:r()}),na=()=>fetch("https://bolt-api/close-request");var la=w('<p class="text-[16pt] font-bold">New Rule</p> <p class="text-[10pt]">A rule decides when you want to be alerted. When this condition becomes active, the ruleset will send you an alert.</p>',1),ra=w('<p class="text-[16pt] font-bold">Edit Rule</p>'),ia=(t,r,l)=>n(r,Math.floor(o(l)*1e6)),pa=w('<label for="2">Timeout (seconds):</label> <br> <input id="2" type="number" class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0">',1),ua=w('<label for="5">This number:</label> <br> <input id="5" type="number" class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0">',1),sa=w(`<label for="3">Buff or debuff:</label> <br> <select id="3" class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0"><optgroup class="text-black" label="Potions"><option>Adrenaline Potion Cooldown</option> <option>Aggression Potion</option> <option>Antifire</option> <option>Antipoison</option> <option>Overload</option> <option>Perfect Plus</option> <option>Poisonous</option> <option>Powerburst Cooldown</option> <option>Prayer Renewal</option> <option>Spirit Attraction Potion</option></optgroup><optgroup class="text-black" label="Powders"><option>Powder of Burials</option> <option>Powder of Defence</option> <option>Powder of Item Protection</option> <option>Powder of Penance</option> <option>Powder of Protection</option> <option>Powder of Pulverising</option></optgroup><optgroup class="text-black" label="Incense"><option>Avantoe Incense</option> <option>Cadantine Incense</option> <option>Dwarfweed Incense</option> <option>Fellstalk Incense</option> <option>Guam Incense</option> <option>Harralander Incense</option> <option>Irit Incense</option> <option>Kwuarm Incense</option> <option>Lantadyme Incense</option> <option>Marrentill Incense</option> <option>Ranarr Incense</option> <option>Snapdragon Incense</option> <option>Spiritweed Incense</option> <option>Tarromin Incense</option> <option>Toadflax Incense</option> <option>Torstol Incense</option> <option>Wergali Incense</option></optgroup><optgroup class="text-black" label="Miscellaneous"><option>Animate Dead</option> <option>Archaeologist's Tea</option> <option>Aura</option> <option>Bonfire</option> <option>Cannonballs</option> <option>Cannon Timer</option> <option>Cinder Core</option> <option>Clan Citadel Buff</option> <option>Crystal Mark</option> <option>Darkness</option> <option>Elven Ritual Shard Cooldown</option> <option>Excalibur Cooldown</option> <option>Firelighter</option> <option>God Book</option> <option>Grimoire</option> <option>Hi-spec Monocle</option> <option>Luminite Injector</option> <option>Material Manual</option> <option>Porter</option> <option>Pulse Core</option> <option>Roar of Osseous</option> <option>Rock of Resilience</option> <option>Scrimshaw</option> <option>Sign of Life</option> <option>Stone of Jas (glacor cavern)</option> <option>Summon</option> <option>Tarpaulin Sheet</option> <option>Valentine's Flip</option> <option>Valentine's Slam</option> <option>Wise Perk</option></optgroup></select> <br><br> <label for="4">Alert when the buff is:</label> <br> <select id="4" class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0"><option class="text-black">Active</option><option class="text-black">Inactive</option><option class="text-black">Less than</option><option class="text-black">Greater than</option><option class="text-black">Parentheses less than</option><option class="text-black">Parentheses greater than</option></select> <br> <!>`,1),va=(t,r,l)=>n(r,"^".concat(o(l).replaceAll(" ",""))),_a=w('<label for="7">Text:</label> <br> <input id="7" type="text" class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0">',1),ca=w('<label for="7">Pattern:</label> <br> <input id="7" type="text" class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0">',1),fa=w('<label for="6">Match type:</label> <br> <select id="6" class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0"><option class="text-black">Exact</option><option class="text-black">Pattern</option></select> <br><br> <!>',1),da=w('<label for="8">Model:</label> <br> <select id="8" class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0"><option class="text-black">Lost souls</option><option class="text-black">Penguin agents 001-007</option><option class="text-black">Seren spirits</option><option class="text-black">Fire spirits</option></select>',1),ba=(t,r,l)=>n(r,o(l)/100),xa=w('<label for="9">Stat:</label> <br> <select id="9" class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0"><option class="text-black">Health</option><option class="text-black">Adrenaline</option><option class="text-black">Prayer</option><option class="text-black">Summoning</option></select> <br><br> <label for="a">Threshold (percent):</label> <br> <input id="a" type="number" class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0">',1),ma=(t,r,l)=>n(r,Math.floor(o(l)*1e6)),ga=w('<br><br> <label for="c">Timeout (seconds):</label> <br> <input id="c" type="number" class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0">',1),ha=w('<label for="b">Mode:</label> <br> <select id="b" class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0"><option class="text-black">Alert on XP gain</option><option class="text-black">Alert on timeout</option></select> <!>',1),wa=w('<div class="mx-2 my-1 p-0 b-0 text-gray-200"><!> <hr class="my-4 opacity-40"> <div class="text-[8pt] w-auto"><label for="1" class="font-italic">Rule type:</label> <br> <select id="1" class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0"><option class="text-black">AFK timer</option><option class="text-black">Buffs/debuffs</option><option class="text-black">Chat text</option><option class="text-black">3D object</option><option class="text-black">Popup text</option><option class="text-black">Stat bars</option><option class="text-black">XP gain</option></select> <br><br> <!></div> <span><button class="w-25 bg-red-500 rounded-sm py-1 px-2 mr-1 mt-4 font-bold text-white text-center hover:opacity-75">Cancel</button> <button class="w-25 bg-blue-500 rounded-sm py-1 px-2 mt-4 font-bold text-white text-center enabled:hover:opacity-75 disabled:bg-gray-500">Save</button></span></div>');function ya(t,r){No(r,!1);const l=k();let u=new URLSearchParams(window.location.search),f=u.get("type"),T=u.get("number"),A=u.get("id"),pe=u.get("ruleset_id"),i=k(f||null),s=k(T?parseInt(T):null),d=k(u.get("ref")),h=k(u.get("comparator")),M=k(u.get("find")),$=k(),ue=k(o(M)===null),de=k(),se=k(),X=k(null),ve=k();o(i)===a.afktimer&&o(s)?n($,Math.floor(o(s)/1e6)):o(i)===a.stat&&o(s)?n(se,Math.floor(o(s)/100)):o(i)===a.xpgain&&o(s)&&n(ve,Math.floor(o(s)/1e6));const Lo=()=>{let p={ruleset_id:pe,type:o(i)};return A&&(p.id=A),o(s)&&(p.number=o(s).toString()),o(d)&&(p.ref=o(d)),o(h)&&(p.comparator=o(h)),o(M)&&(p.find=o(M)),"\0".concat(new URLSearchParams(p).toString())};Jo(()=>(o(i),o(s),o(d),o(h),o(M),o(X)),()=>{n(l,o(i)===a.afktimer&&o(s)!==null||o(i)===a.buff&&o(d)!==null&&o(h)!==null&&(o(s)!==null||o(h)==="active"||o(h)==="inactive")||o(i)===a.chat&&o(M)!==null||o(i)===a.model&&o(d)!==null||o(i)===a.popup&&o(M)!==null||o(i)===a.stat&&o(d)!==null&&o(s)!==null||o(i)===a.xpgain&&(o(s)!==null&&o(X)===!0||o(X)===!1))}),Qo(),Yo();var _o=wa(),co=g(_o);{var Bo=p=>{var q=la();_(p,q)},jo=p=>{var q=ra();_(p,q)};j(co,p=>{A===null?p(Bo):p(jo,!1)})}var fo=e(co,4),_e=e(g(fo),4);U(()=>{o(i),N(()=>{})}),_e.__change=[aa,i,$,s,d,h,M];var be=g(_e),bo={},xe=e(be),xo={},me=e(xe),mo={},ge=e(me),go={},he=e(ge),ho={},we=e(he),wo={},yo=e(we),ko={},qo=e(_e,5);{var Eo=p=>{var q=pa(),ce=e(x(q),4);ce.__change=[ia,s,$],z(ce,()=>o($),ye=>n($,ye)),_(p,q)},Fo=p=>{var q=re(),ce=x(q);{var ye=Q=>{var ee=sa(),oe=e(x(ee),4);U(()=>{o(d),N(()=>{})});var fe=g(oe),ae=g(fe);ae.value=(ae.__value="noadrenalinepotion")==null?"":"noadrenalinepotion";var C=e(ae,2);C.value=(C.__value="aggressionpotion")==null?"":"aggressionpotion";var E=e(C,2);E.value=(E.__value="antifire")==null?"":"antifire";var F=e(E,2);F.value=(F.__value="antipoison")==null?"":"antipoison";var G=e(F,2);G.value=(G.__value="overload")==null?"":"overload";var H=e(G,2);H.value=(H.__value="perfectplus")==null?"":"perfectplus";var y=e(H,2);y.value=(y.__value="poisonous")==null?"":"poisonous";var P=e(y,2);P.value=(P.__value="nopowerburst")==null?"":"nopowerburst";var R=e(P,2);R.value=(R.__value="prayerrenewal")==null?"":"prayerrenewal";var c=e(R,2);c.value=(c.__value="spiritattractionpotion")==null?"":"spiritattractionpotion";var m=e(fe),v=g(m);v.value=(v.__value="powderofburials")==null?"":"powderofburials";var b=e(v,2);b.value=(b.__value="powderofdefence")==null?"":"powderofdefence";var I=e(b,2);I.value=(I.__value="powderofitemprotection")==null?"":"powderofitemprotection";var O=e(I,2);O.value=(O.__value="powderofpenance")==null?"":"powderofpenance";var S=e(O,2);S.value=(S.__value="powderofprotection")==null?"":"powderofprotection";var V=e(S,2);V.value=(V.__value="powderofpulverising")==null?"":"powderofpulverising";var D=e(m),L=g(D);L.value=(L.__value="incenseavantoe")==null?"":"incenseavantoe";var B=e(L,2);B.value=(B.__value="incensecadantine")==null?"":"incensecadantine";var te=e(B,2);te.value=(te.__value="incensedwarfweed")==null?"":"incensedwarfweed";var ne=e(te,2);ne.value=(ne.__value="incensefellstalk")==null?"":"incensefellstalk";var W=e(ne,2);W.value=(W.__value="incenseguam")==null?"":"incenseguam";var Y=e(W,2);Y.value=(Y.__value="incenseharralander")==null?"":"incenseharralander";var Z=e(Y,2);Z.value=(Z.__value="incenseirit")==null?"":"incenseirit";var le=e(Z,2);le.value=(le.__value="incensekwuarm")==null?"":"incensekwuarm";var ke=e(le,2);ke.value=(ke.__value="incenselantadyme")==null?"":"incenselantadyme";var Pe=e(ke,2);Pe.value=(Pe.__value="incensemarrentill")==null?"":"incensemarrentill";var Ie=e(Pe,2);Ie.value=(Ie.__value="incenseranarr")==null?"":"incenseranarr";var Se=e(Ie,2);Se.value=(Se.__value="incensesnapdragon")==null?"":"incensesnapdragon";var Te=e(Se,2);Te.value=(Te.__value="incensespiritweed")==null?"":"incensespiritweed";var Ae=e(Te,2);Ae.value=(Ae.__value="incensetarromin")==null?"":"incensetarromin";var Me=e(Ae,2);Me.value=(Me.__value="incensetoadflax")==null?"":"incensetoadflax";var Ce=e(Me,2);Ce.value=(Ce.__value="incensetorstol")==null?"":"incensetorstol";var So=e(Ce,2);So.value=(So.__value="incensewergali")==null?"":"incensewergali";var Vo=e(D),Re=g(Vo);Re.value=(Re.__value="animatedead")==null?"":"animatedead";var Le=e(Re,2);Le.value=(Le.__value="archaeologiststea")==null?"":"archaeologiststea";var Be=e(Le,2);Be.value=(Be.__value="aura")==null?"":"aura";var je=e(Be,2);je.value=(je.__value="bonfire")==null?"":"bonfire";var qe=e(je,2);qe.value=(qe.__value="cannonballs")==null?"":"cannonballs";var Ee=e(qe,2);Ee.value=(Ee.__value="cannontimer")==null?"":"cannontimer";var Fe=e(Ee,2);Fe.value=(Fe.__value="cindercore")==null?"":"cindercore";var Ge=e(Fe,2);Ge.value=(Ge.__value="clancitadel")==null?"":"clancitadel";var Oe=e(Ge,2);Oe.value=(Oe.__value="crystalmask")==null?"":"crystalmask";var Ve=e(Oe,2);Ve.value=(Ve.__value="darkness")==null?"":"darkness";var De=e(Ve,2);De.value=(De.__value="noritualshard")==null?"":"noritualshard";var We=e(De,2);We.value=(We.__value="noexcalibur")==null?"":"noexcalibur";var He=e(We,2);He.value=(He.__value="firelighter")==null?"":"firelighter";var Ue=e(He,2);Ue.value=(Ue.__value="godbook")==null?"":"godbook";var Xe=e(Ue,2);Xe.value=(Xe.__value="grimoire")==null?"":"grimoire";var Ke=e(Xe,2);Ke.value=(Ke.__value="hispecmonocle")==null?"":"hispecmonocle";var Ne=e(Ke,2);Ne.value=(Ne.__value="luminiteinjector")==null?"":"luminiteinjector";var Je=e(Ne,2);Je.value=(Je.__value="materialmanual")==null?"":"materialmanual";var Qe=e(Je,2);Qe.value=(Qe.__value="porter")==null?"":"porter";var Ye=e(Qe,2);Ye.value=(Ye.__value="pulsecore")==null?"":"pulsecore";var Ze=e(Ye,2);Ze.value=(Ze.__value="roarofosseous")==null?"":"roarofosseous";var ze=e(Ze,2);ze.value=(ze.__value="rockofresilience")==null?"":"rockofresilience";var $e=e(ze,2);$e.value=($e.__value="scrimshaw")==null?"":"scrimshaw";var eo=e($e,2);eo.value=(eo.__value="signoflife")==null?"":"signoflife";var oo=e(eo,2);oo.value=(oo.__value="stoneofjas")==null?"":"stoneofjas";var ao=e(oo,2);ao.value=(ao.__value="summon")==null?"":"summon";var to=e(ao,2);to.value=(to.__value="tarpaulinsheet")==null?"":"tarpaulinsheet";var no=e(to,2);no.value=(no.__value="valentinesflip")==null?"":"valentinesflip";var lo=e(no,2);lo.value=(lo.__value="valentinesslam")==null?"":"valentinesslam";var To=e(lo,2);To.value=(To.__value="wiseperk")==null?"":"wiseperk";var ro=e(oe,9);U(()=>{o(h),N(()=>{})});var io=g(ro);io.value=(io.__value="active")==null?"":"active";var po=e(io);po.value=(po.__value="inactive")==null?"":"inactive";var uo=e(po);uo.value=(uo.__value="lessthan")==null?"":"lessthan";var so=e(uo);so.value=(so.__value="greaterthan")==null?"":"greaterthan";var vo=e(so);vo.value=(vo.__value="parenslessthan")==null?"":"parenslessthan";var Ao=e(vo);Ao.value=(Ao.__value="greater than")==null?"":"greater than";var Do=e(ro,4);{var Wo=K=>{var Mo=ua(),Ho=e(x(Mo),4);z(Ho,()=>o(s),Uo=>n(s,Uo)),_(K,Mo)};j(Do,K=>{o(h)!==null&&o(h)!=="active"&&o(h)!=="inactive"&&K(Wo)})}J(oe,()=>o(d),K=>n(d,K)),J(ro,()=>o(h),K=>n(h,K)),_(Q,ee)},Oo=Q=>{var ee=re(),oe=x(ee);{var fe=C=>{var E=fa(),F=e(x(E),4);U(()=>{o(ue),N(()=>{})});var G=g(F);G.value=(G.__value=!0)==null?"":!0;var H=e(G);H.value=(H.__value=!1)==null?"":!1;var y=e(F,5);{var P=c=>{var m=_a(),v=e(x(m),4);v.__change=[va,M,de],z(v,()=>o(de),b=>n(de,b)),_(c,m)},R=c=>{var m=ca(),v=e(x(m),4);z(v,()=>o(M),b=>n(M,b)),_(c,m)};j(y,c=>{o(ue)?c(P):c(R,!1)})}J(F,()=>o(ue),c=>n(ue,c)),_(C,E)},ae=C=>{var E=re(),F=x(E);{var G=y=>{var P=da(),R=e(x(P),4);U(()=>{o(d),N(()=>{})});var c=g(R);c.value=(c.__value="lostsoul")==null?"":"lostsoul";var m=e(c);m.value=(m.__value="penguinagent")==null?"":"penguinagent";var v=e(m);v.value=(v.__value="serenspirit")==null?"":"serenspirit";var b=e(v);b.value=(b.__value="firespirit")==null?"":"firespirit",J(R,()=>o(d),I=>n(d,I)),_(y,P)},H=y=>{var P=re(),R=x(P);{var c=v=>{var b=xa(),I=e(x(b),4);U(()=>{o(d),N(()=>{})});var O=g(I);O.value=(O.__value="health")==null?"":"health";var S=e(O);S.value=(S.__value="adrenaline")==null?"":"adrenaline";var V=e(S);V.value=(V.__value="prayer")==null?"":"prayer";var D=e(V);D.value=(D.__value="summoning")==null?"":"summoning";var L=e(I,9);L.__change=[ba,s,se],J(I,()=>o(d),B=>n(d,B)),z(L,()=>o(se),B=>n(se,B)),_(v,b)},m=v=>{var b=re(),I=x(b);{var O=S=>{var V=ha(),D=e(x(V),4);U(()=>{o(X),N(()=>{})});var L=g(D);L.value=(L.__value=!1)==null?"":!1;var B=e(L);B.value=(B.__value=!0)==null?"":!0;var te=e(D,2);{var ne=W=>{var Y=ga(),Z=e(x(Y),7);Z.__change=[ma,s,ve],z(Z,()=>o(ve),le=>n(ve,le)),_(W,Y)};j(te,W=>{o(X)&&W(ne)})}J(D,()=>o(X),W=>n(X,W)),_(S,V)};j(I,S=>{o(i)===a.xpgain&&S(O)},!0)}_(v,b)};j(R,v=>{o(i)===a.stat?v(c):v(m,!1)},!0)}_(y,P)};j(F,y=>{o(i)===a.model?y(G):y(H,!1)},!0)}_(C,E)};j(oe,C=>{o(i)===a.chat||o(i)===a.popup?C(fe):C(ae,!1)},!0)}_(Q,ee)};j(ce,Q=>{o(i)===a.buff?Q(ye):Q(Oo,!1)},!0)}_(p,q)};j(qo,p=>{o(i)===a.afktimer?p(Eo):p(Fo,!1)})}var Go=e(fo,2),Po=g(Go);Po.__click=[na];var Io=e(Po,2);Io.__click=[ta,Lo],U(()=>{bo!==(bo=a.afktimer)&&(be.value=(be.__value=a.afktimer)==null?"":a.afktimer),xo!==(xo=a.buff)&&(xe.value=(xe.__value=a.buff)==null?"":a.buff),mo!==(mo=a.chat)&&(me.value=(me.__value=a.chat)==null?"":a.chat),go!==(go=a.model)&&(ge.value=(ge.__value=a.model)==null?"":a.model),ho!==(ho=a.popup)&&(he.value=(he.__value=a.popup)==null?"":a.popup),wo!==(wo=a.stat)&&(we.value=(we.__value=a.stat)==null?"":a.stat),ko!==(ko=a.xpgain)&&(yo.value=(yo.__value=a.xpgain)==null?"":a.xpgain),Io.disabled=!o(l)}),J(_e,()=>o(i),p=>n(i,p)),_(t,_o),Zo()}Ko(["change","click"]);zo(ya,{target:document.body});
