package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class S extends A0.a {
    public static final Parcelable.Creator<S> CREATOR = new D0.c(14);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f978a;

    public S(String str) {
        com.google.android.gms.common.internal.F.g(str);
        this.f978a = str;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof S) {
            return this.f978a.equals(((S) obj).f978a);
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f978a});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f978a, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
