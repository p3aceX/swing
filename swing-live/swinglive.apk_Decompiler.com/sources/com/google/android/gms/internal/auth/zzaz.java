package com.google.android.gms.internal.auth;

import A0.a;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;

/* JADX INFO: loaded from: classes.dex */
public final class zzaz extends a {
    public static final Parcelable.Creator<zzaz> CREATOR = new zzba();
    final int zza;
    public final String zzb;
    public final byte[] zzc;

    public zzaz(int i4, String str, byte[] bArr) {
        this.zza = 1;
        F.g(str);
        this.zzb = str;
        F.g(bArr);
        this.zzc = bArr;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        int i5 = this.zza;
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(i5);
        AbstractC0184a.i0(parcel, 2, this.zzb, false);
        AbstractC0184a.c0(parcel, 3, this.zzc, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    public zzaz(String str, byte[] bArr) {
        this(1, str, bArr);
    }
}
