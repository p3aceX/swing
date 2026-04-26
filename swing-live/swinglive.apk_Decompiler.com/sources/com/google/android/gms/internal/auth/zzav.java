package com.google.android.gms.internal.auth;

import A0.a;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;

/* JADX INFO: loaded from: classes.dex */
public final class zzav extends a {
    public static final Parcelable.Creator<zzav> CREATOR = new zzaw();
    final int zza;
    public final String zzb;
    public final int zzc;

    public zzav(int i4, String str, int i5) {
        this.zza = 1;
        F.g(str);
        this.zzb = str;
        this.zzc = i5;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        int i5 = this.zza;
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(i5);
        AbstractC0184a.i0(parcel, 2, this.zzb, false);
        int i6 = this.zzc;
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(i6);
        AbstractC0184a.n0(iM0, parcel);
    }

    public zzav(String str, int i4) {
        this(1, str, i4);
    }
}
