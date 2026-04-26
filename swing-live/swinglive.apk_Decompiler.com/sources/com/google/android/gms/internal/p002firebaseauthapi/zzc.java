package com.google.android.gms.internal.p002firebaseauthapi;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import r.h;

/* JADX INFO: loaded from: classes.dex */
public final class zzc extends h {
    @Deprecated
    public static Intent zza(Context context, BroadcastReceiver broadcastReceiver, IntentFilter intentFilter) {
        if (zza.zza()) {
            return context.registerReceiver(broadcastReceiver, intentFilter, zza.zza() ? 2 : 0);
        }
        return context.registerReceiver(broadcastReceiver, intentFilter);
    }
}
