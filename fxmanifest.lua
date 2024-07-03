fx_version 'cerulean'
game 'gta5'
lua54 'yes'


client_scripts {
    'configs/config_main.lua',
    'src/client/c_main.lua'
  }
  
  server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'src/server/s_framework.lua',
    'configs/sv_webhook.lua',
    'src/server/s_main.lua',
  }
   
  shared_scripts {
    '@ox_lib/init.lua',
    'configs/locales.lua',
    'configs/config_main.lua',
    'configs/utils.lua',
  }
  