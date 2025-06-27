<script lang="ts">
    import { RuleType, type Ruleset, type ConfigRuleset, type AlertRule, type ConfigRule } from './interfaces';
    import { getInitialAlertState } from './common';
    import { get, type Writable } from 'svelte/store';
    import { v4 as randomUUID } from 'uuid';

    let soundEnabled = false;
    let globalFlashTimer = true;
    setInterval(() => {
        globalFlashTimer = !globalFlashTimer;
    }, 350);

    const writeRulesetsToBuffer = (list: Ruleset[], buffer: DataView | null) => {
        let cursor = 0;

        const writeBool = (b: boolean) => {
            if (buffer) buffer.setUint8(cursor, b ? 1 : 0);
            cursor += 1;
        };

        const writeUint = (n: number) => {
            if (buffer) buffer.setUint32(cursor, n, true);
            cursor += 4;
        };

        const writeInt = (n: number) => {
            if (buffer) buffer.setInt32(cursor, n, true);
            cursor += 4;
        };

        const writeString = (s: string) => {
            // is there a better way to do this?
            const array = new TextEncoder().encode(s);
            writeUint(s.length);
            if (buffer) {
                for (let i = 0; i < array.byteLength; i += 1) {
                    buffer.setUint8(cursor + i, array[i]);
                }
            }
            cursor += array.byteLength;
        };

        writeUint(list.length);
        for (const ruleset of list) {
            writeString(ruleset.id);
            writeBool(ruleset.paused);
            writeBool(ruleset.alert);
            writeBool(ruleset.doFlashWindow);
            writeBool(ruleset.onlyIfUnfocused);
            writeUint(Object.keys(ruleset.rules).length);
            for (const rule of Object.values(ruleset.rules)) {
                writeString(rule.id);
                writeString(rule.ruletype);
                const hasAlert = typeof(rule.alert) === 'boolean';
                const hasNumber = typeof(rule.number) === 'number';
                const hasRef = typeof(rule.ref) === 'string';
                const hasComparator = typeof(rule.comparator) === 'string';
                const hasFind = typeof(rule.find) === 'string';
                writeBool(rule.paused);
                writeBool(hasAlert);
                if (hasAlert) writeBool(rule.alert === true);
                writeBool(hasNumber);
                if (hasNumber) writeInt(rule.number!);
                writeBool(hasRef);
                if (hasRef) writeString(rule.ref!);
                writeBool(hasComparator);
                if (hasComparator) writeString(rule.comparator!);
                writeBool(hasFind);
                if (hasFind) writeString(rule.find!);
            }
        }

        return cursor;
    };

    window.addEventListener('message', (event) => {
        if (!event.data || typeof(event.data) !== 'object' || event.data.type !== 'pluginMessage') return;
        const msgType = new Uint16Array(event.data.content.slice(0, 2))[0];
        switch (msgType) {
            case 1: {
                // new or edited ruleset
                const params = new URLSearchParams((new TextDecoder()).decode(event.data.content.slice(2)));
                let id = params.get('id');
                let oldRuleset: Ruleset | null = null;
                if (id) {
                    oldRuleset = get(list)[id];
                } else {
                    id = randomUUID();
                }
                $list[id] = {
                    id,
                    name: params.get('name')!,
                    paused: oldRuleset ? oldRuleset.paused : false,
                    rules: oldRuleset ? oldRuleset.rules : {},
                    expanded: oldRuleset ? oldRuleset.expanded : false,
                    alert: oldRuleset ? oldRuleset.alert : false,
                    doFlashWindow: params.get('flash_window')! === '1',
                    sound: params.get('sound') ?? undefined,
                    volume: parseInt(params.get('volume')!),
                    onlyIfUnfocused: params.get('only_if_unfocused')! === '1',
                };
                break;
            }
            case 2: {
                // new or edited rule
                const params = new URLSearchParams((new TextDecoder()).decode(event.data.content.slice(2)));
                const rulesets = $list;
                const ruleset = rulesets[params.get('ruleset_id')!];
                let id = params.get('id');
                let oldRule: AlertRule | null = null;
                if (id) {
                    oldRule = ruleset.rules[id];
                } else {
                    id = randomUUID();
                }
                const number = params.get('number');
                const ruletype = params.get('type')! as RuleType;
                ruleset.rules[id] = {
                    id,
                    ruletype,
                    paused: oldRule ? oldRule.paused : false,
                    alert: oldRule ? oldRule.alert : getInitialAlertState(ruletype, !!number),
                    number: number ? parseInt(number) : undefined,
                    ref: params.get('ref') ?? undefined,
                    comparator: params.get('comparator') ?? undefined,
                    find: params.get('find') ?? undefined,
                    exacttext: params.get('exacttext') ?? undefined,
                };
                ruleset.expanded = true;
                list.set(rulesets);
                break;
            }
            case 3: {
                // change alert state
                const rulesets = $list;
                const data = new URLSearchParams((new TextDecoder()).decode(event.data.content.slice(2)));
                const ruleset = rulesets[data.get('ruleset_id')!];
                const rule = ruleset.rules[data.get('rule_id')!];
                const alert = data.get('alert')! === '1';
                const hasAlert = typeof(rule.alert) === 'boolean';
                if (hasAlert) {
                    rule.alert = alert;
                }
                let rulesetAlert = false;
                for (let rule of Object.values(ruleset.rules)) {
                    if (rule.alert) {
                        rulesetAlert = true;
                    }
                }
                if ((rulesetAlert && !ruleset.alert) || (alert && !hasAlert)) {
                    if (ruleset.sound && soundEnabled) {
                        const audio = (new Audio('plugin://app/sounds/'.concat(ruleset.sound)));
                        audio.volume = Math.min(Math.max(ruleset.volume / 100.0, 0.0), 1.0);
                        audio.play();
                    }
                }
                ruleset.alert = rulesetAlert;
                doActOnListChange = false;
                doUpdateLuaOnListChange = false;
                list.set(rulesets);
                break;
            }
            default:
                console.error(`unknown message type ${msgType}`);
        }
    });

    let doActOnListChange = false;
    let doUpdateLuaOnListChange = true;
    export let list: Writable<{[id: string]: Ruleset}>;
    $: {
        const rulesets = $list;
        if (doUpdateLuaOnListChange && (doActOnListChange || Object.keys(rulesets).length > 0)) {
            // inform the lua code of our new list of rulesets
            const values = Object.values(rulesets);
            const length = writeRulesetsToBuffer(values, null);
            const buffer = new ArrayBuffer(length + 2);
            (new DataView(buffer, 0, 2)).setUint16(0, 5, true);
            writeRulesetsToBuffer(values, new DataView(buffer, 2, length));
            fetch("https://bolt-api/send-message", { method: 'POST', body: buffer });
        }
        if (doActOnListChange) {
            // save the config file to disk
            const config: ConfigRuleset[] = Object.values(rulesets).map((ruleset): ConfigRuleset => {return {
                name: ruleset.name,
                paused: ruleset.paused,
                rules: Object.values(ruleset.rules).map((x: AlertRule): ConfigRule => {return {
                    ruletype: x.ruletype,
                    paused: x.paused,
                    number: x.number,
                    ref: x.ref,
                    comparator: x.comparator,
                    find: x.find,
                    exacttext: x.exacttext,
                }}),
                doFlashWindow: ruleset.doFlashWindow,
                sound: ruleset.sound,
                volume: ruleset.volume,
                onlyIfUnfocused: ruleset.onlyIfUnfocused,
            }});
            const body = '\x03\x00'.concat(JSON.stringify(config));
            fetch("https://bolt-api/send-message", { method: 'POST', body });
        } else {
            doActOnListChange = true;
        }
        doUpdateLuaOnListChange = true;
    }

    const openNewRulesetMenu = () => fetch("https://bolt-api/send-message", { method: 'POST', body: new Uint8Array([1, 0]) });

    const openEditRulesetMenu = (ruleset: Ruleset) => {
        let params: Record<string, string> = {
            id: ruleset.id,
            name: ruleset.name,
            only_if_unfocused: ruleset.onlyIfUnfocused ? '1' : '0',
            flash_window: ruleset.doFlashWindow ? '1' : '0',
            volume: ruleset.volume.toString(),
        };
        if (ruleset.sound) {
            params['sound'] = ruleset.sound;
        }
        const body = '\x02\x00'.concat(new URLSearchParams(params).toString());
        fetch("https://bolt-api/send-message", { method: 'POST', body });
    };

    const openAddRuleMenu = (ruleset: Ruleset) => {
        let params: Record<string, string> = {
            ruleset_id: ruleset.id,
        };
        const body = '\x04\x00'.concat(new URLSearchParams(params).toString());
        fetch("https://bolt-api/send-message", { method: 'POST', body });
    };

    const openEditRuleMenu = (ruleset: Ruleset, rule: AlertRule) => {
        let params: Record<string, string> = {
            ruleset_id: ruleset.id,
            id: rule.id,
            type: rule.ruletype,
        };
        if (rule.number) params['number'] = rule.number.toString();
        if (rule.ref) params['ref'] = rule.ref;
        if (rule.comparator) params['comparator'] = rule.comparator;
        if (rule.find) params['find'] = rule.find;
        if (rule.exacttext) params['exacttext'] = rule.exacttext;
        const body = '\x04\x00'.concat(new URLSearchParams(params).toString());
        fetch("https://bolt-api/send-message", { method: 'POST', body });
    };

    const deleteRuleset = (ruleset: Ruleset) => {
        const newList = get(list);
        delete newList[ruleset.id];
        list.set(newList);
    };

    const setRulesetAlertState = (ruleset: Ruleset) => {
        ruleset.alert = false;
        if (ruleset.paused) return;
        for (const rule of Object.values(ruleset.rules)) {
            if (rule.alert && !rule.paused) ruleset.alert = true;
        }
    };

    const deleteRule = (ruleset: Ruleset, rule: AlertRule) => {
        delete ruleset.rules[rule.id];
        setRulesetAlertState(ruleset);
        list.set($list);
    }

    const togglePausedRule = (rule: AlertRule, ruleset: Ruleset) => {
        rule.paused = !rule.paused;
        if (rule.alert && rule.paused) {
            rule.alert = false;
            setRulesetAlertState(ruleset);
        }
        list.set($list);
    };

    const togglePausedRuleset = (ruleset: Ruleset) => {
        ruleset.paused = !ruleset.paused;
        setRulesetAlertState(ruleset);
        list.set($list);
    };

    const setExpanded = (ruleset: Ruleset, expanded: boolean) => {
        ruleset.expanded = expanded;
        list = list;
    };

    const getRuleDescription = (rule: AlertRule) => {
        switch (rule.ruletype) {
            case RuleType.afktimer:
                if (typeof(rule.number) !== 'number') return 'afk timer';
                return `afk timer (${Math.floor(rule.number / 1000000.0)} sec)`;
            case RuleType.buff:
                switch (rule.comparator) {
                    case 'active':
                        return `buff '${rule.ref}' active`;
                    case 'inactive':
                        return `buff '${rule.ref}' inactive`;
                    case 'lessthan':
                        return `buff '${rule.ref}' < ${rule.number}`;
                    case 'greaterthan':
                        return `buff '${rule.ref}' > ${rule.number}`;
                    case 'parenslessthan':
                        return `buff '${rule.ref}' parentheses < ${rule.number}`;
                    case 'parenscreaterthan':
                        return `buff '${rule.ref}' parentheses > ${rule.number}`;
                    default:
                        return `buff '${rule.ref}'`;
                }
            case RuleType.chat:
                return `chat text: '${rule.exacttext ?? rule.find}'`;
            case RuleType.craftingprogress:
            if (typeof(rule.number) !== 'number') return 'crafting progress';
                return `crafting progress: ${rule.number}%`;
            case RuleType.model:
                return `3D model: '${rule.ref}'`;
            case RuleType.popup:
                return `popup text: '${rule.exacttext ?? rule.find}'`;
            case RuleType.stat:
                if (typeof(rule.number) !== 'number') return `stat '${rule.ref}'`;
                return `stat '${rule.ref}' < ${rule.number}%`;
            case RuleType.xpgain:
                if (typeof(rule.number) !== 'number') return 'xp gain';
                return `xp gain timeout (${Math.floor(rule.number / 1000000.0)} sec)`;
            default:
                return 'unknown';
        }
    }
