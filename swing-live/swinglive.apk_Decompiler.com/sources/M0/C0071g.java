package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0071g extends A0.a {
    public static final Parcelable.Creator<C0071g> CREATOR = new W(2);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final N f1007a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final X f1008b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0072h f1009c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Y f1010d;

    public C0071g(N n4, X x4, C0072h c0072h, Y y4) {
        this.f1007a = n4;
        this.f1008b = x4;
        this.f1009c = c0072h;
        this.f1010d = y4;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0071g)) {
            return false;
        }
        C0071g c0071g = (C0071g) obj;
        return com.google.android.gms.common.internal.F.j(this.f1007a, c0071g.f1007a) && com.google.android.gms.common.internal.F.j(this.f1008b, c0071g.f1008b) && com.google.android.gms.common.internal.F.j(this.f1009c, c0071g.f1009c) && com.google.android.gms.common.internal.F.j(this.f1010d, c0071g.f1010d);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1007a, this.f1008b, this.f1009c, this.f1010d});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f1007a, i4, false);
        AbstractC0184a.h0(parcel, 2, this.f1008b, i4, false);
        AbstractC0184a.h0(parcel, 3, this.f1009c, i4, false);
        AbstractC0184a.h0(parcel, 4, this.f1010d, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
