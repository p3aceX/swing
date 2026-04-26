package Q0;

import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public abstract class t extends i implements u {
    @Override // Q0.i
    public final boolean a(int i4, Parcel parcel, Parcel parcel2, int i5) {
        if (i4 != 2) {
            return false;
        }
        Parcelable.Creator creator = Bundle.CREATOR;
        Bundle bundle = (Bundle) j.a(parcel);
        j.b(parcel);
        b(bundle);
        return true;
    }
}
