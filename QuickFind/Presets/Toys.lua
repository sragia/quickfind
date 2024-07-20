local _, QF = ...

QF.createPreset({
    type = 'TOY',
    name = 'Toys',
    all = true,
    getData = function () return {} end,
})
