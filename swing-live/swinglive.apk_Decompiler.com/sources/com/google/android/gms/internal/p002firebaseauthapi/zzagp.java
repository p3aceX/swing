package com.google.android.gms.internal.p002firebaseauthapi;

import H0.a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class zzagp implements Parcelable.Creator<zzagq> {
    @Override // android.os.Parcelable.Creator
    public final zzagq createFromParcel(Parcel parcel) {
        int iI0 = a.i0(parcel);
        while (parcel.dataPosition() < iI0) {
            a.e0(parcel.readInt(), parcel);
        }
        a.y(iI0, parcel);
        return new zzagq();
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ zzagq[] newArray(int i4) {
        return new zzagq[i4];
    }
}
