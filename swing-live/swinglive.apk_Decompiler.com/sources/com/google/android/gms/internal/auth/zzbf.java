package com.google.android.gms.internal.auth;

import android.os.Parcel;
import w0.C0700b;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzbf extends zzb implements zzbg {
    public zzbf() {
        super("com.google.android.gms.auth.api.internal.IAuthCallbacks");
    }

    @Override // com.google.android.gms.internal.auth.zzb
    public final boolean zza(int i4, Parcel parcel, Parcel parcel2, int i5) {
        if (i4 == 1) {
            C0700b c0700b = (C0700b) zzc.zza(parcel, C0700b.CREATOR);
            zzc.zzb(parcel);
            zzb(c0700b);
        } else {
            if (i4 != 2) {
                return false;
            }
            String string = parcel.readString();
            zzc.zzb(parcel);
            zzc(string);
        }
        parcel2.writeNoException();
        return true;
    }
}
