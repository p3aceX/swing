package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.tasks.OnFailureListener;

/* JADX INFO: loaded from: classes.dex */
final class zzadv implements OnFailureListener {
    public zzadv(zzadt zzadtVar) {
    }

    @Override // com.google.android.gms.tasks.OnFailureListener
    public final void onFailure(Exception exc) {
        zzadt.zza.c(a.m("SmsRetrieverClient failed to start: ", exc.getMessage()), new Object[0]);
    }
}
