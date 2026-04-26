package com.google.android.gms.internal.auth;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.s;
import w0.C0700b;

/* JADX INFO: loaded from: classes.dex */
final class zzbu implements s {
    private final Status zza;
    private C0700b zzb;

    public zzbu(Status status) {
        this.zza = status;
    }

    public final C0700b getResponse() {
        return this.zzb;
    }

    @Override // com.google.android.gms.common.api.s
    public final Status getStatus() {
        return this.zza;
    }

    public zzbu(C0700b c0700b) {
        this.zzb = c0700b;
        this.zza = Status.f3372f;
    }
}
