package com.google.android.gms.internal.p002firebaseauthapi;

import H0.a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class zzafl implements Parcelable.Creator<zzafm> {
    @Override // android.os.Parcelable.Creator
    public final zzafm createFromParcel(Parcel parcel) {
        int iI0 = a.i0(parcel);
        String strQ = null;
        String strQ2 = null;
        Long lX = null;
        String strQ3 = null;
        Long lX2 = null;
        while (parcel.dataPosition() < iI0) {
            int i4 = parcel.readInt();
            char c5 = (char) i4;
            if (c5 == 2) {
                strQ = a.q(i4, parcel);
            } else if (c5 == 3) {
                strQ2 = a.q(i4, parcel);
            } else if (c5 == 4) {
                lX = a.X(i4, parcel);
            } else if (c5 == 5) {
                strQ3 = a.q(i4, parcel);
            } else if (c5 != 6) {
                a.e0(i4, parcel);
            } else {
                lX2 = a.X(i4, parcel);
            }
        }
        a.y(iI0, parcel);
        return new zzafm(strQ, strQ2, lX, strQ3, lX2);
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ zzafm[] newArray(int i4) {
        return new zzafm[i4];
    }
}
