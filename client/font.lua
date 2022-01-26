local fontId

Citizen.CreateThread(function()
    RegisterFontFile('firesans')
    fontId = RegisterFontId('Fire Sans')
end)

function getFontId()
    return fontId
end