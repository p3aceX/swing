package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class B extends AbstractC0076l {
    public static final Parcelable.Creator<B> CREATOR = new D0.c(20);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f946a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Double f947b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f948c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f949d;
    public final Integer e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final L f950f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final V f951m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final C0070f f952n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final Long f953o;

    public B(byte[] bArr, Double d5, String str, ArrayList arrayList, Integer num, L l2, String str2, C0070f c0070f, Long l4) {
        com.google.android.gms.common.internal.F.g(bArr);
        this.f946a = bArr;
        this.f947b = d5;
        com.google.android.gms.common.internal.F.g(str);
        this.f948c = str;
        this.f949d = arrayList;
        this.e = num;
        this.f950f = l2;
        this.f953o = l4;
        if (str2 != null) {
            try {
                this.f951m = V.a(str2);
            } catch (U e) {
                throw new IllegalArgumentException(e);
            }
        } else {
            this.f951m = null;
        }
        this.f952n = c0070f;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof B)) {
            return false;
        }
        B b5 = (B) obj;
        if (!Arrays.equals(this.f946a, b5.f946a) || !com.google.android.gms.common.internal.F.j(this.f947b, b5.f947b) || !com.google.android.gms.common.internal.F.j(this.f948c, b5.f948c)) {
            return false;
        }
        ArrayList arrayList = this.f949d;
        ArrayList arrayList2 = b5.f949d;
        return ((arrayList == null && arrayList2 == null) || (arrayList != null && arrayList2 != null && arrayList.containsAll(arrayList2) && arrayList2.containsAll(arrayList))) && com.google.android.gms.common.internal.F.j(this.e, b5.e) && com.google.android.gms.common.internal.F.j(this.f950f, b5.f950f) && com.google.android.gms.common.internal.F.j(this.f951m, b5.f951m) && com.google.android.gms.common.internal.F.j(this.f952n, b5.f952n) && com.google.android.gms.common.internal.F.j(this.f953o, b5.f953o);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(Arrays.hashCode(this.f946a)), this.f947b, this.f948c, this.f949d, this.e, this.f950f, this.f951m, this.f952n, this.f953o});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.c0(parcel, 2, this.f946a, false);
        AbstractC0184a.d0(parcel, 3, this.f947b);
        AbstractC0184a.i0(parcel, 4, this.f948c, false);
        AbstractC0184a.l0(parcel, 5, this.f949d, false);
        AbstractC0184a.f0(parcel, 6, this.e);
        AbstractC0184a.h0(parcel, 7, this.f950f, i4, false);
        V v = this.f951m;
        AbstractC0184a.i0(parcel, 8, v == null ? null : v.f981a, false);
        AbstractC0184a.h0(parcel, 9, this.f952n, i4, false);
        AbstractC0184a.g0(parcel, 10, this.f953o);
        AbstractC0184a.n0(iM0, parcel);
    }
}
