package com.google.android.gms.internal.fido;

import M0.C0078n;
import M0.C0079o;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;

/* JADX INFO: loaded from: classes.dex */
public final class zzn extends zza implements IInterface {
    public zzn(IBinder iBinder) {
        super(iBinder, "com.google.android.gms.fido.fido2.internal.privileged.IFido2PrivilegedService");
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final void zzc(zzg zzgVar, String str) {
        Parcel parcelZza = zza();
        int i4 = zzc.zza;
        parcelZza.writeStrongBinder(zzgVar);
        parcelZza.writeString(str);
        zzb(4, parcelZza);
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final void zzd(zzm zzmVar, C0078n c0078n) {
        Parcel parcelZza = zza();
        int i4 = zzc.zza;
        parcelZza.writeStrongBinder(zzmVar);
        zzc.zzd(parcelZza, c0078n);
        zzb(1, parcelZza);
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final void zze(zzm zzmVar, C0079o c0079o) {
        Parcel parcelZza = zza();
        int i4 = zzc.zza;
        parcelZza.writeStrongBinder(zzmVar);
        zzc.zzd(parcelZza, c0079o);
        zzb(2, parcelZza);
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final void zzf(zze zzeVar) {
        Parcel parcelZza = zza();
        int i4 = zzc.zza;
        parcelZza.writeStrongBinder(zzeVar);
        zzb(3, parcelZza);
    }
}
