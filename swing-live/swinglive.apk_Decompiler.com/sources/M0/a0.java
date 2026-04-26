package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

/* JADX INFO: loaded from: classes.dex */
public final class a0 extends A0.a {
    public static final Parcelable.Creator<a0> CREATOR = new W(15);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f991a;

    public a0(ArrayList arrayList) {
        com.google.android.gms.common.internal.F.g(arrayList);
        this.f991a = arrayList;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof a0)) {
            return false;
        }
        a0 a0Var = (a0) obj;
        ArrayList arrayList = a0Var.f991a;
        ArrayList arrayList2 = this.f991a;
        return arrayList2.containsAll(arrayList) && a0Var.f991a.containsAll(arrayList2);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{new HashSet(this.f991a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.l0(parcel, 1, this.f991a, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
