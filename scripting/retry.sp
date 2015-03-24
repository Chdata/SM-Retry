#include <sourcemod>

public OnPluginStart()
{
    RegConsoleCmd("sm_retry", Reconnect);
    RegConsoleCmd("sm_rejoin", Reconnect);
    RegConsoleCmd("sm_reconnect", Reconnect);
    LoadTranslations("ch.retry.phrases");
}

public Action:Reconnect(iClient, iArgc)
{   
    decl String:target_name[MAX_TARGET_LENGTH];
    GetClientName(iClient, target_name, sizeof(target_name));

    if (!iArgc)
    {
        ShowActivity2(iClient, "[SM] ", "%t", "Reconnected target", "_s", target_name); // "Reconnected by admin"
        ReplyToCommand(iClient, "[SM] %t", "Reconnected target", "_s", target_name);
        //LogAction(iClient, iClient, "\"%L\" reconnected \"%L\" (reason \"%s\")", iClient, iClient, reason);
        ClientCommand(iClient, "retry");
    }
    else if (CheckCommandAccess(iClient, "sm_retry", ADMFLAG_KICK))
    {
        decl String:szArguments[256];
        GetCmdArgString(szArguments, sizeof(szArguments));

        decl String:szTarget[65];
        new len = BreakString(szArguments, szTarget, sizeof(szTarget));
        
        if (len == -1)
        {
            /* Safely null terminate */
            len = 0;
            szArguments[0] = '\0';
        }

        decl String:reason[64];
        Format(reason, sizeof(reason), szArguments[len]);

        if (StrEqual(szTarget, "@me"))
        {
            if (reason[0] == '\0')
            {
                ShowActivity2(iClient, "[SM] ", "%t", "Reconnected target", "_s", target_name);
                ReplyToCommand(iClient, "[SM] %t", "Reconnected target", "_s", target_name);
            }
            else
            {
                ShowActivity2(iClient, "[SM] ", "%t", "Reconnected target reason", "_s", target_name, reason);
                ReplyToCommand(iClient, "[SM] %t", "Reconnected target reason", "_s", target_name, reason);
            }

            //LogAction(iClient, iClient, "\"%L\" reconnected \"%L\" (reason \"%s\")", iClient, iClient, reason);

            ClientCommand(iClient, "retry");
            return Plugin_Handled;
        }

        decl target_list[MAXPLAYERS+1], target_count, bool:tn_is_ml;
        
        if ((target_count = ProcessTargetString(
                szTarget,
                iClient, 
                target_list, 
                MAXPLAYERS, 
                COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS,
                target_name,
                sizeof(target_name),
                tn_is_ml)) > 0)
        {
            if (tn_is_ml)
            {
                if (reason[0] == '\0')
                {
                    ShowActivity2(iClient, "[SM] ", "%t", "Reconnected target", target_name);
                    ReplyToCommand(iClient, "[SM] %t", "Reconnected target", target_name);
                }
                else
                {
                    ShowActivity2(iClient, "[SM] ", "%t", "Reconnected target reason", target_name, reason);
                    ReplyToCommand(iClient, "[SM] %t", "Reconnected target reason", target_name, reason);
                }
            }
            else
            {
                if (reason[0] == '\0')
                {
                    ShowActivity2(iClient, "[SM] ", "%t", "Reconnected target", "_s", target_name);
                    ReplyToCommand(iClient, "[SM] %t", "Reconnected target", "_s", target_name);
                }
                else
                {
                    ShowActivity2(iClient, "[SM] ", "%t", "Reconnected target reason", "_s", target_name, reason);
                    ReplyToCommand(iClient, "[SM] %t", "Reconnected target reason", "_s", target_name, reason);
                }
            }

            new kick_self = 0;
            
            for (new i = 0; i < target_count; i++)
            {
                /* Kick everyone else first */
                if (target_list[i] == iClient)
                {
                    kick_self = iClient;
                }
                else
                {
                    ClientCommand(target_list[i], "retry");
                    //LogAction(iClient, target_list[i], "\"%L\" reconnected \"%L\" (reason \"%s\")", iClient, target_list[i], reason);
                }
            }
            
            if (kick_self)
            {
                //LogAction(iClient, iClient, "\"%L\" reconnected \"%L\" (reason \"%s\")", iClient, iClient, reason);
                ClientCommand(iClient, "retry");
            }
        }
        else
        {
            ReplyToTargetError(iClient, target_count);
        }
    }
    else
    {
        ReplyToCommand(iClient, "[SM] You cannot target other players.");
    }
    
    return Plugin_Handled;
}
