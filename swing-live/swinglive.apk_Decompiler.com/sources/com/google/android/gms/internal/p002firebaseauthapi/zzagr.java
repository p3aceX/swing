package com.google.android.gms.internal.p002firebaseauthapi;

import H0.a;
import K.k;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;

/* JADX INFO: loaded from: classes.dex */
public final class zzagr implements Parcelable.Creator<zzags> {
    @Override // android.os.Parcelable.Creator
    public final zzags createFromParcel(Parcel parcel) {
        int iI0 = a.i0(parcel);
        String strQ = null;
        String strQ2 = null;
        String strQ3 = null;
        String strQ4 = null;
        String strQ5 = null;
        String strQ6 = null;
        String strQ7 = null;
        String strQ8 = null;
        String strQ9 = null;
        String strQ10 = null;
        String strQ11 = null;
        String strQ12 = null;
        String strQ13 = null;
        boolean zS = false;
        boolean zS2 = false;
        boolean zS3 = false;
        while (parcel.dataPosition() < iI0) {
            int i4 = parcel.readInt();
            switch ((char) i4) {
                case 2:
                    strQ = a.q(i4, parcel);
                    break;
                case 3:
                    strQ2 = a.q(i4, parcel);
                    break;
                case 4:
                    strQ3 = a.q(i4, parcel);
                    break;
                case 5:
                    strQ4 = a.q(i4, parcel);
                    break;
                case k.STRING_SET_FIELD_NUMBER /* 6 */:
                    strQ5 = a.q(i4, parcel);
                    break;
                case k.DOUBLE_FIELD_NUMBER /* 7 */:
                    strQ6 = a.q(i4, parcel);
                    break;
                case k.BYTES_FIELD_NUMBER /* 8 */:
                    strQ7 = a.q(i4, parcel);
                    break;
                case '\t':
                    strQ8 = a.q(i4, parcel);
                    break;
                case '\n':
                    zS = a.S(i4, parcel);
                    break;
                case ModuleDescriptor.MODULE_VERSION /* 11 */:
                    zS2 = a.S(i4, parcel);
                    break;
                case '\f':
                    strQ9 = a.q(i4, parcel);
                    break;
                case '\r':
                    strQ10 = a.q(i4, parcel);
                    break;
                case 14:
                    strQ11 = a.q(i4, parcel);
                    break;
                case 15:
                    strQ12 = a.q(i4, parcel);
                    break;
                case 16:
                    zS3 = a.S(i4, parcel);
                    break;
                case 17:
                    strQ13 = a.q(i4, parcel);
                    break;
                default:
                    a.e0(i4, parcel);
                    break;
            }
        }
        a.y(iI0, parcel);
        return new zzags(strQ, strQ2, strQ3, strQ4, strQ5, strQ6, strQ7, strQ8, zS, zS2, strQ9, strQ10, strQ11, strQ12, zS3, strQ13);
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ zzags[] newArray(int i4) {
        return new zzags[i4];
    }
}
