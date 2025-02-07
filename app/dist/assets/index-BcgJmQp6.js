(function(){const e=document.createElement("link").relList;if(e&&e.supports&&e.supports("modulepreload"))return;for(const o of document.querySelectorAll('link[rel="modulepreload"]'))n(o);new MutationObserver(o=>{for(const l of o)if(l.type==="childList")for(const u of l.addedNodes)u.tagName==="LINK"&&u.rel==="modulepreload"&&n(u)}).observe(document,{childList:!0,subtree:!0});function r(o){const l={};return o.integrity&&(l.integrity=o.integrity),o.referrerPolicy&&(l.referrerPolicy=o.referrerPolicy),o.crossOrigin==="use-credentials"?l.credentials="include":o.crossOrigin==="anonymous"?l.credentials="omit":l.credentials="same-origin",l}function n(o){if(o.ep)return;o.ep=!0;const l=r(o);fetch(o.href,l)}})();const ct=!1;var Wt=Array.isArray,$t=Array.prototype.indexOf,Kt=Array.from,Xt=Object.defineProperty,_t=Object.getOwnPropertyDescriptor,zt=Object.getOwnPropertyDescriptors,Gt=Object.getPrototypeOf;function Jt(t){return t()}function vt(t){for(var e=0;e<t.length;e++)t[e]()}const k=2,yt=4,st=8,Qt=16,A=32,J=64,H=128,x=256,W=512,b=1024,P=2048,q=4096,$=8192,Q=16384,Zt=32768,te=65536,ee=1<<19,Et=1<<20,pt=Symbol("$state");function xt(t){return t===this.v}function re(t){throw new Error("https://svelte.dev/e/effect_in_teardown")}function ne(){throw new Error("https://svelte.dev/e/effect_in_unowned_derived")}function oe(t){throw new Error("https://svelte.dev/e/effect_orphan")}function le(){throw new Error("https://svelte.dev/e/effect_update_depth_exceeded")}function ue(){throw new Error("https://svelte.dev/e/state_unsafe_local_read")}let it=!1,se=!1;function ie(){it=!0}const ae=2;let d=null;function dt(t){d=t}function Tt(t,e=!1,r){d={p:d,c:null,e:null,m:!1,s:t,x:null,l:null},it&&!e&&(d.l={s:null,u:null,r1:[],r2:ce(!1)})}function kt(t){const e=d;if(e!==null){const u=e.e;if(u!==null){var r=p,n=_;e.e=null;try{for(var o=0;o<u.length;o++){var l=u[o];L(l.effect),R(l.reaction),Rt(l.fn)}}finally{L(r),R(n)}}d=e.p,e.m=!0}return{}}function fe(){return!it||d!==null&&d.l===null}function ce(t,e){var r={f:0,v:t,reactions:null,equals:xt,rv:0,wv:0};return r}var ht,Ot,St;function _e(){if(ht===void 0){ht=window;var t=Element.prototype,e=Node.prototype;Ot=_t(e,"firstChild").get,St=_t(e,"nextSibling").get,t.__click=void 0,t.__className="",t.__attributes=null,t.__styles=null,t.__e=void 0,Text.prototype.__t=void 0}}function ve(t=""){return document.createTextNode(t)}function Nt(t){return Ot.call(t)}function At(t){return St.call(t)}function U(t,e){return Nt(t)}function E(t,e=1,r=!1){let n=t;for(;e--;)n=At(n);return n}function pe(t){var e=k|P,r=_!==null&&_.f&k?_:null;return p===null||r!==null&&r.f&x?e|=x:p.f|=Et,{ctx:d,deps:null,effects:null,equals:xt,f:e,fn:t,reactions:null,rv:0,v:null,wv:0,parent:r??p}}function Dt(t){var e=t.effects;if(e!==null){t.effects=null;for(var r=0;r<e.length;r+=1)S(e[r])}}function de(t){for(var e=t.parent;e!==null;){if(!(e.f&k))return e;e=e.parent}return null}function he(t){var e,r=p;L(de(t));try{Dt(t),e=Bt(t)}finally{L(r)}return e}function Ft(t){var e=he(t),r=(T||t.f&x)&&t.deps!==null?q:b;N(t,r),t.equals(e)||(t.v=e,t.wv=ke())}function Ct(t){p===null&&_===null&&oe(),_!==null&&_.f&x&&p===null&&ne(),at&&re()}function ge(t,e){var r=e.last;r===null?e.last=e.first=t:(r.next=t,t.prev=r,e.last=t)}function Z(t,e,r,n=!0){var o=(t&J)!==0,l=p,u={ctx:d,deps:null,nodes_start:null,nodes_end:null,f:t|P,first:null,fn:e,last:null,next:null,parent:o?null:l,prev:null,teardown:null,transitions:null,wv:0};if(r){var a=C;try{wt(!0),ft(u),u.f|=Zt}catch(g){throw S(u),g}finally{wt(a)}}else e!==null&&Ut(u);var f=r&&u.deps===null&&u.first===null&&u.nodes_start===null&&u.teardown===null&&(u.f&(Et|H))===0;if(!f&&!o&&n&&(l!==null&&ge(u,l),_!==null&&_.f&k)){var i=_;(i.effects??(i.effects=[])).push(u)}return u}function gt(t){Ct();var e=p!==null&&(p.f&A)!==0&&d!==null&&!d.m;if(e){var r=d;(r.e??(r.e=[])).push({fn:t,effect:p,reaction:_})}else{var n=Rt(t);return n}}function we(t){return Ct(),be(t)}function me(t){const e=Z(J,t,!0);return(r={})=>new Promise(n=>{r.outro?xe(e,()=>{S(e),n(void 0)}):(S(e),n(void 0))})}function Rt(t){return Z(yt,t,!1)}function be(t){return Z(st,t,!0)}function ye(t,e=!0){return Z(st|A,t,!0,e)}function Lt(t){var e=t.teardown;if(e!==null){const r=at,n=_;mt(!0),R(null);try{e.call(null)}finally{mt(r),R(n)}}}function Pt(t,e=!1){var r=t.first;for(t.first=t.last=null;r!==null;){var n=r.next;S(r,e),r=n}}function Ee(t){for(var e=t.first;e!==null;){var r=e.next;e.f&A||S(e),e=r}}function S(t,e=!0){var r=!1;if((e||t.f&ee)&&t.nodes_start!==null){for(var n=t.nodes_start,o=t.nodes_end;n!==null;){var l=n===o?null:At(n);n.remove(),n=l}r=!0}Pt(t,e&&!r),G(t,0),N(t,Q);var u=t.transitions;if(u!==null)for(const f of u)f.stop();Lt(t);var a=t.parent;a!==null&&a.first!==null&&It(t),t.next=t.prev=t.teardown=t.ctx=t.deps=t.fn=t.nodes_start=t.nodes_end=null}function It(t){var e=t.parent,r=t.prev,n=t.next;r!==null&&(r.next=n),n!==null&&(n.prev=r),e!==null&&(e.first===t&&(e.first=n),e.last===t&&(e.last=r))}function xe(t,e){var r=[];Mt(t,r,!0),Te(r,()=>{S(t),e&&e()})}function Te(t,e){var r=t.length;if(r>0){var n=()=>--r||e();for(var o of t)o.out(n)}else e()}function Mt(t,e,r){if(!(t.f&$)){if(t.f^=$,t.transitions!==null)for(const u of t.transitions)(u.is_global||r)&&e.push(u);for(var n=t.first;n!==null;){var o=n.next,l=(n.f&te)!==0||(n.f&A)!==0;Mt(n,e,l?r:!1),n=o}}}let Y=!1,K=!1,X=null,C=!1,at=!1;function wt(t){C=t}function mt(t){at=t}let ot=[],I=0;let _=null,O=!1;function R(t){_=t}let p=null;function L(t){p=t}let M=null,h=null,w=0,D=null,qt=1,z=0,T=!1;function ke(){return++qt}function tt(t){var i;var e=t.f;if(e&P)return!0;if(e&q){var r=t.deps,n=(e&x)!==0;if(r!==null){var o,l,u=(e&W)!==0,a=n&&p!==null&&!T,f=r.length;if(u||a){for(o=0;o<f;o++)l=r[o],(u||!((i=l==null?void 0:l.reactions)!=null&&i.includes(t)))&&(l.reactions??(l.reactions=[])).push(t);u&&(t.f^=W)}for(o=0;o<f;o++)if(l=r[o],tt(l)&&Ft(l),l.wv>t.wv)return!0}(!n||p!==null&&!T)&&N(t,b)}return!1}function Oe(t,e){for(var r=e;r!==null;){if(r.f&H)try{r.fn(t);return}catch{r.f^=H}r=r.parent}throw Y=!1,t}function Se(t){return(t.f&Q)===0&&(t.parent===null||(t.parent.f&H)===0)}function et(t,e,r,n){if(Y){if(r===null&&(Y=!1),Se(e))throw t;return}r!==null&&(Y=!0);{Oe(t,e);return}}function jt(t,e,r=0){var n=t.reactions;if(n!==null)for(var o=0;o<n.length;o++){var l=n[o];l.f&k?jt(l,e,r+1):e===l&&(r===0?N(l,P):l.f&b&&N(l,q),Ut(l))}}function Bt(t){var v;var e=h,r=w,n=D,o=_,l=T,u=M,a=d,f=O,i=t.f;h=null,w=0,D=null,_=i&(A|J)?null:t,T=(i&x)!==0&&(!C||o===null||f),M=null,dt(t.ctx),O=!1,z++;try{var g=(0,t.fn)(),c=t.deps;if(h!==null){var s;if(G(t,w),c!==null&&w>0)for(c.length=w+h.length,s=0;s<h.length;s++)c[w+s]=h[s];else t.deps=c=h;if(!T)for(s=w;s<c.length;s++)((v=c[s]).reactions??(v.reactions=[])).push(t)}else c!==null&&w<c.length&&(G(t,w),c.length=w);if(fe()&&D!==null&&!(t.f&(k|q|P)))for(s=0;s<D.length;s++)jt(D[s],t);return o!==null&&z++,g}finally{h=e,w=r,D=n,_=o,T=l,M=u,dt(a),O=f}}function Ne(t,e){let r=e.reactions;if(r!==null){var n=$t.call(r,t);if(n!==-1){var o=r.length-1;o===0?r=e.reactions=null:(r[n]=r[o],r.pop())}}r===null&&e.f&k&&(h===null||!h.includes(e))&&(N(e,q),e.f&(x|W)||(e.f^=W),Dt(e),G(e,0))}function G(t,e){var r=t.deps;if(r!==null)for(var n=e;n<r.length;n++)Ne(t,r[n])}function ft(t){var e=t.f;if(!(e&Q)){N(t,b);var r=p,n=d;p=t;try{e&Qt?Ee(t):Pt(t),Lt(t);var o=Bt(t);t.teardown=typeof o=="function"?o:null,t.wv=qt;var l=t.deps,u;ct&&se&&t.f&P}catch(a){et(a,t,r,n||t.ctx)}finally{p=r}}}function Ae(){if(I>1e3){I=0;try{le()}catch(t){if(X!==null)et(t,X,null);else throw t}}I++}function De(t){var e=t.length;if(e!==0){Ae();var r=C;C=!0;try{for(var n=0;n<e;n++){var o=t[n];o.f&b||(o.f^=b);var l=[];Vt(o,l),Fe(l)}}finally{C=r}}}function Fe(t){var e=t.length;if(e!==0)for(var r=0;r<e;r++){var n=t[r];if(!(n.f&(Q|$)))try{tt(n)&&(ft(n),n.deps===null&&n.first===null&&n.nodes_start===null&&(n.teardown===null?It(n):n.fn=null))}catch(o){et(o,n,null,n.ctx)}}}function Ce(){if(K=!1,I>1001)return;const t=ot;ot=[],De(t),K||(I=0,X=null)}function Ut(t){K||(K=!0,queueMicrotask(Ce)),X=t;for(var e=t;e.parent!==null;){e=e.parent;var r=e.f;if(r&(J|A)){if(!(r&b))return;e.f^=b}}ot.push(e)}function Vt(t,e){var r=t.first,n=[];t:for(;r!==null;){var o=r.f,l=(o&A)!==0,u=l&&(o&b)!==0,a=r.next;if(!u&&!(o&$))if(o&st){if(l)r.f^=b;else{var f=_;try{_=r,tt(r)&&ft(r)}catch(s){et(s,r,null,r.ctx)}finally{_=f}}var i=r.first;if(i!==null){r=i;continue}}else o&yt&&n.push(r);if(a===null){let s=r.parent;for(;s!==null;){if(t===s)break t;var g=s.next;if(g!==null){r=g;continue t}s=s.parent}}r=a}for(var c=0;c<n.length;c++)i=n[c],e.push(i),Vt(i,e)}function Yt(t){var e=t.f,r=(e&k)!==0;if(_!==null&&!O){M!==null&&M.includes(t)&&ue();var n=_.deps;t.rv<z&&(t.rv=z,h===null&&n!==null&&n[w]===t?w++:h===null?h=[t]:(!T||!h.includes(t))&&h.push(t))}else if(r&&t.deps===null&&t.effects===null){var o=t,l=o.parent;l!==null&&!(l.f&x)&&(o.f^=x)}return r&&(o=t,tt(o)&&Ft(o)),t.v}function Re(t){var e=O;try{return O=!0,t()}finally{O=e}}const Le=-7169;function N(t,e){t.f=t.f&Le|e}function Pe(t){if(!(typeof t!="object"||!t||t instanceof EventTarget)){if(pt in t)lt(t);else if(!Array.isArray(t))for(let e in t){const r=t[e];typeof r=="object"&&r&&pt in r&&lt(r)}}}function lt(t,e=new Set){if(typeof t=="object"&&t!==null&&!(t instanceof EventTarget)&&!e.has(t)){e.add(t),t instanceof Date&&t.getTime();for(let n in t)try{lt(t[n],e)}catch{}const r=Gt(t);if(r!==Object.prototype&&r!==Array.prototype&&r!==Map.prototype&&r!==Set.prototype&&r!==Date.prototype){const n=zt(r);for(let o in n){const l=n[o].get;if(l)try{l.call(t)}catch{}}}}}const Ie=["touchstart","touchmove"];function Me(t){return Ie.includes(t)}const Ht=new Set,ut=new Set;function qe(t){for(var e=0;e<t.length;e++)Ht.add(t[e]);for(var r of ut)r(t)}function V(t){var j;var e=this,r=e.ownerDocument,n=t.type,o=((j=t.composedPath)==null?void 0:j.call(t))||[],l=o[0]||t.target,u=0,a=t.__root;if(a){var f=o.indexOf(a);if(f!==-1&&(e===document||e===window)){t.__root=e;return}var i=o.indexOf(e);if(i===-1)return;f<=i&&(u=f)}if(l=o[u]||t.target,l!==e){Xt(t,"currentTarget",{configurable:!0,get(){return l||r}});var g=_,c=p;R(null),L(null);try{for(var s,v=[];l!==null;){var m=l.assignedSlot||l.parentNode||l.host||null;try{var y=l["__"+n];if(y!==void 0&&!l.disabled)if(Wt(y)){var[rt,...nt]=y;rt.apply(l,[t,...nt])}else y.call(l,t)}catch(B){s?v.push(B):s=B}if(t.cancelBubble||m===e||m===null)break;l=m}if(s){for(let B of v)queueMicrotask(()=>{throw B});throw s}}finally{t.__root=e,delete t.currentTarget,R(g),L(c)}}}function je(t){var e=document.createElement("template");return e.innerHTML=t,e.content}function Be(t,e){var r=p;r.nodes_start===null&&(r.nodes_start=t,r.nodes_end=e)}function Ue(t,e){var r=(e&ae)!==0,n,o=!t.startsWith("<!>");return()=>{n===void 0&&(n=je(o?t:"<!>"+t),n=Nt(n));var l=r?document.importNode(n,!0):n.cloneNode(!0);return Be(l,l),l}}function Ve(t,e){t!==null&&t.before(e)}function Ye(t,e){return He(t,e)}const F=new Map;function He(t,{target:e,anchor:r,props:n={},events:o,context:l,intro:u=!0}){_e();var a=new Set,f=c=>{for(var s=0;s<c.length;s++){var v=c[s];if(!a.has(v)){a.add(v);var m=Me(v);e.addEventListener(v,V,{passive:m});var y=F.get(v);y===void 0?(document.addEventListener(v,V,{passive:m}),F.set(v,1)):F.set(v,y+1)}}};f(Kt(Ht)),ut.add(f);var i=void 0,g=me(()=>{var c=r??e.appendChild(ve());return ye(()=>{if(l){Tt({});var s=d;s.c=l}o&&(n.$$events=o),i=t(c,n)||{},l&&kt()}),()=>{var m;for(var s of a){e.removeEventListener(s,V);var v=F.get(s);--v===0?(document.removeEventListener(s,V),F.delete(s)):F.set(s,v)}ut.delete(f),c!==r&&((m=c.parentNode)==null||m.removeChild(c))}});return We.set(i,g),i}let We=new WeakMap;function $e(t=!1){const e=d,r=e.l.u;if(!r)return;let n=()=>Pe(e.s);if(t){let o=0,l={};const u=pe(()=>{let a=!1;const f=e.s;for(const i in f)f[i]!==l[i]&&(l[i]=f[i],a=!0);return a&&o++,o});n=()=>Yt(u)}r.b.length&&we(()=>{bt(e,n),vt(r.b)}),gt(()=>{const o=Re(()=>r.m.map(Jt));return()=>{for(const l of o)typeof l=="function"&&l()}}),r.a.length&&gt(()=>{bt(e,n),vt(r.a)})}function bt(t,e){if(t.l.s)for(const r of t.l.s)Yt(r);e()}const Ke="5";typeof window<"u"&&(window.__svelte||(window.__svelte={v:new Set})).v.add(Ke);ie();const Xe=()=>fetch("https://bolt-api/close-request");var ze=(t,e)=>e("-1","-1"),Ge=(t,e)=>e("0","-1"),Je=(t,e)=>e("1","-1"),Qe=(t,e)=>e("-1","0"),Ze=(t,e)=>e("1","0"),tr=(t,e)=>e("-1","1"),er=(t,e)=>e("0","1"),rr=(t,e)=>e("1","1"),nr=(t,e)=>e("0","0"),or=Ue('<main><div class="absolute grid grid-cols-[5px_auto_5px] grid-rows-[5px_auto_5px] top-0 left-0 bottom-0 right-0 pointer-events-none"><div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="pointer-events-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div> <div class="bg-black pointer-events-auto select-none"></div></div> <div class="m-[7px] w-auto h-auto"><div class="m-0 p-0 b-0 absolute top-[5px] right-[5px] w-[18px] h-[18px]"><button class="m-0 p-0 b-0 absolute top-0 left-0 w-full h-full select-none text-center text-[12px] bg-[hsl(0,70%,50%)] hover:bg-[hsl(0,100%,50%)]">X</button></div> <div class="m-0 p-0 b-0 absolute left-[5px] top-[5px] right-[23px] h-[18px] bg-[grey] text-center text-[10pt]"><p class="m-0 p-0 b-0 color-black select-none pointer-events-none">Alerts</p></div> <div class="fixed top-[21px] bottom-[6px] left-[6px] right-[6px] text-[10pt] pointer-events-none"><p>Hello World</p></div></div></main>');function lr(t,e){Tt(e,!1);const r=(nt,j)=>fetch("https://bolt-api/start-reposition?".concat(new URLSearchParams({h:nt,v:j}).toString()));$e();var n=or(),o=U(n),l=U(o);l.__mousedown=[ze,r];var u=E(l,2);u.__mousedown=[Ge,r];var a=E(u,2);a.__mousedown=[Je,r];var f=E(a,2);f.__mousedown=[Qe,r];var i=E(f,4);i.__mousedown=[Ze,r];var g=E(i,2);g.__mousedown=[tr,r];var c=E(g,2);c.__mousedown=[er,r];var s=E(c,2);s.__mousedown=[rr,r];var v=E(o,2),m=U(v),y=U(m);y.__click=[Xe];var rt=E(m,2);rt.__mousedown=[nr,r],Ve(t,n),kt()}qe(["mousedown","click"]);Ye(lr,{target:document.getElementById("app")});
