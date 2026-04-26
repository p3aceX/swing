package com.google.android.gms.internal.auth;

import K.k;
import android.os.Parcel;
import com.google.android.gms.common.api.Status;
import t0.C0671a;
import t0.C0672b;
import t0.f;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzas extends zzb implements zzat {
    public zzas() {
        super("com.google.android.gms.auth.api.accounttransfer.internal.IAccountTransferCallbacks");
    }

    @Override // com.google.android.gms.internal.auth.zzb
    public final boolean zza(int i4, Parcel parcel, Parcel parcel2, int i5) {
        switch (i4) {
            case 1:
                Status status = (Status) zzc.zza(parcel, Status.CREATOR);
                zzc.zzb(parcel);
                zzh(status);
                return true;
            case 2:
                Status status2 = (Status) zzc.zza(parcel, Status.CREATOR);
                f fVar = (f) zzc.zza(parcel, f.CREATOR);
                zzc.zzb(parcel);
                zzf(status2, fVar);
                return true;
            case 3:
                Status status3 = (Status) zzc.zza(parcel, Status.CREATOR);
                C0672b c0672b = (C0672b) zzc.zza(parcel, C0672b.CREATOR);
                zzc.zzb(parcel);
                zzg(status3, c0672b);
                return true;
            case 4:
                zze();
                return true;
            case 5:
                Status status4 = (Status) zzc.zza(parcel, Status.CREATOR);
                zzc.zzb(parcel);
                zzd(status4);
                return true;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                byte[] bArrCreateByteArray = parcel.createByteArray();
                zzc.zzb(parcel);
                zzb(bArrCreateByteArray);
                return true;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                C0671a c0671a = (C0671a) zzc.zza(parcel, C0671a.CREATOR);
                zzc.zzb(parcel);
                zzc(c0671a);
                return true;
            default:
                return false;
        }
    }
}
