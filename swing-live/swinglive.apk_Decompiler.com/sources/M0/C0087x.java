package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.x, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0087x extends A0.a {
    public static final Parcelable.Creator<C0087x> CREATOR = new D0.c(17);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f1040a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f1041b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f1042c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0074j f1043d;
    public final C0073i e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C0075k f1044f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C0071g f1045m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final String f1046n;

    public C0087x(String str, String str2, byte[] bArr, C0074j c0074j, C0073i c0073i, C0075k c0075k, C0071g c0071g, String str3) {
        boolean z4 = true;
        if ((c0074j == null || c0073i != null || c0075k != null) && ((c0074j != null || c0073i == null || c0075k != null) && (c0074j != null || c0073i != null || c0075k == null))) {
            z4 = false;
        }
        com.google.android.gms.common.internal.F.b(z4);
        this.f1040a = str;
        this.f1041b = str2;
        this.f1042c = bArr;
        this.f1043d = c0074j;
        this.e = c0073i;
        this.f1044f = c0075k;
        this.f1045m = c0071g;
        this.f1046n = str3;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0087x)) {
            return false;
        }
        C0087x c0087x = (C0087x) obj;
        return com.google.android.gms.common.internal.F.j(this.f1040a, c0087x.f1040a) && com.google.android.gms.common.internal.F.j(this.f1041b, c0087x.f1041b) && Arrays.equals(this.f1042c, c0087x.f1042c) && com.google.android.gms.common.internal.F.j(this.f1043d, c0087x.f1043d) && com.google.android.gms.common.internal.F.j(this.e, c0087x.e) && com.google.android.gms.common.internal.F.j(this.f1044f, c0087x.f1044f) && com.google.android.gms.common.internal.F.j(this.f1045m, c0087x.f1045m) && com.google.android.gms.common.internal.F.j(this.f1046n, c0087x.f1046n);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1040a, this.f1041b, this.f1042c, this.e, this.f1043d, this.f1044f, this.f1045m, this.f1046n});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f1040a, false);
        AbstractC0184a.i0(parcel, 2, this.f1041b, false);
        AbstractC0184a.c0(parcel, 3, this.f1042c, false);
        AbstractC0184a.h0(parcel, 4, this.f1043d, i4, false);
        AbstractC0184a.h0(parcel, 5, this.e, i4, false);
        AbstractC0184a.h0(parcel, 6, this.f1044f, i4, false);
        AbstractC0184a.h0(parcel, 7, this.f1045m, i4, false);
        AbstractC0184a.i0(parcel, 8, this.f1046n, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
