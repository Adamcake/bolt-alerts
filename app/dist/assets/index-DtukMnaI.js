import{b as Me,g as m,d as z,r as we,a as ye,p as Ne,I as Q,c as xe,e as Y,i as Ce,m as ne,s as se,E as Fe,f as qe,h as Be,j as Ve,k as He,l as We,n as je,o as ze,q as Ye,t as q,u as G,v as Ge,w as Je,x as X,y as Xe,z as Ke,L as Qe,A as Ze,S as et,B as tt,C as nt,P as at,D as rt,R as st,F as oe,G as ie,H as ot,J as it,K as lt,M as ke,N as Se,O as ut,Q as ct,T as Ee,U as B,V as R,W as C,X as Re,Y as L,Z as Ue,_ as le,$ as ue,a0 as ce,a1 as de,a2 as dt,a3 as ft}from"./legacy-CU8Tr-xf.js";import{p as vt,R as N}from"./interfaces-Dq7mtQWd.js";let Ie=!1;function fe(e,t){return t}function pt(e,t,n,r){for(var l=[],p=t.length,y=0;y<p;y++)qe(t[y].e,l,!0);var f=p>0&&l.length===0&&n!==null;if(f){var g=n.parentNode;Be(g),g.append(n),r.clear(),D(e,t[0].prev,t[p-1].next)}Ve(l,()=>{for(var h=0;h<p;h++){var u=t[h];f||(r.delete(u.k),D(e,u.prev,u.next)),He(u.e,!f)}})}function ve(e,t,n,r,l,p=null){var y=e,f={items:new Map,first:null},g=null,h=!1,u=z(()=>{var b=n();return Ye(b)?b:b==null?[]:xe(b)});Me(()=>{var b=m(u),_=b.length;h&&_===0||(h=_===0,_t(b,f,y,l,t,r,n),p!==null&&(_===0?g?we(g):g=ye(()=>p(y)):g!==null&&Ne(g,()=>{g=null})),m(u))})}function _t(e,t,n,r,l,p,y){var f=e.length,g=t.items,h=t.first,u=h,b,_=null,E=[],x=[],I,$,k,a;for(a=0;a<f;a+=1){if(I=e[a],$=p(I,a),k=g.get($),k===void 0){var s=u?u.e.nodes_start:n;_=gt(s,t,_,_===null?t.first:_.next,I,$,a,r,l,y),g.set($,_),E=[],x=[],u=_.next;continue}if(bt(k,I,a),k.e.f&Q&&we(k.e),k!==u){if(b!==void 0&&b.has(k)){if(E.length<x.length){var i=x[0],o;_=i.prev;var c=E[0],d=E[E.length-1];for(o=0;o<E.length;o+=1)pe(E[o],i,n);for(o=0;o<x.length;o+=1)b.delete(x[o]);D(t,c.prev,d.next),D(t,_,c),D(t,d,i),u=i,_=d,a-=1,E=[],x=[]}else b.delete(k),pe(k,u,n),D(t,k.prev,k.next),D(t,k,_===null?t.first:_.next),D(t,_,k),_=k;continue}for(E=[],x=[];u!==null&&u.k!==$;)u.e.f&Q||(b??(b=new Set)).add(u),x.push(u),u=u.next;if(u===null)continue;k=u}E.push(k),_=k,u=k.next}if(u!==null||b!==void 0){for(var w=b===void 0?[]:xe(b);u!==null;)u.e.f&Q||w.push(u),u=u.next;var v=w.length;if(v>0){var S=null;pt(t,w,S,g)}}Y.first=t.first&&t.first.e,Y.last=_&&_.e}function bt(e,t,n,r){Ce(e.v,t),e.i=n}function gt(e,t,n,r,l,p,y,f,g,h){var u=(g&je)!==0,b=(g&ze)===0,_=u?b?ne(l):se(l):l,E=g&Fe?se(y):y,x={i:E,v:_,k:p,a:null,e:null,prev:n,next:r};try{return x.e=ye(()=>f(e,_,E,h),Ie),x.e.prev=n&&n.e,x.e.next=r&&r.e,n===null?t.first=x:(n.next=x,n.e.next=x.e),r!==null&&(r.prev=x,r.e.prev=x.e),x}finally{}}function pe(e,t,n){for(var r=e.next?e.next.e.nodes_start:n,l=t?t.e.nodes_start:n,p=e.e.nodes_start;p!==r;){var y=We(p);l.before(p),p=y}}function D(e,t,n){t===null?e.first=n:(t.next=n,t.e.next=n&&n.e),n!==null&&(n.prev=t,n.e.prev=t&&t.e)}function $e(e){var t,n,r="";if(typeof e=="string"||typeof e=="number")r+=e;else if(typeof e=="object")if(Array.isArray(e)){var l=e.length;for(t=0;t<l;t++)e[t]&&(n=$e(e[t]))&&(r&&(r+=" "),r+=n)}else for(n in e)e[n]&&(r&&(r+=" "),r+=n);return r}function mt(){for(var e,t,n=0,r="",l=arguments.length;n<l;n++)(e=arguments[n])&&(t=$e(e))&&(r&&(r+=" "),r+=t);return r}function _e(e){return typeof e=="object"?mt(e):e??""}function be(e,t,n){var r=e.__className,l=ht(t);(r!==l||Ie)&&(t==null?e.removeAttribute("class"):e.className=l,e.__className=l)}function ht(e,t){return(e??"")+""}function Ae(e,t,n){if(e==null)return t(void 0),q;const r=G(()=>e.subscribe(t,n));return r.unsubscribe?()=>r.unsubscribe():r}const F=[];function ge(e,t=q){let n=null;const r=new Set;function l(f){if(Ge(e,f)&&(e=f,n)){const g=!F.length;for(const h of r)h[1](),F.push(h,e);if(g){for(let h=0;h<F.length;h+=2)F[h][0](F[h+1]);F.length=0}}}function p(f){l(f(e))}function y(f,g=q){const h=[f,g];return r.add(h),r.size===1&&(n=t(l,p)||q),f(e),()=>{r.delete(h),r.size===0&&n&&(n(),n=null)}}return{set:l,update:p,subscribe:y}}function ee(e){let t;return Ae(e,n=>t=n)(),t}let j=!1,te=Symbol();function wt(e,t,n){const r=n[t]??(n[t]={store:null,source:ne(void 0),unsubscribe:q});if(r.store!==e&&!(te in n))if(r.unsubscribe(),r.store=e??null,e==null)r.source.v=void 0,r.unsubscribe=q;else{var l=!0;r.unsubscribe=Ae(e,p=>{l?r.source.v=p:X(r.source,p)}),l=!1}return e&&te in n?ee(e):m(r.source)}function yt(){const e={};function t(){Je(()=>{for(var n in e)e[n].unsubscribe();Xe(e,te,{enumerable:!1,value:!0})})}return[e,t]}function xt(e,t,n){return e.set(n),t}function kt(e){var t=j;try{return j=!1,[e(),j]}finally{j=t}}function me(e){for(var t=Y,n=Y;t!==null&&!(t.f&(rt|st));)t=t.parent;try{return oe(t),e()}finally{oe(n)}}function St(e,t,n,r){var c;var l=(n&lt)!==0,p=!nt||(n&at)!==0,y=(n&ot)!==0,f=!1,g;[g,f]=kt(()=>e[t]);var h=et in e||tt in e,u=(((c=Ke(e,t))==null?void 0:c.set)??(h&&t in e&&(d=>e[t]=d)))||void 0,b=r,_=!0,E=!1,x=()=>(E=!0,_&&(_=!1,b=r),b),I;if(p)I=()=>{var d=e[t];return d===void 0?x():(_=!0,E=!1,d)};else{var $=me(()=>(l?ie:z)(()=>e[t]));$.f|=Qe,I=()=>{var d=m($);return d!==void 0&&(b=void 0),d===void 0?b:d}}if(u){var k=e.$$legacy;return function(d,w){return arguments.length>0?((!p||!w||k||f)&&u(w?I():d),d):I()}}var a=!1,s=!1,i=ne(g),o=me(()=>ie(()=>{var d=I(),w=m(i);return a?(a=!1,s=!0,w):(s=!1,i.v=d)}));return o.equals=Ze,function(d,w){if(it!==null&&(a=s,I(),m(i)),arguments.length>0){const v=w?m(o):p&&y?vt(d):d;return o.equals(v)||(a=!0,X(i,v),E&&b!==void 0&&(b=v),G(()=>m(o))),d}return m(o)}}const U=[];for(let e=0;e<256;++e)U.push((e+256).toString(16).slice(1));function Et(e,t=0){return(U[e[t+0]]+U[e[t+1]]+U[e[t+2]]+U[e[t+3]]+"-"+U[e[t+4]]+U[e[t+5]]+"-"+U[e[t+6]]+U[e[t+7]]+"-"+U[e[t+8]]+U[e[t+9]]+"-"+U[e[t+10]]+U[e[t+11]]+U[e[t+12]]+U[e[t+13]]+U[e[t+14]]+U[e[t+15]]).toLowerCase()}let Z;const Rt=new Uint8Array(16);function Ut(){if(!Z){if(typeof crypto>"u"||!crypto.getRandomValues)throw new Error("crypto.getRandomValues() not supported. See https://github.com/uuidjs/uuid#getrandomvalues-not-supported");Z=crypto.getRandomValues.bind(crypto)}return Z(Rt)}const It=typeof crypto<"u"&&crypto.randomUUID&&crypto.randomUUID.bind(crypto),he={randomUUID:It};function J(e,t,n){var l;if(he.randomUUID&&!e)return he.randomUUID();e=e||{};const r=e.random??((l=e.rng)==null?void 0:l.call(e))??Ut();if(r.length<16)throw new Error("Random bytes length must be >= 16");return r[6]=r[6]&15|64,r[8]=r[8]&63|128,Et(r)}const $t=()=>fetch("https://bolt-api/send-message",{method:"POST",body:new Uint8Array([1,0])});var At=(e,t,n)=>t(m(n),!1),Tt=B('<button class="h-[14px] w-[14px] pointer-events-auto"><img src="plugin://app/images/caret-down-solid.svg" class="w-full h-full" alt="Hide"></button>'),Ot=(e,t,n)=>t(m(n),!0),Pt=B('<button class="h-[14px] w-[14px] pointer-events-auto"><img src="plugin://app/images/caret-down-solid.svg" class="w-full h-full rotate-270" alt="Expand"></button>'),Dt=(e,t,n)=>t(m(n)),Lt=(e,t,n)=>t(m(n)),Mt=(e,t,n)=>t(m(n)),Nt=(e,t,n,r)=>t(m(n),m(r)),Ct=(e,t,n,r)=>t(m(n),m(r)),Ft=B('<div> <button class="absolute rounded-lg right-0 top-0 h-[18px] w-[18px] hover:bg-red-500 pointer-events-auto py-0 by-0" title="Delete"><img src="plugin://app/images/xmark-solid.svg" class="w-full h-full" alt="Delete"></button> <button class="absolute rounded-lg right-[18px] top-0 h-[18px] w-[18px] hover:bg-blue-400 pointer-events-auto py-0 by-0" title="Edit"><img src="plugin://app/images/gear-solid.svg" class="absolute top-[2px] left-[2px] w-[14px] h-[14px]" alt="Edit"></button></div>'),qt=B('<div><!> <button class="absolute rounded-lg right-0 top-0 h-[18px] w-[18px] hover:bg-red-500 pointer-events-auto py-0 by-0" title="Delete"><img src="plugin://app/images/xmark-solid.svg" class="w-full h-full" alt="Delete"></button> <button class="absolute rounded-lg right-[18px] top-0 h-[18px] w-[18px] hover:bg-blue-400 pointer-events-auto py-0 by-0" title="Edit"><img src="plugin://app/images/gear-solid.svg" class="absolute top-[2px] left-[2px] w-[14px] h-[14px]" alt="Edit"></button> <button class="absolute rounded-lg right-[36px] top-0 h-[18px] w-[18px] hover:bg-emerald-400 pointer-events-auto py-0 by-0" title="Add rule"><img src="plugin://app/images/plus-solid.svg" class="w-full h-full" alt="Add rule"></button></div> <!>',1),Bt=B('<div><!> <button class="rounded-sm my-1 px-2 py-1 bg-emerald-400 pointer-events-auto hover:opacity-75">Add ruleset</button></div>');function Vt(e,t){Se(t,!1);const[n,r]=yt(),l=()=>wt(f(),"$list",n),p=(a,s)=>{let i=0;const o=v=>{s&&s.setUint8(i,v?1:0),i+=1},c=v=>{s&&s.setUint32(i,v,!0),i+=4},d=v=>{s&&s.setInt32(i,v,!0),i+=4},w=v=>{const S=new TextEncoder().encode(v);if(c(v.length),s)for(let A=0;A<S.byteLength;A+=1)s.setUint8(i+A,S[A]);i+=S.byteLength};c(a.length);for(const v of a){w(v.id),o(v.alert),o(v.doFlashWindow),o(v.onlyIfUnfocused),c(Object.keys(v.rules).length);for(const S of Object.values(v.rules)){w(S.id),w(S.ruletype);const A=typeof S.alert=="boolean",O=typeof S.number=="number",M=typeof S.ref=="string",V=typeof S.comparator=="string",H=typeof S.find=="string";o(A),A&&o(S.alert===!0),o(O),O&&d(S.number),o(M),M&&w(S.ref),o(V),V&&w(S.comparator),o(H),H&&w(S.find)}}return i};window.addEventListener("message",a=>{if(!a.data||typeof a.data!="object"||a.data.type!=="pluginMessage")return;const s=new Uint16Array(a.data.content.slice(0,2))[0];switch(s){case 1:{const i=new URLSearchParams(new TextDecoder().decode(a.data.content.slice(2)));let o=i.get("id"),c=null;o?c=ee(f())[o]:o=J(),xt(f(),G(l)[o]={id:o,name:i.get("name"),rules:c?c.rules:{},expanded:c?c.expanded:!1,alert:c?c.alert:!1,doFlashWindow:i.get("flash_window")==="1",sound:i.get("sound")??void 0,volume:parseInt(i.get("volume")),onlyIfUnfocused:i.get("only_if_unfocused")==="1"},G(l));break}case 2:{const i=new URLSearchParams(new TextDecoder().decode(a.data.content.slice(2))),o=l(),c=o[i.get("ruleset_id")];let d=i.get("id"),w=null;d?w=c.rules[d]:d=J();let v=i.get("number");c.rules[d]={id:d,ruletype:i.get("type"),alert:w?w.alert:!1,number:v?parseInt(v):void 0,ref:i.get("ref")??void 0,comparator:i.get("comparator")??void 0,find:i.get("find")??void 0},c.expanded=!0,f().set(o);break}default:console.error(`unknown message type ${s}`)}});let y=Ue(!1),f=St(t,"list",12);const g=a=>{let s={id:a.id,name:a.name,only_if_unfocused:a.onlyIfUnfocused?"1":"0",flash_window:a.doFlashWindow?"1":"0",volume:a.volume.toString()};a.sound&&(s.sound=a.sound);const i="\0".concat(new URLSearchParams(s).toString());fetch("https://bolt-api/send-message",{method:"POST",body:i})},h=a=>{let s={ruleset_id:a.id};const i="\0".concat(new URLSearchParams(s).toString());fetch("https://bolt-api/send-message",{method:"POST",body:i})},u=(a,s)=>{let i={ruleset_id:a.id,id:s.id,type:s.ruletype};s.number&&(i.number=s.number.toString()),s.ref&&(i.ref=s.ref),s.comparator&&(i.comparator=s.comparator),s.find&&(i.find=s.find);const o="\0".concat(new URLSearchParams(i).toString());fetch("https://bolt-api/send-message",{method:"POST",body:o})},b=a=>{const s=ee(f());delete s[a.id],f().set(s)},_=(a,s)=>{delete a.rules[s.id],f().set(l())},E=(a,s)=>{a.expanded=s,f(f())},x=a=>{switch(a.ruletype){case N.afktimer:return a.number?`afk timer (${Math.floor(a.number/1e6)} sec)`:"afk timer";case N.buff:switch(a.comparator){case"active":return`buff '${a.ref}' active`;case"inactive":return`buff '${a.ref}' inactive`;case"lessthan":return`buff '${a.ref}' < ${a.number}`;case"greaterthan":return`buff '${a.ref}' > ${a.number}`;case"parenslessthan":return`buff '${a.ref}' parentheses < ${a.number}`;case"parenscreaterthan":return`buff '${a.ref}' parentheses > ${a.number}`;default:return`buff '${a.ref}'`}case N.chat:return`chat text: '${a.find}'`;case N.model:return`3D model: '${a.ref}'`;case N.popup:return`popup text: '${a.find}'`;case N.stat:return a.number?`stat '${a.ref}' < ${Math.floor(a.number*100)}%`:"";case N.xpgain:return a.number?`xp gain timeout (${Math.floor(a.number/1e6)} sec)`:"xp gain";default:return"unknown"}};ut(()=>(l(),m(y)),()=>{const a=l();if(m(y)||Object.keys(a).length>0){const s=Object.values(a),i=p(s,null),o=new ArrayBuffer(i+2);new DataView(o,0,2).setUint16(0,5,!0),p(s,new DataView(o,2,i)),fetch("https://bolt-api/send-message",{method:"POST",body:o})}if(m(y)){const s=Object.values(a).map(o=>({name:o.name,rules:Object.values(o.rules).map(c=>({ruletype:c.ruletype,number:c.number,ref:c.ref,comparator:c.comparator,find:c.find})),doFlashWindow:o.doFlashWindow,sound:o.sound,volume:o.volume,onlyIfUnfocused:o.onlyIfUnfocused})),i="\0".concat(JSON.stringify(s));fetch("https://bolt-api/send-message",{method:"POST",body:i})}else X(y,!0)}),ct(),Ee();var I=Bt(),$=L(I);ve($,1,()=>Object.values(l()),fe,(a,s,i)=>{var o=qt(),c=le(o),d=L(c);{var w=T=>{var P=Tt();P.__click=[At,E,s],C(T,P)},v=T=>{var P=Pt();P.__click=[Ot,E,s],C(T,P)};ue(d,T=>{m(s).expanded?T(w):T(v,!1)})}var S=R(d),A=R(S);A.__click=[Dt,b,s];var O=R(A,2);O.__click=[Lt,g,s];var M=R(O,2);M.__click=[Mt,h,s];var V=R(c,2);{var H=T=>{var P=dt(),Te=le(P);ve(Te,1,()=>Object.values(m(s).rules),fe,(Oe,W)=>{var K=Ft(),ae=L(K),re=R(ae);re.__click=[Nt,_,s,W];var Pe=R(re,2);Pe.__click=[Ct,u,s,W],ce((De,Le)=>{be(K,_e(De)),de(ae,`${Le??""} `)},[()=>"relative px-1 w-full text-[8pt] ".concat(m(W).alert?"bg-red-400":i&1?"bg-gray-200":"bg-gray-300"),()=>x(m(W))],z),C(Oe,K)}),C(T,P)};ue(V,T=>{m(s).expanded&&T(H)})}ce(T=>{be(c,_e(T)),de(S,` ${m(s).name??""} `)},[()=>"relative w-full text-[8pt] ".concat(m(s).alert?"bg-red-400":i&1?"bg-gray-200":"bg-gray-300")],z),C(a,o)});var k=R($,2);k.__click=[$t],C(e,I),Re(),r()}ke(["click"]);const Ht=()=>fetch("https://bolt-api/close-request");var Wt=(e,t)=>{e.button===0&&t("-1","-1")},jt=(e,t)=>{e.button===0&&t("0","-1")},zt=(e,t)=>{e.button===0&&t("1","-1")},Yt=(e,t)=>{e.button===0&&t("-1","0")},Gt=(e,t)=>{e.button===0&&t("1","0")},Jt=(e,t)=>{e.button===0&&t("-1","1")},Xt=(e,t)=>{e.button===0&&t("0","1")},Kt=(e,t)=>{e.button===0&&t("1","1")},Qt=(e,t)=>{e.button===0&&t("0","0")},Zt=B('<main><div class="absolute grid grid-cols-[5px_auto_5px] grid-rows-[5px_auto_5px] top-0 left-0 bottom-0 right-0 z-100 pointer-events-none"><div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="pointer-events-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div></div> <div class="m-[7px] w-auto h-auto"><div class="m-0 p-0 border-b border-black absolute top-[5px] right-[5px] w-[18px] h-[19px]"><button class="m-0 p-0 absolute top-0 left-0 w-full h-full select-none text-center text-[12px] bg-[hsl(0,70%,50%)] hover:bg-[hsl(0,100%,50%)]">X</button></div> <div class="m-0 p-0 border-b border-black absolute left-[5px] top-[5px] right-[23px] h-[19px] bg-[grey] text-center text-[10pt]"><p class="m-0 p-0 color-black select-none pointer-events-none">Alerts</p></div> <div class="fixed top-[24px] bottom-[6px] left-[5px] right-[5px] text-[10pt] pointer-events-none"><!></div></div></main>');function en(e,t){Se(t,!1);const n=new URLSearchParams(window.location.search);let r=Ue((o=>{const c=o.get("list");if(!c)return ge({});const d=JSON.parse(atob(c));let w={};for(const v of d){let S={};for(const O of v.rules){const M=J();S[M]={id:M,ruletype:O.ruletype,alert:!1,number:O.number,ref:O.ref,comparator:O.comparator,find:O.find}}const A=J();w[A]={id:A,name:v.name,rules:S,expanded:!1,alert:!1,doFlashWindow:v.doFlashWindow,sound:v.sound,volume:v.volume,onlyIfUnfocused:v.onlyIfUnfocused}}return ge(w)})(n));const l=(o,c)=>fetch("https://bolt-api/start-reposition?".concat(new URLSearchParams({h:o,v:c}).toString()));Ee();var p=Zt(),y=L(p),f=L(y);f.__mousedown=[Wt,l];var g=R(f,2);g.__mousedown=[jt,l];var h=R(g,2);h.__mousedown=[zt,l];var u=R(h,2);u.__mousedown=[Yt,l];var b=R(u,4);b.__mousedown=[Gt,l];var _=R(b,2);_.__mousedown=[Jt,l];var E=R(_,2);E.__mousedown=[Xt,l];var x=R(E,2);x.__mousedown=[Kt,l];var I=R(y,2),$=L(I),k=L($);k.__click=[Ht];var a=R($,2);a.__mousedown=[Qt,l];var s=R(a,2),i=L(s);Vt(i,{get list(){return m(r)},set list(o){X(r,o)},$$legacy:!0}),C(e,p),Re()}ke(["mousedown","click"]);ft(en,{target:document.body});
