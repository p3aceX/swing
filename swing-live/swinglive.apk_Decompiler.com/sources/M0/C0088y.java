package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.y, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0088y extends AbstractC0076l {
    public static final Parcelable.Creator<C0088y> CREATOR = new D0.c(16);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C f1047a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final F f1048b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f1049c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f1050d;
    public final Double e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final ArrayList f1051f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C0077m f1052m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final Integer f1053n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final L f1054o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final EnumC0069e f1055p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final C0070f f1056q;

    public C0088y(C c5, F f4, byte[] bArr, ArrayList arrayList, Double d5, ArrayList arrayList2, C0077m c0077m, Integer num, L l2, String str, C0070f c0070f) {
        com.google.android.gms.common.internal.F.g(c5);
        this.f1047a = c5;
        com.google.android.gms.common.internal.F.g(f4);
        this.f1048b = f4;
        com.google.android.gms.common.internal.F.g(bArr);
        this.f1049c = bArr;
        com.google.android.gms.common.internal.F.g(arrayList);
        this.f1050d = arrayList;
        this.e = d5;
        this.f1051f = arrayList2;
        this.f1052m = c0077m;
        this.f1053n = num;
        this.f1054o = l2;
        if (str != null) {
            try {
                this.f1055p = EnumC0069e.a(str);
            } catch (C0068d e) {
                throw new IllegalArgumentException(e);
            }
        } else {
            this.f1055p = null;
        }
        this.f1056q = c0070f;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0088y)) {
            return false;
        }
        C0088y c0088y = (C0088y) obj;
        if (!com.google.android.gms.common.internal.F.j(this.f1047a, c0088y.f1047a) || !com.google.android.gms.common.internal.F.j(this.f1048b, c0088y.f1048b) || !Arrays.equals(this.f1049c, c0088y.f1049c) || !com.google.android.gms.common.internal.F.j(this.e, c0088y.e)) {
            return false;
        }
        ArrayList arrayList = this.f1050d;
        ArrayList arrayList2 = c0088y.f1050d;
        if (!arrayList.containsAll(arrayList2) || !arrayList2.containsAll(arrayList)) {
            return false;
        }
        ArrayList arrayList3 = this.f1051f;
        ArrayList arrayList4 = c0088y.f1051f;
        return ((arrayList3 == null && arrayList4 == null) || (arrayList3 != null && arrayList4 != null && arrayList3.containsAll(arrayList4) && arrayList4.containsAll(arrayList3))) && com.google.android.gms.common.internal.F.j(this.f1052m, c0088y.f1052m) && com.google.android.gms.common.internal.F.j(this.f1053n, c0088y.f1053n) && com.google.android.gms.common.internal.F.j(this.f1054o, c0088y.f1054o) && com.google.android.gms.common.internal.F.j(this.f1055p, c0088y.f1055p) && com.google.android.gms.common.internal.F.j(this.f1056q, c0088y.f1056q);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1047a, this.f1048b, Integer.valueOf(Arrays.hashCode(this.f1049c)), this.f1050d, this.e, this.f1051f, this.f1052m, this.f1053n, this.f1054o, this.f1055p, this.f1056q});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 2, this.f1047a, i4, false);
        AbstractC0184a.h0(parcel, 3, this.f1048b, i4, false);
        AbstractC0184a.c0(parcel, 4, this.f1049c, false);
        AbstractC0184a.l0(parcel, 5, this.f1050d, false);
        AbstractC0184a.d0(parcel, 6, this.e);
        AbstractC0184a.l0(parcel, 7, this.f1051f, false);
        AbstractC0184a.h0(parcel, 8, this.f1052m, i4, false);
        AbstractC0184a.f0(parcel, 9, this.f1053n);
        AbstractC0184a.h0(parcel, 10, this.f1054o, i4, false);
        EnumC0069e enumC0069e = this.f1055p;
        AbstractC0184a.i0(parcel, 11, enumC0069e == null ? null : enumC0069e.f997a, false);
        AbstractC0184a.h0(parcel, 12, this.f1056q, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
