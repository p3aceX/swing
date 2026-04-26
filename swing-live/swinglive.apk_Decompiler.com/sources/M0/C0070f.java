package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0070f extends A0.a {
    public static final Parcelable.Creator<C0070f> CREATOR = new W(3);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0085v f998a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final a0 f999b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final M f1000c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final c0 f1001d;
    public final P e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Q f1002f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final b0 f1003m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final S f1004n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final C0086w f1005o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final T f1006p;

    public C0070f(C0085v c0085v, a0 a0Var, M m4, c0 c0Var, P p4, Q q4, b0 b0Var, S s4, C0086w c0086w, T t4) {
        this.f998a = c0085v;
        this.f1000c = m4;
        this.f999b = a0Var;
        this.f1001d = c0Var;
        this.e = p4;
        this.f1002f = q4;
        this.f1003m = b0Var;
        this.f1004n = s4;
        this.f1005o = c0086w;
        this.f1006p = t4;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0070f)) {
            return false;
        }
        C0070f c0070f = (C0070f) obj;
        return com.google.android.gms.common.internal.F.j(this.f998a, c0070f.f998a) && com.google.android.gms.common.internal.F.j(this.f999b, c0070f.f999b) && com.google.android.gms.common.internal.F.j(this.f1000c, c0070f.f1000c) && com.google.android.gms.common.internal.F.j(this.f1001d, c0070f.f1001d) && com.google.android.gms.common.internal.F.j(this.e, c0070f.e) && com.google.android.gms.common.internal.F.j(this.f1002f, c0070f.f1002f) && com.google.android.gms.common.internal.F.j(this.f1003m, c0070f.f1003m) && com.google.android.gms.common.internal.F.j(this.f1004n, c0070f.f1004n) && com.google.android.gms.common.internal.F.j(this.f1005o, c0070f.f1005o) && com.google.android.gms.common.internal.F.j(this.f1006p, c0070f.f1006p);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f998a, this.f999b, this.f1000c, this.f1001d, this.e, this.f1002f, this.f1003m, this.f1004n, this.f1005o, this.f1006p});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 2, this.f998a, i4, false);
        AbstractC0184a.h0(parcel, 3, this.f999b, i4, false);
        AbstractC0184a.h0(parcel, 4, this.f1000c, i4, false);
        AbstractC0184a.h0(parcel, 5, this.f1001d, i4, false);
        AbstractC0184a.h0(parcel, 6, this.e, i4, false);
        AbstractC0184a.h0(parcel, 7, this.f1002f, i4, false);
        AbstractC0184a.h0(parcel, 8, this.f1003m, i4, false);
        AbstractC0184a.h0(parcel, 9, this.f1004n, i4, false);
        AbstractC0184a.h0(parcel, 10, this.f1005o, i4, false);
        AbstractC0184a.h0(parcel, 11, this.f1006p, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
