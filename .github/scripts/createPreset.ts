import {format} from 'lua-json';
import { writeFileSync } from "fs";


export function createPreset(data: any, name: string, type: 'SPELL', description?: string): void {
    const lua = `local _, QF = ...

    QF.createPreset({
        type = '${type}',
        name = '${name}',
        description = '${description || ''}',
        getData = function()
            ${format(data)}
        end
    })`

    writeFileSync(`../../QuickFind/Presets/${name.replace(' ', '_')}.lua`, lua);
}