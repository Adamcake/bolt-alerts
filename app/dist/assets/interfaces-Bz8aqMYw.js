import{S as l,a8 as S,a9 as k,s as v,aa as A,g as w,ab as u,x as g,z as P,e as E,ac as K,a4 as L,q as M}from"./legacy-mJe-Rq-b.js";function c(r,b=null,z){if(typeof r!="object"||r===null||l in r)return r;const I=L(r);if(I!==S&&I!==k)return r;var a=new Map,_=M(r),x=v(0);_&&a.set("length",v(r.length));var o;return new Proxy(r,{defineProperty(f,e,t){(!("value"in t)||t.configurable===!1||t.enumerable===!1||t.writable===!1)&&K();var n=a.get(e);return n===void 0?(n=v(t.value),a.set(e,n)):g(n,c(t.value,o)),!0},deleteProperty(f,e){var t=a.get(e);if(t===void 0)e in f&&a.set(e,v(u));else{if(_&&typeof e=="string"){var n=a.get("length"),i=Number(e);Number.isInteger(i)&&i<n.v&&g(n,i)}g(t,u),j(x)}return!0},get(f,e,t){var d;if(e===l)return r;var n=a.get(e),i=e in f;if(n===void 0&&(!i||(d=P(f,e))!=null&&d.writable)&&(n=v(c(i?f[e]:u,o)),a.set(e,n)),n!==void 0){var s=w(n);return s===u?void 0:s}return Reflect.get(f,e,t)},getOwnPropertyDescriptor(f,e){var t=Reflect.getOwnPropertyDescriptor(f,e);if(t&&"value"in t){var n=a.get(e);n&&(t.value=w(n))}else if(t===void 0){var i=a.get(e),s=i==null?void 0:i.v;if(i!==void 0&&s!==u)return{enumerable:!0,configurable:!0,value:s,writable:!0}}return t},has(f,e){var s;if(e===l)return!0;var t=a.get(e),n=t!==void 0&&t.v!==u||Reflect.has(f,e);if(t!==void 0||E!==null&&(!n||(s=P(f,e))!=null&&s.writable)){t===void 0&&(t=v(n?c(f[e],o):u),a.set(e,t));var i=w(t);if(i===u)return!1}return n},set(f,e,t,n){var O;var i=a.get(e),s=e in f;if(_&&e==="length")for(var d=t;d<i.v;d+=1){var y=a.get(d+"");y!==void 0?g(y,u):d in f&&(y=v(u),a.set(d+"",y))}i===void 0?(!s||(O=P(f,e))!=null&&O.writable)&&(i=v(void 0),g(i,c(t,o)),a.set(e,i)):(s=i.v!==u,g(i,c(t,o)));var m=Reflect.getOwnPropertyDescriptor(f,e);if(m!=null&&m.set&&m.set.call(n,t),!s){if(_&&typeof e=="string"){var N=a.get("length"),h=Number(e);Number.isInteger(h)&&h>=N.v&&g(N,h+1)}j(x)}return!0},ownKeys(f){w(x);var e=Reflect.ownKeys(f).filter(i=>{var s=a.get(i);return s===void 0||s.v!==u});for(var[t,n]of a)n.v!==u&&!(t in f)&&e.push(t);return e},setPrototypeOf(){A()}})}function j(r,b=1){g(r,r.v+b)}function D(r){return r!==null&&typeof r=="object"&&l in r?r[l]:r}function U(r,b){return Object.is(D(r),D(b))}var q=(r=>(r.afktimer="afktimer",r.buff="buff",r.chat="chat",r.craftingprogress="craftingprogress",r.model="model",r.popup="popup",r.stat="stat",r.xpgain="xpgain",r))(q||{});export{q as R,U as i,c as p};
