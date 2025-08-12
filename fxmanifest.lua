fx_version 'cerulean'
game 'gta5'

author 'donk'
description 'Simple Admin Commands for your server'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

lua54 'yes'
