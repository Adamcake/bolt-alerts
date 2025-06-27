<script lang="ts">
  import AlertList from "./AlertList.svelte";
  import { RuleType, type Ruleset, type ConfigRuleset, type AlertRule } from './interfaces';
  import { getInitialAlertState } from "./common";
  import { writable, type Writable } from 'svelte/store';
  import { v4 as randomUUID } from 'uuid';

  // load any previous config from alerts file
  const query = new URLSearchParams(window.location.search);
  let alertList: Writable<{[id: string]: Ruleset}> = ((q) => {
    const alertData = q.get('list');
    if (!alertData) return writable({});
    const alertConfigList: ConfigRuleset[] = JSON.parse(atob(alertData));
    let ret: {[id: string]: Ruleset} = {};
    for (const x of alertConfigList) {
      let rules: { [id: string]: AlertRule; } = {};
      for (const rule of x.rules) {
        const id = randomUUID();
        const ruletype = rule.ruletype as RuleType;
        rules[id] = {
          id,
          ruletype,
          paused: rule.paused ?? false,
          alert: getInitialAlertState(ruletype, !!rule.number),
          number: rule.number,
          ref: rule.ref,
          comparator: rule.comparator,
          find: rule.find,
          exacttext: rule.exacttext,
        };
      }
      const id = randomUUID();
      ret[id] = {
        id,
        name: x.name,
        paused: x.paused ?? false,
        rules,
        expanded: false,
        alert: false,
        doFlashWindow: x.doFlashWindow,
        sound: x.sound,
        volume: x.volume,
        onlyIfUnfocused: x.onlyIfUnfocused,
      }
    }
    return writable(ret);
  })(query);

  const startDrag = (h: string, v: string) => fetch('https://bolt-api/start-reposition?'.concat(new URLSearchParams({h, v}).toString()));
  const close = () => fetch('https://bolt-api/close-request');
</script>

<main>
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="absolute grid grid-cols-[5px_auto_5px] grid-rows-[5px_auto_5px] top-0 left-0 bottom-0 right-0 z-100 pointer-events-none">
    <div class="bg-black pointer-events-auto select-none" onmousedown={(e) => {if (e.button === 0) startDrag('-1', '-1')}}></div>
    <div class="bg-black pointer-events-auto select-none" onmousedown={(e) => {if (e.button === 0) startDrag('0', '-1')}}></div>
    <div class="bg-black pointer-events-auto select-none" onmousedown={(e) => {if (e.button === 0) startDrag('1', '-1')}}></div>
    <div class="bg-black pointer-events-auto select-none" onmousedown={(e) => {if (e.button === 0) startDrag('-1', '0')}}></div>
    <div class="pointer-events-none"></div>
    <div class="bg-black pointer-events-auto select-none" onmousedown={(e) => {if (e.button === 0) startDrag('1', '0')}}></div>
    <div class="bg-black pointer-events-auto select-none" onmousedown={(e) => {if (e.button === 0) startDrag('-1', '1')}}></div>
    <div class="bg-black pointer-events-auto select-none" onmousedown={(e) => {if (e.button === 0) startDrag('0', '1')}}></div>
    <div class="bg-black pointer-events-auto select-none" onmousedown={(e) => {if (e.button === 0) startDrag('1', '1')}}></div>
  </div>

  <div class="m-[7px] w-auto h-auto">
    <div class="m-0 p-0 border-b border-black absolute top-[5px] right-[5px] w-[18px] h-[19px]">
      <button class="m-0 p-0 absolute top-0 left-0 w-full h-full select-none text-center text-[12px] bg-[hsl(0,70%,50%)] hover:bg-[hsl(0,100%,50%)]" onclick={close}>X</button>
    </div>
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div class="m-0 p-0 border-b border-black absolute left-[5px] top-[5px] right-[23px] h-[19px] bg-[grey] text-center text-[10pt]" onmousedown={(e) => {if (e.button === 0) startDrag('0', '0')}}>
      <p class="m-0 p-0 color-black select-none pointer-events-none">Alerts</p>
    </div>
    <div class="fixed top-[24px] bottom-[6px] left-[5px] right-[5px] text-[10pt] pointer-events-none">
      <AlertList bind:list={alertList} />
    </div>
  </div>
</main>
