import { parse } from 'csv-parse';
import {} from 'lua-json';
import { createPreset } from './createPreset';

type BuildResponseItem = {
    product: string;
    version: string;
    created_at: string;
    build_config: string;
    product_config: string;
    cdn_config: string;
}

type BuildResponse = {
    wow: BuildResponseItem
} 

type FlyoutItemsTableItem = {
    ID: string;
    SpellID: string;
    Slot: string;
    SpellFlyoutID: string;
}

async function getLatestRetailBuildVersion() {
    const response = await fetch('https://wago.tools/api/builds/latest');
    const build = await response.json() as BuildResponse;

    return build.wow.version
}

const portalFlyoutItems = [
    '84', // mop
    '96', // wod
    '220', // SL dung
    '222', // SL Raid
    '223', // BFA
    '224', // Legion
    '227', // DF dung
    '230', // Cata
    '231', // DF Raid
    '232' // TWW
]

function parseCsv(csv: string): Promise<FlyoutItemsTableItem[]> {
    return new Promise((resolve, reject) => {
        parse(csv, {
            columns: true
        }, (err, records) => {
            if (err) {
                reject(err);
            } else {
                resolve(records)
            }
        })
    })
}

async function main() {
    const build = await getLatestRetailBuildVersion();
    const response = await fetch(`https://wago.tools/db2/SpellFlyoutItem/csv?build=${build}`);
    const csv = await response.text() as any;
    const flyoutItems = await parseCsv(csv);
    const portals = flyoutItems.filter(item => portalFlyoutItems.includes(item.SpellFlyoutID)).map(item => item.SpellID);
    
    createPreset(portals, 'Portals', 'SPELL');
}

main()