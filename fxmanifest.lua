-- manifest.lua (fxmanifest.lua)
fx_version 'cerulean'
game 'gta5'

author 'RDE | SerpentsByte'
description 'Not so much Kung Fu Combatsystem for FiveM'
version '1.1.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql'
}

lua54 'yes'