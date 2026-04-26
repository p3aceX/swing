package com.google.android.gms.internal.p002firebaseauthapi;

import H0.a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class zzafs implements Parcelable.Creator<zzafp> {
    @Override // android.os.Parcelable.Creator
    public final zzafp createFromParcel(Parcel parcel) {
        int iI0 = a.i0(parcel);
        String strQ = null;
        String strQ2 = null;
        String strQ3 = null;
        while (parcel.dataPosition() < iI0) {
            int i4 = parcel.readInt();
            char c5 = (char) i4;
            if (c5 == 1) {
                strQ = a.q(i4, parcel);
            } else if (c5 == 2) {
                strQ2 = a.q(i4, parcel);
            } else if (c5 != 3) {
                a.e0(i4, parcel);
            } else {
                strQ3 = a.q(i4, parcel);
            }
        }
        a.y(iI0, parcel);
        return new zzafp(strQ, strQ2, strQ3);
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ zzafp[] newArray(int i4) {
        return new zzafp[i4];
    }
}
