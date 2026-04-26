package com.google.android.gms.internal.p002firebaseauthapi;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import com.google.android.gms.common.api.Status;

/* JADX INFO: loaded from: classes.dex */
final class zzadx extends BroadcastReceiver {
    private final String zza;
    private final /* synthetic */ zzadt zzb;

    public zzadx(zzadt zzadtVar, String str) {
        this.zzb = zzadtVar;
        this.zza = str;
    }

    @Override // android.content.BroadcastReceiver
    public final void onReceive(Context context, Intent intent) {
        if ("com.google.android.gms.auth.api.phone.SMS_RETRIEVED".equals(intent.getAction())) {
            Bundle extras = intent.getExtras();
            if (((Status) extras.get("com.google.android.gms.auth.api.phone.EXTRA_STATUS")).f3378b == 0) {
                String str = (String) extras.get("com.google.android.gms.auth.api.phone.EXTRA_SMS_MESSAGE");
                zzaea zzaeaVar = (zzaea) this.zzb.zzd.get(this.zza);
                if (zzaeaVar == null) {
                    zzadt.zza.c("Verification code received with no active retrieval session.", new Object[0]);
                } else {
                    String strZza = zzadt.zza(str);
                    zzaeaVar.zze = strZza;
                    if (strZza == null) {
                        zzadt.zza.c("Unable to extract verification code.", new Object[0]);
                    } else if (!zzah.zzc(zzaeaVar.zzd)) {
                        zzadt.zza(this.zzb, this.zza);
                    }
                }
            }
            context.getApplicationContext().unregisterReceiver(this);
        }
    }
}
