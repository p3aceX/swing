package com.google.android.gms.internal.auth;

import android.accounts.Account;
import android.os.Bundle;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import com.google.android.gms.common.api.internal.InterfaceC0261i;
import q0.C0628b;

/* JADX INFO: loaded from: classes.dex */
public final class zzp extends zza implements IInterface {
    public zzp(IBinder iBinder) {
        super(iBinder, "com.google.android.gms.auth.account.data.IGoogleAuthService");
    }

    public final void zzd(InterfaceC0261i interfaceC0261i, zzbw zzbwVar) {
        Parcel parcelZza = zza();
        zzc.zzd(parcelZza, interfaceC0261i);
        zzc.zzc(parcelZza, zzbwVar);
        zzc(2, parcelZza);
    }

    public final void zze(zzm zzmVar, C0628b c0628b) {
        Parcel parcelZza = zza();
        zzc.zzd(parcelZza, zzmVar);
        zzc.zzc(parcelZza, c0628b);
        zzc(4, parcelZza);
    }

    public final void zzf(zzo zzoVar, Account account, String str, Bundle bundle) {
        Parcel parcelZza = zza();
        zzc.zzd(parcelZza, zzoVar);
        zzc.zzc(parcelZza, account);
        parcelZza.writeString(str);
        zzc.zzc(parcelZza, bundle);
        zzc(1, parcelZza);
    }

    public final void zzg(zzk zzkVar, Account account) {
        Parcel parcelZza = zza();
        zzc.zzd(parcelZza, zzkVar);
        zzc.zzc(parcelZza, account);
        zzc(6, parcelZza);
    }

    public final void zzh(zzk zzkVar, String str) {
        Parcel parcelZza = zza();
        zzc.zzd(parcelZza, zzkVar);
        parcelZza.writeString(str);
        zzc(3, parcelZza);
    }
}