</script>

<div>
    {#each Object.values($list) as ruleset, i}
        <div class={"relative w-full text-[8pt] h-[19px] ".concat(ruleset.paused ? "bg-gray-500" : ((ruleset.alert && globalFlashTimer) ? "bg-red-400" : (i & 1 ? "bg-gray-200" : "bg-gray-300")))}>
            {#if ruleset.expanded}
                <button class="h-[14px] w-[14px] pointer-events-auto" onclick={() => setExpanded(ruleset, false)}><img src="plugin://app/images/caret-down-solid.svg" class="w-full h-full" alt="Hide" /></button>
            {:else}
                <button class="h-[14px] w-[14px] pointer-events-auto" onclick={() => setExpanded(ruleset, true)}><img src="plugin://app/images/caret-down-solid.svg" class="w-full h-full rotate-270" alt="Expand" /></button>
            {/if}
            {ruleset.name}
            <button
                class="absolute rounded-lg right-0 top-0 h-[18px] w-[18px] hover:bg-red-500 pointer-events-auto py-0 by-0"
                onclick={() => deleteRuleset(ruleset)}
                title="Delete"
            >
                <img src="plugin://app/images/xmark-solid.svg" class="w-full h-full" alt="Delete" />
            </button>
            <button
                class="absolute rounded-lg right-[14px] top-0 h-[18px] w-[18px] hover:bg-blue-400 pointer-events-auto py-0 by-0"
                onclick={() => openEditRulesetMenu(ruleset)}
                title="Edit"
            >
                <img src="plugin://app/images/gear-solid.svg" class="absolute top-[3px] left-[3px] w-[12px] h-[12px]" alt="Edit" />
            </button>
            <button
                class="absolute rounded-lg right-[27px] top-0 h-[18px] w-[18px] hover:bg-blue-400 pointer-events-auto py-0 by-0"
                onclick={() => togglePausedRuleset(ruleset)}
                title={ruleset.paused ? "Resume" : "Pause"}
            >
                <img src={ruleset.paused ? "plugin://app/images/play-solid.svg" : "plugin://app/images/pause-solid.svg"} class="absolute top-[2px] left-[2px] w-[14px] h-[14px]" alt={ruleset.paused ? "Resume" : "Pause"} />
            </button>
            <button
                class="absolute rounded-lg right-[40px] top-0 h-[18px] w-[18px] hover:bg-emerald-400 pointer-events-auto py-0 by-0"
                onclick={() => openAddRuleMenu(ruleset)}
                title="Add rule"
            >
                <img src="plugin://app/images/plus-solid.svg" class="absolute top-[3px] left-[3px] w-[12px] h-[12px]" alt="Add rule" />
            </button>
        </div>
        {#if ruleset.expanded}
            {#each Object.values(ruleset.rules) as rule}
                <div class={"relative px-1 w-full text-[8pt] h-[19px] ".concat(rule.paused || ruleset.paused ? "bg-gray-500" : ((rule.alert && globalFlashTimer) ? "bg-red-400" : (i & 1 ? "bg-gray-200" : "bg-gray-300")))}>
                    {getRuleDescription(rule)}
                    <button
                        class="absolute rounded-lg right-0 top-0 h-[18px] w-[18px] hover:bg-red-500 pointer-events-auto py-0 by-0"
                        onclick={() => deleteRule(ruleset, rule)}
                        title="Delete"
                    >
                        <img src="plugin://app/images/xmark-solid.svg" class="w-full h-full" alt="Delete" />
                    </button>
                    <button
                        class="absolute rounded-lg right-[14px] top-0 h-[18px] w-[18px] hover:bg-blue-400 pointer-events-auto py-0 by-0"
                        onclick={() => openEditRuleMenu(ruleset, rule)}
                        title="Edit"
                    >
                        <img src="plugin://app/images/gear-solid.svg" class="absolute top-[3px] left-[3px] w-[12px] h-[12px]" alt="Edit" />
                    </button>
                    <button
                        class="absolute rounded-lg right-[27px] top-0 h-[18px] w-[18px] hover:bg-blue-400 pointer-events-auto py-0 by-0"
                        onclick={() => togglePausedRule(rule, ruleset)}
                        title={rule.paused ? "Resume" : "Pause"}
                    >
                        <img src={rule.paused ? "plugin://app/images/play-solid.svg" : "plugin://app/images/pause-solid.svg"} class="absolute top-[2px] left-[2px] w-[14px] h-[14px]" alt={rule.paused ? "Resume" : "Pause"} />
                    </button>
                </div>
            {/each}
        {/if}
    {/each}
    {#if !soundEnabled}
        <button class={"rounded-sm m-1 px-2 py-1 pointer-events-auto hover:opacity-75 ".concat(globalFlashTimer ? "bg-red-400" : "bg-blue-400")} onclick={() => soundEnabled = true}>Enable sounds</button>
    {/if}
    <button class="rounded-sm m-1 px-2 py-1 bg-emerald-400 pointer-events-auto hover:opacity-75" onclick={openNewRulesetMenu}>Add ruleset</button>
</div>
