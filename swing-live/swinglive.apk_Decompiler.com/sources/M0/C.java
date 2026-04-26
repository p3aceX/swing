package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class C extends A0.a {
    public static final Parcelable.Creator<C> CREATOR = new D0.c(21);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f954a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f955b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f956c;

    public C(String str, String str2, String str3) {
        com.google.android.gms.common.internal.F.g(str);
        this.f954a = str;
        com.google.android.gms.common.internal.F.g(str2);
        this.f955b = str2;
        this.f956c = str3;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C)) {
            return false;
        }
        C c5 = (C) obj;
        return com.google.android.gms.common.internal.F.j(this.f954a, c5.f954a) && com.google.android.gms.common.internal.F.j(this.f955b, c5.f955b) && com.google.android.gms.common.internal.F.j(this.f956c, c5.f956c);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f954a, this.f955b, this.f956c});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 2, this.f954a, false);
        AbstractC0184a.i0(parcel, 3, this.f955b, false);
        AbstractC0184a.i0(parcel, 4, this.f956c, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
