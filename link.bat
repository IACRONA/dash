@ECHO off

set git_path=C:\Users\ACRONA\Documents\GitHub\dotawarsongs
set dota_path_content=C:\SteamLibrary\steamapps\common\dota 2 beta\content\dota_addons\dotawarsongs
set dota_path_game=C:\SteamLibrary\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs

robocopy %git_path%\content "%dota_path_content%" /mir /move /NFL /NDL /NJH /NJS /nc /ns /np
robocopy %git_path%\game "%dota_path_game%" /mir /move /NFL /NDL /NJH /NJS /nc /ns /np

mklink /j %git_path%\content "%dota_path_content%"
mklink /j %git_path%\game "%dota_path_game%"
pause