package com.google.android.gms.internal.auth;

import H0.a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class zzaw implements Parcelable.Creator {
    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        int iI0 = a.i0(parcel);
        int iU = 0;
        String strQ = null;
        int iU2 = 0;
        while (parcel.dataPosition() < iI0) {
            int i4 = parcel.readInt();
            char c5 = (char) i4;
            if (c5 == 1) {
                iU = a.U(i4, parcel);
            } else if (c5 == 2) {
                strQ = a.q(i4, parcel);
            } else if (c5 != 3) {
                a.e0(i4, parcel);
            } else {
                iU2 = a.U(i4, parcel);
            }
        }
        a.y(iI0, parcel);
        return new zzav(iU, strQ, iU2);
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ Object[] newArray(int i4) {
        return new zzav[i4];
    }
}
