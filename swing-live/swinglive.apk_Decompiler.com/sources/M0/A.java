package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class A extends A0.a {
    public static final Parcelable.Creator<A> CREATOR = new D0.c(19);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final E f944a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final r f945b;

    public A(String str, int i4) {
        com.google.android.gms.common.internal.F.g(str);
        try {
            this.f944a = E.a(str);
            try {
                this.f945b = r.a(i4);
            } catch (C0081q e) {
                throw new IllegalArgumentException(e);
            }
        } catch (D e4) {
            throw new IllegalArgumentException(e4);
        }
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof A)) {
            return false;
        }
        A a5 = (A) obj;
        return this.f944a.equals(a5.f944a) && this.f945b.equals(a5.f945b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f944a, this.f945b});
    }

    /* JADX WARN: Type inference failed for: r0v3, types: [M0.a, java.lang.Enum] */
    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        this.f944a.getClass();
        AbstractC0184a.i0(parcel, 2, "public-key", false);
        AbstractC0184a.f0(parcel, 3, Integer.valueOf(this.f945b.f1033a.a()));
        AbstractC0184a.n0(iM0, parcel);
    }
}
