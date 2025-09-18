if not exist .\mod\halo_system\addons\ mkdir .\mod\halo_system\addons\
	mkdir .\halo_system\
	copy .\src\*.sqf .\halo_system\
	copy .\src\config.cpp .\halo_system\
	pboc.exe pack .\halo_system
	move .\halo_system.pbo .\mod\halo_system\addons\halo_system.pbo
	copy .\src\mod.cpp .\mod\halo_system\mod.cpp
	powershell -Command "Remove-Item .\halo_system -Recurse -Force"