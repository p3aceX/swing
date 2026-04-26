package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class F extends A0.a {
    public static final Parcelable.Creator<F> CREATOR = new D0.c(23);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f958a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f959b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f960c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f961d;

    public F(byte[] bArr, String str, String str2, String str3) {
        com.google.android.gms.common.internal.F.g(bArr);
        this.f958a = bArr;
        com.google.android.gms.common.internal.F.g(str);
        this.f959b = str;
        this.f960c = str2;
        com.google.android.gms.common.internal.F.g(str3);
        this.f961d = str3;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof F)) {
            return false;
        }
        F f4 = (F) obj;
        return Arrays.equals(this.f958a, f4.f958a) && com.google.android.gms.common.internal.F.j(this.f959b, f4.f959b) && com.google.android.gms.common.internal.F.j(this.f960c, f4.f960c) && com.google.android.gms.common.internal.F.j(this.f961d, f4.f961d);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f958a, this.f959b, this.f960c, this.f961d});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.c0(parcel, 2, this.f958a, false);
        AbstractC0184a.i0(parcel, 3, this.f959b, false);
        AbstractC0184a.i0(parcel, 4, this.f960c, false);
        AbstractC0184a.i0(parcel, 5, this.f961d, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
