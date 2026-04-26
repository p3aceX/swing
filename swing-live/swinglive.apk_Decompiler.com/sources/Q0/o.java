package Q0;

import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public abstract class o extends i implements p {
    @Override // Q0.i
    public final boolean a(int i4, Parcel parcel, Parcel parcel2, int i5) {
        if (i4 == 2) {
            Parcelable.Creator creator = Bundle.CREATOR;
            Bundle bundle = (Bundle) j.a(parcel);
            j.b(parcel);
            e(bundle);
            return true;
        }
        if (i4 == 3) {
            Parcelable.Creator creator2 = Bundle.CREATOR;
            Bundle bundle2 = (Bundle) j.a(parcel);
            j.b(parcel);
            c(bundle2);
            return true;
        }
        if (i4 == 4) {
            Parcelable.Creator creator3 = Bundle.CREATOR;
            Bundle bundle3 = (Bundle) j.a(parcel);
            j.b(parcel);
            d(bundle3);
            return true;
        }
        if (i4 != 5) {
            return false;
        }
        Parcelable.Creator creator4 = Bundle.CREATOR;
        Bundle bundle4 = (Bundle) j.a(parcel);
        j.b(parcel);
        b(bundle4);
        return true;
    }
}
