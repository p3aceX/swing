package com.google.android.gms.internal.auth;

import A0.a;
import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;

/* JADX INFO: loaded from: classes.dex */
public final class zzbb extends a {
    public static final Parcelable.Creator<zzbb> CREATOR = new zzbc();
    final int zza;
    public final String zzb;
    public final PendingIntent zzc;

    public zzbb(int i4, String str, PendingIntent pendingIntent) {
        this.zza = 1;
        F.g(str);
        this.zzb = str;
        F.g(pendingIntent);
        this.zzc = pendingIntent;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        int i5 = this.zza;
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(i5);
        AbstractC0184a.i0(parcel, 2, this.zzb, false);
        AbstractC0184a.h0(parcel, 3, this.zzc, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    public zzbb(String str, PendingIntent pendingIntent) {
        this(1, str, pendingIntent);
    }
}
