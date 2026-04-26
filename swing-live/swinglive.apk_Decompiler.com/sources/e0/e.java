package E0;

import K.k;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class e implements Parcelable.Creator {
    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        int iI0 = H0.a.i0(parcel);
        int iU = 0;
        int iU2 = 0;
        boolean zS = false;
        int iU3 = 0;
        boolean zS2 = false;
        int iU4 = 0;
        String strQ = null;
        String strQ2 = null;
        D0.b bVar = null;
        while (parcel.dataPosition() < iI0) {
            int i4 = parcel.readInt();
            switch ((char) i4) {
                case 1:
                    iU = H0.a.U(i4, parcel);
                    break;
                case 2:
                    iU2 = H0.a.U(i4, parcel);
                    break;
                case 3:
                    zS = H0.a.S(i4, parcel);
                    break;
                case 4:
                    iU3 = H0.a.U(i4, parcel);
                    break;
                case 5:
                    zS2 = H0.a.S(i4, parcel);
                    break;
                case k.STRING_SET_FIELD_NUMBER /* 6 */:
                    strQ = H0.a.q(i4, parcel);
                    break;
                case k.DOUBLE_FIELD_NUMBER /* 7 */:
                    iU4 = H0.a.U(i4, parcel);
                    break;
                case k.BYTES_FIELD_NUMBER /* 8 */:
                    strQ2 = H0.a.q(i4, parcel);
                    break;
                case '\t':
                    bVar = (D0.b) H0.a.o(parcel, i4, D0.b.CREATOR);
                    break;
                default:
                    H0.a.e0(i4, parcel);
                    break;
            }
        }
        H0.a.y(iI0, parcel);
        return new a(iU, iU2, zS, iU3, zS2, strQ, iU4, strQ2, bVar);
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ Object[] newArray(int i4) {
        return new a[i4];
    }
}
