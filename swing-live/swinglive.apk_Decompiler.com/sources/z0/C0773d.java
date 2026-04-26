package z0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.r;
import java.util.Arrays;
import w0.C0701c;

/* JADX INFO: renamed from: z0.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0773d extends A0.a {
    public static final Parcelable.Creator<C0773d> CREATOR = new C0701c(5);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6955a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6956b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f6957c;

    public C0773d(long j4, String str, int i4) {
        this.f6955a = str;
        this.f6956b = i4;
        this.f6957c = j4;
    }

    public final long b() {
        long j4 = this.f6957c;
        return j4 == -1 ? this.f6956b : j4;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof C0773d) {
            C0773d c0773d = (C0773d) obj;
            String str = this.f6955a;
            if (((str != null && str.equals(c0773d.f6955a)) || (str == null && c0773d.f6955a == null)) && b() == c0773d.b()) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6955a, Long.valueOf(b())});
    }

    public final String toString() {
        r rVar = new r(this);
        rVar.v(this.f6955a, "name");
        rVar.v(Long.valueOf(b()), "version");
        return rVar.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f6955a, false);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f6956b);
        long jB = b();
        AbstractC0184a.o0(parcel, 3, 8);
        parcel.writeLong(jB);
        AbstractC0184a.n0(iM0, parcel);
    }

    public C0773d(String str, long j4) {
        this.f6955a = str;
        this.f6957c = j4;
        this.f6956b = -1;
    }
}
