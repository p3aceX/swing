package q0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: renamed from: q0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0627a extends A0.a {
    public static final Parcelable.Creator<C0627a> CREATOR = new C0454D(5);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6241a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final long f6242b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6243c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f6244d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f6245f;

    public C0627a(int i4, long j4, String str, int i5, int i6, String str2) {
        this.f6241a = i4;
        this.f6242b = j4;
        F.g(str);
        this.f6243c = str;
        this.f6244d = i5;
        this.e = i6;
        this.f6245f = str2;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0627a)) {
            return false;
        }
        if (obj == this) {
            return true;
        }
        C0627a c0627a = (C0627a) obj;
        return this.f6241a == c0627a.f6241a && this.f6242b == c0627a.f6242b && F.j(this.f6243c, c0627a.f6243c) && this.f6244d == c0627a.f6244d && this.e == c0627a.e && F.j(this.f6245f, c0627a.f6245f);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(this.f6241a), Long.valueOf(this.f6242b), this.f6243c, Integer.valueOf(this.f6244d), Integer.valueOf(this.e), this.f6245f});
    }

    public final String toString() {
        int i4 = this.f6244d;
        return "AccountChangeEvent {accountName = " + this.f6243c + ", changeType = " + (i4 != 1 ? i4 != 2 ? i4 != 3 ? i4 != 4 ? "UNKNOWN" : "RENAMED_TO" : "RENAMED_FROM" : "REMOVED" : "ADDED") + ", changeData = " + this.f6245f + ", eventIndex = " + this.e + "}";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6241a);
        AbstractC0184a.o0(parcel, 2, 8);
        parcel.writeLong(this.f6242b);
        AbstractC0184a.i0(parcel, 3, this.f6243c, false);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f6244d);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e);
        AbstractC0184a.i0(parcel, 6, this.f6245f, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
