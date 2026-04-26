package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.v, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0085v extends A0.a {
    public static final Parcelable.Creator<C0085v> CREATOR = new W(18);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f1038a;

    public C0085v(String str) {
        com.google.android.gms.common.internal.F.g(str);
        this.f1038a = str;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof C0085v) {
            return this.f1038a.equals(((C0085v) obj).f1038a);
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1038a});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 2, this.f1038a, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
