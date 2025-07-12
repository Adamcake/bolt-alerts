<script lang="ts">
    import { RuleType } from './interfaces';
    let params = new URLSearchParams(window.location.search);
    let ruleTypeParam = params.get('type');
    let numberParam = params.get('number');
    let exactText = params.get('exacttext');

    let id: string | null = params.get('id');
    let rulesetId: string = params.get('ruleset_id')!;
    let ruleType: RuleType | null = ruleTypeParam ? (ruleTypeParam as RuleType) : null;
    let number: number | null = numberParam ? parseInt(numberParam) : null;
    let ref: string | null = params.get('ref');
    let comparator: string | null = params.get('comparator');
    let find: string | null = params.get('find');

    let afkTimeoutValue: number;
    let matchTypeIsExact: boolean = find === null || exactText !== null;
    let findExactValue: string = exactText ?? '';
    let xpGainModeIsTimeout: boolean | null = null;
    let xpGainTimeoutValue: number;

    if (ruleType === RuleType.afktimer && number) {
        afkTimeoutValue = Math.floor(number / 1000000.0);
    } else if (ruleType === RuleType.xpgain && number) {
        xpGainTimeoutValue = Math.floor(number / 1000000.0);
    }

    $: valid =
        (ruleType === RuleType.afktimer && number !== null) ||
        (ruleType === RuleType.buff && ref !== null && comparator !== null && (number !== null || comparator === 'active' || comparator === 'inactive')) ||
        (ruleType === RuleType.chat && find !== null) ||
        (ruleType === RuleType.craftingprogress && number !== null) ||
        (ruleType === RuleType.model && ref !== null) ||
        (ruleType === RuleType.popup && find !== null) ||
        (ruleType === RuleType.stat && ref !== null && number !== null) ||
        (ruleType === RuleType.xpgain && ((number !== null && xpGainModeIsTimeout === true) || xpGainModeIsTimeout === false));

    const onTypeChange = () => {
        switch (ruleType) {
            case RuleType.afktimer:
                afkTimeoutValue = 60 * 14;
                number = afkTimeoutValue * 1000000;
                break;
            case RuleType.buff:
                ref = null;
                number = null;
                comparator = null;
                break;
            case RuleType.chat:
                find = null;
                break;
            case RuleType.model:
                ref = null;
                break;
            case RuleType.popup:
                find = null;
                break;
            case RuleType.stat:
                ref = null;
                number = null;
                break;
            case RuleType.xpgain:
                number = null;
                break;
            case RuleType.craftingprogress:
                number = null;
                break;
        }
    };

    // add '^' at the start to make a pattern that only matches strings starting with the exact value,
    // then escape all the characters found here: https://www.lua.org/pil/20.2.html
    // note: it lists ')' but not ']', not sure if that's correct but it does work as expected anyway.
    const exactToPattern = (s: string): string => '^'.concat(
        findExactValue
            .replaceAll('%', '%%')
            .replaceAll('(', '%(')
            .replaceAll(')', '%)')
            .replaceAll('.', '%.')
            .replaceAll('+', '%+')
            .replaceAll('-', '%-')
            .replaceAll('*', '%*')
            .replaceAll('?', '%?')
            .replaceAll('[', '%[')
            .replaceAll('^', '%^')
            .replaceAll('$', '%$')
    )

    const getPostBody = () => {
        let params: Record<string, string> = {
            ruleset_id: rulesetId,
            type: ruleType!,
        };
        if (id) params['id'] = id;
        if (number) params['number'] = number.toString();
        if (ref) params['ref'] = ref;
        if (comparator) params['comparator'] = comparator;
        if (find) params['find'] = find;
        if (matchTypeIsExact) params['exacttext'] = findExactValue;
        return '\x02\x00'.concat(new URLSearchParams(params).toString());
    }

    const save = () => fetch("https://bolt-api/send-message", {method: 'POST', body: getPostBody()});
    const cancel = () => fetch("https://bolt-api/close-request");
</script>

