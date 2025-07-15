fx_version 'cerulean'
game 'gta5'

author 'donk'
description 'Simple Admin Commands for your server'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'locales/en.lua', -- Change to the language you want
}

client_scripts {
    'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

lua54 'yes'
