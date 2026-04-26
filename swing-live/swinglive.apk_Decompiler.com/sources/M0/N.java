package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

/* JADX INFO: loaded from: classes.dex */
public final class N extends A0.a {
    public static final Parcelable.Creator<N> CREATOR = new D0.c(29);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f972a;

    public N(ArrayList arrayList) {
        this.f972a = arrayList;
    }

    public final boolean equals(Object obj) {
        ArrayList arrayList;
        if (!(obj instanceof N)) {
            return false;
        }
        N n4 = (N) obj;
        ArrayList arrayList2 = this.f972a;
        if (arrayList2 == null && n4.f972a == null) {
            return true;
        }
        return arrayList2 != null && (arrayList = n4.f972a) != null && arrayList2.containsAll(arrayList) && n4.f972a.containsAll(arrayList2);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{new HashSet(this.f972a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.l0(parcel, 1, this.f972a, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
