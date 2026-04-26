package com.google.android.gms.internal.auth;

import android.accounts.Account;
import android.os.Bundle;
import com.google.android.gms.common.api.internal.C0253a;
import com.google.android.gms.tasks.Task;
import q0.C0628b;

/* JADX INFO: loaded from: classes.dex */
public interface zzg {
    /* synthetic */ C0253a getApiKey();

    Task zza(zzbw zzbwVar);

    Task zzb(C0628b c0628b);

    Task zzc(Account account, String str, Bundle bundle);

    Task zzd(Account account);

    Task zze(String str);
}
