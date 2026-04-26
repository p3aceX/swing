package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class d extends A0.a {
    public static final Parcelable.Creator<d> CREATOR = new C0454D(22);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f6602a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f6603b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6604c;

    public d(String str, boolean z4, byte[] bArr) {
        if (z4) {
            F.g(bArr);
            F.g(str);
        }
        this.f6602a = z4;
        this.f6603b = bArr;
        this.f6604c = str;
    }

    public final boolean equals(Object obj) {
        String str;
        String str2;
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof d)) {
            return false;
        }
        d dVar = (d) obj;
        return this.f6602a == dVar.f6602a && Arrays.equals(this.f6603b, dVar.f6603b) && ((str = this.f6604c) == (str2 = dVar.f6604c) || (str != null && str.equals(str2)));
    }

    public final int hashCode() {
        return Arrays.hashCode(this.f6603b) + (Arrays.hashCode(new Object[]{Boolean.valueOf(this.f6602a), this.f6604c}) * 31);
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6602a ? 1 : 0);
        AbstractC0184a.c0(parcel, 2, this.f6603b, false);
        AbstractC0184a.i0(parcel, 3, this.f6604c, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