<div class="mx-2 my-1 p-0 b-0 text-gray-200">
    {#if id === null}
        <p class="text-[16pt] font-bold">New Rule</p>
        <p class="text-[10pt]">A rule decides when you want to be alerted. When this condition becomes active, the ruleset will send you an alert.</p>
    {:else}
    <p class="text-[16pt] font-bold">Edit Rule</p>
    {/if}
    <hr class="my-4 opacity-40">
    <div class="text-[8pt] w-auto">
        <label for="1" class="font-italic">Rule type:</label>
        <br>
        <select id="1" bind:value={ruleType} onchange={onTypeChange} class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0">
            <option class="text-black" value={RuleType.afktimer}>AFK timer</option>
            <option class="text-black" value={RuleType.buff}>Buffs/debuffs</option>
            <option class="text-black" value={RuleType.chat}>Chat text</option>
            <option class="text-black" value={RuleType.craftingprogress}>Crafting progress</option>
            <option class="text-black" value={RuleType.model}>3D object</option>
            <option class="text-black" value={RuleType.popup}>Popup text</option>
            <option class="text-black" value={RuleType.stat}>Stat bars</option>
            <option class="text-black" value={RuleType.xpgain}>XP gain</option>
        </select>
        <br><br>
        {#if ruleType === RuleType.afktimer}
            <label for="2">Timeout (seconds):</label>
            <br>
            <input
                id="2"
                type="number"
                class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0"
                bind:value={afkTimeoutValue}
                onchange={() => number = Math.floor(afkTimeoutValue * 1000000)}
            />
        {:else if ruleType === RuleType.buff}
            <label for="3">Buff or debuff:</label>
            <br>
            <select id="3" bind:value={ref} class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0">
                <optgroup class="text-black" label="Potions">
                    <option value="noadrenalinepotion">Adrenaline Potion Cooldown</option>
                    <option value="aggressionpotion">Aggression Potion</option>
                    <option value="antifire">Antifire</option>
                    <option value="antipoison">Antipoison</option>
                    <option value="overload">Overload</option>
                    <option value="perfectplus">Perfect Plus</option>
                    <option value="poisonous">Poisonous</option>
                    <option value="nopowerburst">Powerburst Cooldown</option>
                    <option value="prayerrenewal">Prayer Renewal</option>
                    <option value="spiritattractionpotion">Spirit Attraction Potion</option>
                </optgroup>
                <optgroup class="text-black" label="Powders">
                    <option value="powderofburials">Powder of Burials</option>
                    <option value="powderofdefence">Powder of Defence</option>
                    <option value="powderofitemprotection">Powder of Item Protection</option>
                    <option value="powderofpenance">Powder of Penance</option>
                    <option value="powderofprotection">Powder of Protection</option>
                    <option value="powderofpulverising">Powder of Pulverising</option>
                </optgroup>
                <optgroup class="text-black" label="Incense">
                    <option value="incenseavantoe">Avantoe Incense</option>
                    <option value="incensecadantine">Cadantine Incense</option>
                    <option value="incensedwarfweed">Dwarfweed Incense</option>
                    <option value="incensefellstalk">Fellstalk Incense</option>
                    <option value="incenseguam">Guam Incense</option>
                    <option value="incenseharralander">Harralander Incense</option>
                    <option value="incenseirit">Irit Incense</option>
                    <option value="incensekwuarm">Kwuarm Incense</option>
                    <option value="incenselantadyme">Lantadyme Incense</option>
                    <option value="incensemarrentill">Marrentill Incense</option>
                    <option value="incenseranarr">Ranarr Incense</option>
                    <option value="incensesnapdragon">Snapdragon Incense</option>
                    <option value="incensespiritweed">Spiritweed Incense</option>
                    <option value="incensetarromin">Tarromin Incense</option>
                    <option value="incensetoadflax">Toadflax Incense</option>
                    <option value="incensetorstol">Torstol Incense</option>
                    <option value="incensewergali">Wergali Incense</option>
                </optgroup>
                <optgroup class="text-black" label="Miscellaneous">
                    <option value="animatedead">Animate Dead</option>
                    <option value="archaeologiststea">Archaeologist's Tea</option>
                    <option value="aura">Aura</option>
                    <option value="bonfire">Bonfire</option>
                    <option value="cannonballs">Cannonballs</option>
                    <option value="cannontimer">Cannon Timer</option>
                    <option value="cindercore">Cinder Core</option>
                    <option value="clancitadel">Clan Citadel Buff</option>
                    <option value="crystalmask">Crystal Mask</option>
                    <option value="darkness">Darkness</option>
                    <option value="noritualshard">Elven Ritual Shard Cooldown</option>
                    <option value="noexcalibur">Excalibur Cooldown</option>
                    <option value="firelighter">Firelighter</option>
                    <option value="godbook">God Book</option>
                    <option value="grimoire">Grimoire</option>
                    <option value="hispecmonocle">Hi-spec Monocle</option>
                    <option value="loveletter">Love Letter</option>
                    <option value="luminiteinjector">Luminite Injector</option>
                    <option value="materialmanual">Material Manual</option>
                    <option value="porter">Porter</option>
                    <option value="proteanpowerup">Protean Powerup</option>
                    <option value="pulsecore">Pulse Core</option>
                    <option value="roarofosseous">Roar of Osseous</option>
                    <option value="rockofresilience">Rock of Resilience</option>
                    <option value="scrimshaw">Scrimshaw</option>
                    <option value="signoflife">Sign of Life</option>
                    <option value="stoneofjas">Stone of Jas (glacor cavern)</option>
                    <option value="summon">Summon</option>
                    <option value="tarpaulinsheet">Tarpaulin Sheet</option>
                    <option value="valentinesflip">Valentine's Flip</option>
                    <option value="valentinesslam">Valentine's Slam</option>
                    <option value="wiseperk">Wise Perk</option>
                </optgroup>
            </select>
            <br><br>
            <label for="4">Alert when the buff is:</label>
            <br>
            <select id="4" bind:value={comparator} class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0">
                <option class="text-black" value="active">Active</option>
                <option class="text-black" value="inactive">Inactive</option>
                <option class="text-black" value="lessthan">Less than</option>
                <option class="text-black" value="greaterthan">Greater than</option>
                <option class="text-black" value="parenslessthan">Parentheses less than</option>
                <option class="text-black" value="greater than">Parentheses greater than</option>
            </select>
            <br>
            {#if comparator !== null && comparator !== 'active' && comparator !== 'inactive'}
                <label for="5">This number:</label>
                <br>
                <input
                    id="5"
                    type="number"
                    class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0"
                    bind:value={number}
                />
            {/if}
        {:else if ruleType === RuleType.chat || ruleType === RuleType.popup}
            <label for="6">Match type:</label>
            <br>
            <select id="6" bind:value={matchTypeIsExact} class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0">
                <option class="text-black" value={true}>Exact</option>
                <option class="text-black" value={false}>Pattern</option>
            </select>
            <br><br>
            {#if matchTypeIsExact}
                <label for="7">Text:</label>
                <br>
                <input
                    id="7"
                    type="text"
                    class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0"
                    bind:value={findExactValue}
                    onchange={() => find = exactToPattern(findExactValue)}
                />
            {:else}
                <label for="7">Pattern:</label>
                <br>
                <input
                    id="7"
                    type="text"
                    class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0"
                    bind:value={find}
                />
            {/if}
        {:else if ruleType === RuleType.craftingprogress}
            <label for="8">Threshold (percent):</label>
            <br>
            <input
                id="8"
                type="number"
                class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0"
                bind:value={number}
            />
        {:else if ruleType === RuleType.model}
            <label for="9">Model:</label>
            <br>
            <select id="9" bind:value={ref} class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0">
                <option class="text-black" value="chroniclefragment">Chronicle Fragment</option>
                <option class="text-black" value="divineblessing">Divine blessing</option>
                <option class="text-black" value="lostsoul">Elidinis spirits</option>
                <option class="text-black" value="eliteslayermob">Elite slayer mobs</option>
                <option class="text-black" value="firespirit">Fire spirits</option>
                <option class="text-black" value="manifestedknowledge">Manifested Knowledge</option>
                <option class="text-black" value="penguinagent">Penguin agents 001-007</option>
                <option class="text-black" value="serenspirit">Seren spirits</option>
            </select>
        {:else if ruleType === RuleType.stat}
            <label for="a">Stat:</label>
            <br>
            <select id="a" bind:value={ref} class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0">
                <option class="text-black" value="health">Health</option>
                <option class="text-black" value="adrenaline">Adrenaline</option>
                <option class="text-black" value="prayer">Prayer</option>
                <option class="text-black" value="summoning">Summoning</option>
            </select>
            <br><br>
            <label for="b">Threshold (percent):</label>
            <br>
            <input
                id="b"
                type="number"
                class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0"
                bind:value={number}
            />
        {:else if ruleType === RuleType.xpgain}
            <label for="c">Mode:</label>
            <br>
            <select id="c" bind:value={xpGainModeIsTimeout} class="border-1 px-[3px] py-[2px] border-white text-white text-[10pt] focus:border-3 focus:px-[1px] focus:py-0">
                <option class="text-black" value={false}>Alert on XP gain</option>
                <option class="text-black" value={true}>Alert on timeout</option>
            </select>
            {#if xpGainModeIsTimeout}
                <br><br>
                <label for="d">Timeout (seconds):</label>
                <br>
                <input
                    id="d"
                    type="number"
                    class="border-gray-200 text-[12pt] border-1 w-full max-w-[260px] px-[3px] py-[2px] border-black focus:border-3 focus:px-[1px] focus:py-0"
                    bind:value={xpGainTimeoutValue}
                    onchange={() => number = Math.floor(xpGainTimeoutValue * 1000000)}
                />
            {/if}
        {/if}
    </div>
    <span>
        <button class="w-25 bg-red-500 rounded-sm py-1 px-2 mr-1 mt-4 font-bold text-white text-center hover:opacity-75" onclick={cancel}>Cancel</button>
        <button
            class="w-25 bg-blue-500 rounded-sm py-1 px-2 mt-4 font-bold text-white text-center enabled:hover:opacity-75 disabled:bg-gray-500"
            disabled={!valid}
            onclick={save}
        >Save</button>
    </span>
</div>
