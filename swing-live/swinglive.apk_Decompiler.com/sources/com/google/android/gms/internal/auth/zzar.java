package com.google.android.gms.internal.auth;

import H0.a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class zzar implements Parcelable.Creator {
    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        int iI0 = a.i0(parcel);
        String strQ = null;
        int iU = 0;
        while (parcel.dataPosition() < iI0) {
            int i4 = parcel.readInt();
            char c5 = (char) i4;
            if (c5 == 1) {
                iU = a.U(i4, parcel);
            } else if (c5 != 2) {
                a.e0(i4, parcel);
            } else {
                strQ = a.q(i4, parcel);
            }
        }
        a.y(iI0, parcel);
        return new zzaq(iU, strQ);
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ Object[] newArray(int i4) {
        return new zzaq[i4];
    }
}
