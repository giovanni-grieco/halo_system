// Aggiunge le azioni solo al terminale
if (hasInterface) then {
    waitUntil { !isNull halo_terminal };

    halo_terminal addAction ["Subscribe to next Halo Jump", {
        [player] remoteExec ["fnc_halo_addPlayer", 2];
    }];

    halo_terminal addAction ["Unsubscribe to next Halo Jump", {
        [player] remoteExec ["fnc_halo_removePlayer", 2];
    }];

    halo_terminal addAction ["Perform HALO Jump", {
        // Solo se il giocatore è iscritto
        [] remoteExec ["fnc_halo_launch", 2];
    }];
};
